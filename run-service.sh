#!/usr/bin/env bash
source ANSIBLE_DOCKER_ENV

docker run -it -v "$(pwd):/project" \
                -v ~/.aws:/root/.aws \
                -e CLUSTER_NAME=$1 \
                -e SERVICE_NAME=$2 \
                -e ENV=$3 \
                simplemachines/ansible-template:$DOCKER_TAG \
                scripts/run-service.sh
