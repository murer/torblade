#!/bin/bash -xe

function cmd_health() {
    sleep 2
}

function cmd_run() {
    exec sleep 600
}

_cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
