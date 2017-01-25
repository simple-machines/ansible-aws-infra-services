#!/bin/bash
ansible-playbook -vvv --vault-password-file=/project/.vaultpassword \
                  /project/service.yml \
                  -e "env=$ENV cluster_name=$CLUSTER_NAME service_name=$SERVICE_NAME"
