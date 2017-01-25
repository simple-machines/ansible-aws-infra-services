#!/bin/bash
ansible-playbook -vvv --vault-password-file=/project/.vaultpassword \
                  /project/infrastructure.yml \
                  -e "env=$ENV cluster_name=$CLUSTER_NAME"
