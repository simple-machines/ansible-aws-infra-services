#!/bin/bash
alias watch='watch '
alias dps='docker ps'

function dl { docker ps -lq; }
function dlr { docker ps -lq -f "status=running"; }
function dlog { x="$(dl)"; if [ -z "$x" ]; then echo "No containers running."; else docker logs "$@" $x; fi ;}
alias dlogf='dlog -f'
alias dlogt='dlog -t'

# Show docker logs for a container that matches the provided pattern.
# The pattern match happens on the 'docker ps' command output, so you can search for
# container id, image name, status, etc.
# Examples:
#       $ dlogp topics  # logs for a container that has 'topics' in it's image name
#       $ dlogp kafka   # logs for a container that has 'kafka' in it's image name
#       $ dlogp 8082    # logs for a container that has '8082' in it's ports field
function dlogp {
  if [[ "$#" -eq "0" ]]; then
    echo "Usage: dlogp <pattern - containerid, image name, etc.>"
    return 1
  fi

  read -r -a CONTAINERS <<< $(docker ps | grep $1 | awk '{print $1}')
  # we have to count it this way otherwise the file can't go in cloud-init
  N_CONTAINERS=$(docker ps | grep $1 | awk '{print $1}' | wc -l )
  if [[ "$N_CONTAINERS" -eq "1" ]]; then
    # Found one container matching $1
    shift
    docker logs "$@" ${CONTAINERS[0]}
  elif [[ "$N_CONTAINERS" -eq "0" ]]; then
    echo "No container matching $1"
  else
    echo "$N_CONTAINERS containers matching $1"
    docker ps | grep "$1"
  fi
}

# Similar to dlogp but the logs are followed (docker logs -f)
#
# Example:
#   $ dlogfp topics         # follow logs for a container that has 'topics' in it's image name
function dlogfp {
  dlogp $1 -f;
}

# Similar to dlogp but the logs are tailed (docker logs -t)
#
# Example:
#   $ dlogtp topics         # tail logs for a container that has 'topics' in it's image name
function dlogtp {
  dlogp $1 -f;
}

function dex { x="$(dlr)"; if [ -z "$x" ]; then echo "Container not running."; else docker exec -it $x "$@"; fi ;}
function dattach { x="$(dl)"; if [ -z "$x" ]; then echo "Container not running."; else docker attach --no-stdin --sig-proxy=false $x "$@"; fi ;}
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
function dstop { x="$(dlr)"; if [ -z "$x" ]; then echo "Container not running."; else time docker stop "$@" $x; fi ;}
