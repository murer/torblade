#!/bin/bash -xe

function cmd_health() {
    date >> /tmp/x
    dig @127.0.0.1 -p 5300 example.com # > /dev/null
    echo after >> /tmp/x
}

function cmd_run() {
    /usr/sbin/dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml
}

_cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
