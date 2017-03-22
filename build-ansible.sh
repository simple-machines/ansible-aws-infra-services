#!/bin/bash

# You shouldn't have to run this file
# This describes how Docker Hub will build the images based on tags
source ANSIBLE_DOCKER_ENV

docker build . -t simplemachines/ansible-template:$DOCKER_TAG
