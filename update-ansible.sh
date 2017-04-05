#!/usr/bin/env bash
set -e
if [ ! -z "$1" ]
  then
    echo "Updating from $1"
    UPDATE_FROM=$1
  else
    echo "Updating from github"
    VERSION=master
    rm -Rf ansible-aws-infra-services-$VERSION
    curl -L --silent --show-error https://github.com/simple-machines/ansible-aws-infra-services/archive/$VERSION.tar.gz | tar xz
    UPDATE_FROM="ansible-aws-infra-services-$VERSION"
fi

rsync \
      --exclude="example-cluster" \
      --exclude="roles/custom*" \
      --include="roles/***" \
      --include="scripts/***" \
      -rav $UPDATE_FROM/* . \
