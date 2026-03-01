#!/bin/bash -xe

function cmd_health() {
    torsocks curl -s https://check.torproject.org/api/ip | grep -q '\"IsTor\":true'
}

function cmd_run() {
    exec /usr/bin/tor -f /etc/tor/torrc
}

_cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
