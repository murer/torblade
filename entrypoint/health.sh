#!/bin/bash -xe


if [ -z "$TORBLADE_SERVICE" ]; then
    echo 'TORBLADE_SERVICE is required'
    false
else
    exec /opt/torblade/health.$TORBLADE_SERVICE.sh run
fi
