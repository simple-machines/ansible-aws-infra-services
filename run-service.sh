#!/usr/bin/env bash
#
# NAME
#     run-service.sh - Run Ansible with service configurations
#
# SYNOPSIS
#     ./run-service.sh CLUSTER SERVICE ENV

set -eu -o pipefail

source ANSIBLE_DOCKER_ENV

USAGE=$(sed -E -e '/^$/q' -e 's/^#($|!.*| (.*))$/\2/' "$0")

docker run -it -v "${PWD}:/project" \
                -v ~/.aws:/root/.aws \
                -e "CLUSTER_NAME=${1:?"Required argument missing. $USAGE"}" \
                -e "SERVICE_NAME=${2:?"Required argument missing. $USAGE"}" \
                -e "ENV=${3:?"Required argument missing. $USAGE"}" \
                "simplemachines/ansible-template:${DOCKER_TAG:?"Required variable missing. $USAGE"}" \
                scripts/run-service.sh
