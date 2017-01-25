#!/usr/bin/env bash
source ANSIBLE_DOCKER_ENV

docker run -it -v "$(pwd):/project" \
                -v ~/.aws:/root/.aws \
                -e CLUSTER_NAME=$1 \
                -e ENV=$2 \
                simplemachines/ansible-template:$DOCKER_TAG \
                scripts/run-infrastructure.sh
