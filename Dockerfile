FROM python:2.7.12

RUN apt-get update && apt-get install -y nano
ENV EDITOR=nano

# Contains the version we need to pull for ansible
COPY ANSIBLE_DOCKER_ENV /

# Collect Ansible
RUN /bin/bash -c 'source /ANSIBLE_DOCKER_ENV \
    && pip install git+https://github.com/ansible/ansible.git@$ANSIBLE_COMMIT_HASH#egg=ansible boto boto3 awscli'

VOLUME ["/project", "/root/.aws"]
WORKDIR /project
