#!/bin/bash -xe

mkdir -p /var/torblade

if [ -z "$TORBLADE_SERVICE" ]; then
    echo 'TORBLADE_SERVICE is required'
    false
else
    if [ ! -f /var/torblade/health.last ] || find /var/torblade/health.last -mmin +1 | grep '.\+'; then
        echo "fail" > /var/torblade/health.last
        exec /opt/torblade/tb.$TORBLADE_SERVICE.sh health
        echo "success" > /var/torblade/health.last
    fi
    grep success /var/torblade/health.last
fi
