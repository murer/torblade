FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y tor dnscrypt-proxy curl torsocks dnsutils nmap isc-dhcp-server iptables net-tools vim


RUN echo "onion 127.0.0.1:9053" > /etc/dnscrypt-proxy/forwarding-rules.txt

RUN sed -i "s/listen_addresses =.*/listen_addresses = \['0.0.0.0:5353'\]/g" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
RUN sed -i "s/server_names = \['cloudflare'\]/server_names = \['google', 'cloudflare'\]/g" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
RUN sed -i "1iproxy = 'socks5://127.0.0.1:9050'" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
# RUN sed -i "1iforce_tcp = true" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
RUN sed -i "1iforwarding_rules = '/etc/dnscrypt-proxy/forwarding-rules.txt'" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

RUN echo "DNSPort 9053" >> /etc/tor/torrc
RUN echo "SocksPort 0.0.0.0:9050" >> /etc/tor/torrc
RUN echo "TransPort 0.0.0.0:9040" >> /etc/tor/torrc
RUN echo "AutomapHostsOnResolve 1" >> /etc/tor/torrc
RUN echo "VirtualAddrNetworkIPv4 10.192.0.0/10" >> /etc/tor/torrc

RUN sed -i 's/INTERFACESv4=""/INTERFACESv4="enp0s8"/' /etc/default/isc-dhcp-server
RUN echo "authoritative;" > /etc/dhcp/dhcpd.conf
RUN echo "default-lease-time 86400;" >> /etc/dhcp/dhcpd.conf
RUN echo "max-lease-time 86400;" >> /etc/dhcp/dhcpd.conf
RUN echo "" >> /etc/dhcp/dhcpd.conf
RUN echo "subnet 192.168.55.0 netmask 255.255.255.0 {" >> /etc/dhcp/dhcpd.conf
RUN echo "    range 192.168.55.100 192.168.55.200;" >> /etc/dhcp/dhcpd.conf
RUN echo "    option routers 192.168.55.10;" >> /etc/dhcp/dhcpd.conf
RUN echo "    option broadcast-address 192.168.55.255;" >> /etc/dhcp/dhcpd.conf
RUN echo "    option domain-name-servers 192.168.55.10;" >> /etc/dhcp/dhcpd.conf
RUN echo "}" >> /etc/dhcp/dhcpd.conf

RUN touch /var/lib/dhcp/dhcpd.leases

COPY entrypoint /opt/torblade
COPY iptables.sh /opt/torblade/iptables.sh
RUN chmod +x /opt/torblade/*.sh

CMD ["/opt/torblade/start.sh"]

HEALTHCHECK --interval=5s --timeout=5s --retries=120 --start-period=5s CMD /opt/torblade/health.sh all
