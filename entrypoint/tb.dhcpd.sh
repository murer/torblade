#!/bin/bash -xe

function cmd_health() {
    true
}

function cmd_run() {
    exec /usr/sbin/dhcpd -d -f -4 -pf /var/run/dhcpd.pid enp0s8
}

_cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
