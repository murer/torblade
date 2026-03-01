#!/bin/bash -xe

if [ -z "$TORBLADE_SERVICE" ]; then
    echo 'TORBLADE_SERVICE is required'
    false
else

    function _check() {
        echo "fail" > /var/torblade/health.last
        exec /opt/torblade/tb.$TORBLADE_SERVICE.sh health
        echo "success" > /var/torblade/health.last
    }

    mkdir -p /var/torblade
    [ ! -f /var/torblade/health.created ] && touch /var/torblade/health.created
    [ ! -f /var/torblade/health.last ] && touch /var/torblade/health.last

    if find /var/torblade/health.created -mmin -2 | grep '.\+'; then
        _check
    elif find /var/torblade/health.last -mmin +5 | grep '.\+'; then
        _check
    fi
    grep success /var/torblade/health.last
    
fi
