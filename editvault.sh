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
    0)
	# Discover clusters, services, environments
	DISCOVERED=$(find . -type f -name '*.yml' ! -name 'common.yml' | ( grep /services/ || true ) | cut -d/ -f2,4,5)
	OPTIONS_CLUSTER=$(echo "$DISCOVERED" | cut -d/ -f1 | sort -u | tr "\n" "," | sed -Ee 's/,$//;s/,/, /g')
	OPTIONS_SERVICE=$(echo "$DISCOVERED" | cut -d/ -f2 | sort -u | tr "\n" ","| sed -Ee 's/,$//;s/,/, /g')
	OPTIONS_ENV=$(echo "$DISCOVERED" | cut -d/ -f3 | cut -d. -f1 | sort -u | tr "\n" ","| sed -Ee 's/,$//;s/,/, /g')
	echo "$USAGE"
	cat <<EOF

OPTIONS

    Clusters:
        ${OPTIONS_CLUSTER:-"NONE"}

    Services:
        ${OPTIONS_SERVICE:-"NONE"}

    Environments:
        ${OPTIONS_ENV:-"NONE"}
EOF

	;;
    *)
	echo "Error: $0 requires 2 or 3 options. $USAGE"
	exit 1
	;;
esac
