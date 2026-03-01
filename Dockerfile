FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y tor dnscrypt-proxy curl torsocks dnsutils nmap isc-dhcp-server iptables net-tools vim

COPY config/dnscrypt-proxy /etc/dnscrypt-proxy
COPY config/tor/torrc /etc/tor/torrc

COPY config/dhcpd/isc-dhcp-server /etc/default/isc-dhcp-server
COPY config/dhcpd/dhcpd.conf /etc/dhcp/dhcpd.conf

RUN touch /var/lib/dhcp/dhcpd.leases

COPY entrypoint /opt/torblade
COPY iptables.sh /opt/torblade/iptables.sh
RUN chmod +x /opt/torblade/*.sh

CMD ["/opt/torblade/start.sh"]

HEALTHCHECK --start-interval=3s --interval=60s --timeout=3s --retries=2 --start-period=5s CMD /opt/torblade/health.sh
