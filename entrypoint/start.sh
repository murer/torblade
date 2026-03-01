#!/bin/bash -xe

[ -z "$TORBLADE_SERVICE" ] || exec /opt/torblade/start.$TORBLADE_SERVICE.sh run


# /usr/bin/tor -f /etc/tor/torrc &
# timeout 60s /opt/torblade/health.sh wait_tor

# /usr/sbin/dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml &
# /opt/torblade/health.sh wait_doh

# /usr/sbin/dhcpd -d -f -4 -pf /var/run/dhcpd.pid enp0s8 &

# wait %1

