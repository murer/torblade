#!/bin/bash -xe

IN_IF="enp0s8"
SUBNET="192.168.55.0/24"
TRANS_PORT="9040"
DNS_PORT="5300"

function cmd_open_tcp_port4() {
    local _port="${1?'_port'}"
    [ ! -z "$_port" ]
    iptables -t nat -A PREROUTING -i "$IN_IF" -s "$SUBNET" -p tcp --dport "$_port" -j REDIRECT --to-ports "$TRANS_PORT"
}

function cmd_open_udp_port4() {
    local _port="${1?'_port'}"
    [ ! -z "$_port" ]
    iptables -t nat -A PREROUTING -i "$IN_IF" -s "$SUBNET" -p udp --dport 53 -j REDIRECT --to-ports "$DNS_PORT"
}

function cmd_open_all4() {
    iptables -t nat -A PREROUTING -i "$IN_IF" -s "$SUBNET" -p tcp --syn -j REDIRECT --to-ports "$TRANS_PORT"
}

function cmd_kill_switch() {
    # Allow established connections (so the proxy can talk back to the client)
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

    # Allow local DNS traffic to the gateway (necessary for the redirect to work)
    iptables -A INPUT -i "$IN_IF" -p udp --dport "$DNS_PORT" -j ACCEPT

    # Explicitly REJECT all other TCP with a RESET (RST)
    # This prevents the client from hanging/waiting for timeouts
    iptables -A FORWARD -i "$IN_IF" -s "$SUBNET" -p tcp -j REJECT --reject-with tcp-reset

    # REJECT everything else (UDP, ICMP, etc.) with ICMP port unreachable
    iptables -A FORWARD -i "$IN_IF" -s "$SUBNET" -j REJECT

    # REJECT all IPv6 traffic from the client interface to prevent leaks
    ip6tables -A FORWARD -i "$IN_IF" -j REJECT

    # Add a final DROP to be absolutely sure nothing else gets through
    iptables -A FORWARD -i "$IN_IF" -j DROP
    ip6tables -A FORWARD -i "$IN_IF" -j DROP
}

function cmd_apply() {

    cmd_drop

    # --- NAT TABLE: REDIRECTION ---
    
    # 1. Redirect DNS (UDP 53) to your Proxy
    cmd_open_udp_port4 53    

    # 2. Redirect HTTPS (TCP 443) to Tor
    cmd_open_tcp_port4 443

    # 4. Redirect SSH (TCP 22) to Tor
    cmd_open_tcp_port4 22

    # 3. Redirect IRC to Tor
    # cmd_open_tcp_port4 6667
    # cmd_open_tcp_port4 6697

    # 5. Redirect HTTP (TCP 80) to Tor
    # cmd_open_tcp_port4 80

    # 5. Redirect every TCP to Tor
    # cmd_open_all4

    # --- FILTER TABLE: THE KILL SWITCH ---
    cmd_kill_switch
}

function cmd_drop() {
    iptables -F
    iptables -t nat -F
    iptables -X
    iptables -P FORWARD ACCEPT
    iptables -P INPUT ACCEPT
    echo "iptables rules flushed."
}

function cmd_fix_my_ip() {

    sudo nmcli connection modify "Wired connection 2" \
        ipv4.addresses 192.168.55.10/24 \
        ipv4.method manual \
        ipv4.gateway "" \
        ipv4.dns "" \
        ipv6.addresses "" \
        ipv6.dns "" \
        ipv6.method disabled
        

    sudo nmcli connection up "Wired connection 2"
}

cd "$(dirname "$0")"; _cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
