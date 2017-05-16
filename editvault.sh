#!/usr/bin/env bash
#
# NAME
#     editvault.sh - Edit ansible vault contents
#
# SYNOPSIS
#     ./editvault.sh CLUSTER SERVICE ENV
#     ./editvault.sh CLUSTER ENV
#     ./editvault.sh

set -eu -o pipefail

source ANSIBLE_DOCKER_ENV

USAGE=$(sed -E -e '/^$/q' -e 's/^#($|!.*| (.*))$/\2/' "$0")

case $# in
    3)
	CLUSTER_NAME_PARAM="${1}"
	SERVICE_NAME_PARAM="${2}"
	TARGET_ENV_PARAM="${3}"
	docker run -it \
               -v "${PWD}:/project" \
               -v ~/.aws:/root/.aws \
               -e "TARGET_ENV=$TARGET_ENV_PARAM" \
               -e "CLUSTER_NAME=$CLUSTER_NAME_PARAM" \
               -e "SERVICE_NAME=$SERVICE_NAME_PARAM" \
               "simplemachines/ansible-template:$DOCKER_TAG" \
               scripts/editvault-services.sh
	;;
    2)
	CLUSTER_NAME_PARAM="${1}"
	TARGET_ENV_PARAM="${2}"
	docker run -it \
               -v "$PWD:/project" \
               -v ~/.aws:/root/.aws \
               -e "TARGET_ENV=$TARGET_ENV_PARAM" \
               -e "CLUSTER_NAME=$CLUSTER_NAME_PARAM" \
               "simplemachines/ansible-template:$DOCKER_TAG" \
               scripts/editvault-infrastructure.sh
	;;
    *) # Display usage along with suggested arguments
	cat <<EOF
ERROR: $0 requires 2 or 3 arguments; $# provided. $USAGE

OPTIONS

    You may want to run one of the following commands:

EOF

    # We'll list environments without a vault file and vault files without an environment file.
	find . -maxdepth 4 -type f -name '*.yml' ! -name 'common.yml' \
	    | egrep '^./([^/]+/services/[^/]+/.*.yml|[^/]+/infrastructure/.*.yml)$' \
	    | sed -Ee "s#^(.*)[.]vault[.]yml\$#\1.yml#" \
	    | sort -u \
	    | sed -Ee "/infrastructure/s#^./([^/]*)/infrastructure/(.*).yml#    $0 \1 \2#" \
	    | sed -Ee "/services/s#^./([^/]*)/services/([^/]*)/(.*).yml\$#    $0 \1 \2 \3#g" \
	    || echo "        ERROR: No clusters or services found"
	exit 1
	;;
esac
