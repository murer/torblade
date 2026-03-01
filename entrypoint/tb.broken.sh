#!/bin/bash -xe

function cmd_health() {
    false broken
}

function cmd_run() {
    sleep 600
}

_cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
