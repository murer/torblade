#!/bin/bash -xe

if [ -z "$TORBLADE_SERVICE" ]; then
    echo 'TORBLADE_SERVICE is required'
    false
else
    exec /opt/torblade/tb.$TORBLADE_SERVICE.sh run
fi

# /usr/bin/tor -f /etc/tor/torrc &
# timeout 60s /opt/torblade/health.sh wait_tor

# /usr/sbin/dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml &
# /opt/torblade/health.sh wait_doh

# /usr/sbin/dhcpd -d -f -4 -pf /var/run/dhcpd.pid enp0s8 &

# wait %1

