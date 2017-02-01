#!/usr/bin/env bash
source ANSIBLE_DOCKER_ENV

SERVICE_OR_CLUSTER_PARAM=$1
CLUSTER_NAME_PARAM=$2

if [ $SERVICE_OR_CLUSTER_PARAM = "services" ]
then
    SERVICE_NAME_PARAM=$3
    TARGET_ENV_PARAM=$4
    docker run -it -v "$(pwd):/project" -v ~/.aws:/root/.aws -e TARGET_ENV=$TARGET_ENV_PARAM -e CLUSTER_NAME=$CLUSTER_NAME_PARAM -e SERVICE_NAME=$SERVICE_NAME_PARAM simplemachines/ansible-template:$DOCKER_TAG scripts/editvault-services.sh
else
    TARGET_ENV_PARAM=$3
    docker run -it -v "$(pwd):/project" -v ~/.aws:/root/.aws -e TARGET_ENV=$TARGET_ENV_PARAM -e CLUSTER_NAME=$CLUSTER_NAME_PARAM simplemachines/ansible-template:$DOCKER_TAG scripts/editvault-infrastructure.sh
fi

