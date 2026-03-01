#!/bin/bash -xe


if [ -z "$TORBLADE_SERVICE" ]; then
    echo 'TORBLADE_SERVICE is required'
    false
else
    exec /opt/torblade/tb.$TORBLADE_SERVICE.sh health
fi
