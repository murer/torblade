#!/bin/bash -xe

function cmd_apply() {
    local IN_IF="enp0s8"
    local SUBNET="192.168.55.0/24"
    local TRANS_PORT="9040"
    local DNS_PORT="5353"

    cmd_drop

    # --- NAT TABLE: REDIRECTION ---
    
    # 1. Redirect DNS (UDP 53) to your Proxy
    iptables -t nat -A PREROUTING -i "$IN_IF" -s "$SUBNET" -p udp --dport 53 -j REDIRECT --to-ports "$DNS_PORT"

    # 2. Redirect HTTPS (TCP 443) to Tor
    iptables -t nat -A PREROUTING -i "$IN_IF" -s "$SUBNET" -p tcp --dport 443 -j REDIRECT --to-ports "$TRANS_PORT"

    # 3. Redirect SSH (TCP 22) to Tor
    iptables -t nat -A PREROUTING -i "$IN_IF" -s "$SUBNET" -p tcp --dport 22 -j REDIRECT --to-ports "$TRANS_PORT"

    # 4. Redirect every TCP to Tor
    # iptables -t nat -A PREROUTING -i "$IN_IF" -s "$SUBNET" -p tcp --syn -j REDIRECT --to-ports "$TRANS_PORT"

    # --- FILTER TABLE: THE KILL SWITCH ---

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
        ipv4.dns ""

    sudo nmcli connection up "Wired connection 2"
}

cd "$(dirname "$0")"; _cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"