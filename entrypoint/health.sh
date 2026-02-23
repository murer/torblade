#!/bin/bash -xe

function cmd_tor() {
    torsocks curl -s https://check.torproject.org/api/ip | grep -q '\"IsTor\":true'
}

function cmd_doh() {
    dig @127.0.0.1 -p 5353 example.com # > /dev/null
}

function cmd_wait_tor() {
    while ! cmd_tor; do
        sleep 10
    done
}

function cmd_wait_doh() {
    while ! cmd_doh; do
        sleep 10
    done
}

function cmd_all() {
    cmd_tor
    cmd_doh
}

cd "$(dirname "$0")"; _cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"