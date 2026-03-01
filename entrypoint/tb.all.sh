#!/bin/bash -xe

function cmd_health() {
    /opt/torblade/tb.tor.sh health
    /opt/torblade/tb.dnscrypt.sh health
    /opt/torblade/tb.dhcpd.sh health
}

function cmd_run() {
    /opt/torblade/tb.tor.sh run &
    while ! /opt/torblade/tb.tor.sh health; do sleep 2; done

    /opt/torblade/tb.dnscrypt.sh run &
    while ! /opt/torblade/tb.dnscrypt.sh health; do sleep 2; done

    /opt/torblade/tb.dhcpd.sh run &
    while ! /opt/torblade/tb.dhcpd.sh health; do sleep 2; done

    sleep infinity
}

_cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
