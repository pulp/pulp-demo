#!/bin/bash

########################
# include the magic
########################
. demo-magic.sh


########################
# functions
########################

wait_until_task_finished() {
    local task_url=$1
    while true
    do
        local response=$(http :24817$task_url)
        local state=$(jq -r .state <<< ${response})
        jq . <<< "${response}"
        case ${state} in
            failed|canceled)
                exit 1
                ;;
            completed)
                break
                ;;
            *)
                sleep 1
                ;;
        esac
    done
}


########################
# demo code
########################

# hide the evidence
clear

BASE_ADDR=":24817"
SERVICES=("pulp-content-app pulp-worker@1 pulp-worker@2 pulp-resource-manager pulp-api")


# create repo

pe "http POST $BASE_ADDR/pulp/api/v3/repositories/ name=foo"

export REPO_HREF=$(http $BASE_ADDR/pulp/api/v3/repositories/ | \
  jq -r '.results[] | select(.name == "foo") | ._href')


# create remote

pe "http POST $BASE_ADDR/pulp/api/v3/remotes/ansible/collection/ \\
    name='bar' \\
    url='https://galaxy.ansible.com/api/v2/collections'
"
export REMOTE_HREF=$(http $BASE_ADDR/pulp/api/v3/remotes/ansible/collection/ | jq -r '.results[] | select(.name == "bar") | ._href')


# sync

p "http POST $BASE_ADDR${REMOTE_HREF}sync/ \\
   repository=$REPO_HREF"
export TASK_URL=$(http POST $BASE_ADDR$REMOTE_HREF'sync/' repository=$REPO_HREF \
  | jq -r '.task')
wait_until_task_finished $TASK_URL
export REPOVERSION_HREF=$(http $BASE_ADDR$TASK_URL| jq -r '.created_resources | first')
pe "http $BASE_ADDR$REPOVERSION_HREF"


# distribute

p "http POST $BASE_ADDR/pulp/api/v3/distributions/ansible/ansible/ \\
  name='baz' \\
  base_path='dev' \\
  repository=${REPO_HREF}
"
export TASK_URL=$(http POST $BASE_ADDR/pulp/api/v3/distributions/ansible/ansible/ \
  name='baz' \
  base_path='dev' \
  repository=${REPO_HREF} | jq -r '.task')
wait_until_task_finished $TASK_URL
export DIST_PATH=$(http $BASE_ADDR$TASK_URL| jq -r '.created_resources | first')
pe "http $BASE_ADDR$DIST_PATH"


# mazer config

pe 'cat ~/.ansible/mazer.yml'


# mazer install

pe "mazer install testing.k8s_demo_collection"


# done

pe "echo 'done'"


# cleanup (edit depending on setup)

rm -rf ~/.ansible/collections/ansible_collections/testing/k8s_demo_collection/

sudo systemctl stop ${SERVICES}

django-admin reset_db --noinput
django-admin migrate
django-admin reset-admin-password --password password

sudo systemctl start ${SERVICES}