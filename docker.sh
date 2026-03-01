#!/bin/bash -xe

function cmd_clean() {
  docker ps -aq --filter label=torbladedev | xargs docker rm -f || true
  docker system prune --volumes --filter label=torbladedev -f || true
}

function cmd_build() {
  docker build -t torblade/torblade:dev .
}

function cmd_run() {
  _is_tty="-t"
  [ -t 0 ] || _is_tty=""
  docker run \
    --rm -i $_is_tty \
    -e "TORBLADE_SERVICE=$TORBLADE_SERVICE" \
    --label torbladedev \
    torblade/torblade:dev "$@"
}

function cmd_healthcheck() {
  set +x
  local _since_date="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local i=""
  local _status=""
  # for i in $(seq 1 30); do
  while [ 1 ]; do
    _status="$(docker inspect --format='{{.State.Health.Status}}' torbladedev_server)"
    if [ "x$_status" != "xstarting" ]; then break; fi
    # if [ "x$_status" == "xhealthy" ] || [ "x$_status" == "xunhealthy" ]; then break; fi
    docker logs --since "$_since_date" torbladedev_server || true
    _since_date="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    sleep 1
  done
  set -x
  [ "x$_status" == "xhealthy" ]
}

function cmd_exec() {
  _is_tty="-t"
  [ -t 0 ] || _is_tty=""
  docker exec -i $_is_tty torbladedev_server "$@"
}

function cmd_start() {
  cmd_clean
  cmd_build
  docker run -d --name torbladedev_server \
    --label torbladedev \
    --network host \
    --cap-add CAP_NET_ADMIN \
    torblade/torblade:dev
  cmd_healthcheck
}

function cmd_start_retry() {
  while ! cmd_start; do
    sleep 1
  done
}

function cmd_stop() {
  docker rm -f torbladedev_server || true
}

function cmd_test() {
  docker exec torbladedev_server torsocks curl https://check.torproject.org/api/ip | grep -q '"IsTor":true'
  docker exec torbladedev_server curl --proxy socks5h://localhost:9050 https://raw.githubusercontent.com/murer/torblade/refs/heads/master/README.md -o /dev/null
  docker exec torbladedev_server curl --proxy socks5://localhost:9050 --header "Host: raw.githubusercontent.com" https://185.199.111.133/murer/torblade/refs/heads/master/README.md -o /dev/null -k
  docker exec torbladedev_server curl --dns-servers 127.0.0.1:53 --proxy socks5://localhost:9050 https://example.com/ -o /dev/null

  echo SUCCESS
}

function cmd_start_and_test() {
  cmd_start
  cmd_test
  cmd_stop
}

function cmd_release() {
  local _tag="${1?'tag is required. Sample: latest'}"
  docker tag torblade/torblade:dev "torblade/torblade:$_tag"
  docker push "torblade/torblade:$_tag"

}

cd "$(dirname "$0")"; _cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
