alias watch='watch '
alias dps='docker ps'
function dl { (docker ps | fgrep 'aws.com/kafka:' | awk '{print $1}'; docker ps -l -q) | head -1;}
function dlog { x="$(dl)"; if [ -z "$x" ]; then echo "Container not running."; else docker logs "$@" $x; fi ;}
alias dlogf='dlog -f'
alias dlogt='dlog -t'
function dex { x="$(dl)"; if [ -z "$x" ]; then echo "Container not running."; else docker exec -it $x "$@"; fi ;}
function dattach { x="$(dl)"; if [ -z "$x" ]; then echo "Container not running."; else docker attach --no-stdin --sig-proxy=false $x "$@"; fi ;}
