#!/usr/bin/env bash
#
# NAME
#     run-service.sh - Run Ansible with service configurations
#
# SYNOPSIS
#     ./run-service.sh CLUSTER SERVICE ENV
#     ./run-service.sh

set -eu -o pipefail

source ANSIBLE_DOCKER_ENV

USAGE=$(sed -E -e '/^$/q' -e 's/^#($|!.*| (.*))$/\2/' "$0")

case $# in
    3) docker run -it -v "${PWD}:/project" \
                -v ~/.aws:/root/.aws \
                -e "CLUSTER_NAME=${1:?"Required argument missing. $USAGE"}" \
                -e "SERVICE_NAME=${2:?"Required argument missing. $USAGE"}" \
                -e "ENV=${3:?"Required argument missing. $USAGE"}" \
                "simplemachines/ansible-template:${DOCKER_TAG:?"Required variable missing. $USAGE"}" \
                scripts/run-service.sh
       ;;
    *) # Display usage along with suggested arguments
	cat <<EOF
ERROR: $0 requires 3 arguments; $# provided. $USAGE

OPTIONS

    You may want to run one of the following commands:

EOF

    # We'll ignore vault files; we won't be able to run them anyway.
	find . -maxdepth 4 -type f -name '*.yml' ! -name 'common.yml' ! -name '*.vault.yml' | sort \
	    | egrep '^./([^/]+/services/[^/]+/.*.yml)$' \
	    | sed -Ee "/services/s#^./([^/]*)/services/([^/]*)/(.*).yml\$#    $0 \1 \2 \3#g" \
	    || echo "        ERROR: No clusters or services found"
	exit 1
	;;
esac
