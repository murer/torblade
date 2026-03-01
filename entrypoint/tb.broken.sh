#!/bin/bash -xe

function cmd_health() {
    sleep 2
    false broken
}

function cmd_run() {
    sleep 600
}

_cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
