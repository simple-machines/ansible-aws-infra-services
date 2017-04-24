#!/usr/bin/env bash
#
# NAME
#     editvault.sh - Edit ansible vault contents
#
# SYNOPSIS
#     ./editvault.sh services CLUSTER SERVICE ENV
#     ./editvault.sh infrastructure CLUSTER ENV

set -eu -o pipefail
source ANSIBLE_DOCKER_ENV

USAGE=$(sed -E -e '/^$/q' -e 's/^#($|!.*| (.*))$/\2/' "$0")

SERVICE_OR_CLUSTER_PARAM=${1:?"Required argument missing. $USAGE"}
CLUSTER_NAME_PARAM=${2:?"Required argument missing. $USAGE"}

if [ "$SERVICE_OR_CLUSTER_PARAM" = "services" ]
then
    SERVICE_NAME_PARAM=${3:?"Required argument missing. $USAGE"}
    TARGET_ENV_PARAM=${4:?"Required argument missing. $USAGE"}
    docker run -it -v "$(pwd):/project" -v ~/.aws:/root/.aws \
        -e "TARGET_ENV=$TARGET_ENV_PARAM" \
        -e "CLUSTER_NAME=$CLUSTER_NAME_PARAM" \
        -e "SERVICE_NAME=$SERVICE_NAME_PARAM" \
        "simplemachines/ansible-template:$DOCKER_TAG" \
        scripts/editvault-services.sh
else
    TARGET_ENV_PARAM=${3:?"Required argument missing. $USAGE"}
    docker run -it -v "$(pwd):/project" -v ~/.aws:/root/.aws \
        -e "TARGET_ENV=$TARGET_ENV_PARAM" \
        -e "CLUSTER_NAME=$CLUSTER_NAME_PARAM" \
        "simplemachines/ansible-template:$DOCKER_TAG" \
        scripts/editvault-infrastructure.sh
fi
