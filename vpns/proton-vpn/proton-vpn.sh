#!/bin/bash -xe

function cmd_install_protonvpn() {
    mkdir -p /etc/apt/hardkeys
    wget -q -O - https://repo.protonvpn.com/debian/public_key.asc | gpg --dearmor > /etc/apt/hardkeys/protonvpn-stable-archive-keyring.gpg
    echo "deb [signed-by=/etc/apt/hardkeys/protonvpn-stable-archive-keyring.gpg] https://repo.protonvpn.com/debian stable main" > /etc/apt/sources.list.d/proton-vpn.list
    apt update
    apt -y install proton-vpn-gtk-app

    if [[ "x$hexblade_user" != "x" ]]; then
        usermod -aG netdev "$hexblade_user"
    elif [[ "x$UID" == "x0" && "x$SUDO_USER" != "x" && "x$SUDO_UID" != "x0" ]]; then
        usermod -aG netdev "$SUDO_USER"
    elif [[ "x$UID" != "x0" ]]; then
        usermod -aG netdev "$USER"
    fi
}

function cmd_install_dhpcd() {
    apt install -y curl dnsutils nmap isc-dhcp-server iptables net-tools vim
    cp dhcpd.conf /etc/dhcp/dhcpd.conf
    cp isc-dhcp-server /etc/default/isc-dhcp-server
}

function cmd_install_ips() {
    sudo nmcli connection modify "Wired connection 2" \
        ipv4.addresses 192.168.60.10/24 \
        ipv4.method manual \
        ipv4.gateway "" \
        ipv4.dns "" \
        ipv6.addresses "" \
        ipv6.dns "" \
        ipv6.method disabled

    sudo nmcli connection up "Wired connection 2"
}

function cmd_iptables_apply() {
    # 1. Cria as cadeias customizadas (uma para NAT, outra para os filtros de FORWARD)
    sudo iptables -t nat -N VPN_GATEWAY_NAT
    sudo iptables -N VPN_GATEWAY_FWD

    # 2. Adiciona suas regras específicas DENTRO dessas novas cadeias
    sudo iptables -t nat -A VPN_GATEWAY_NAT -s 192.168.60.0/24 -o proton0 -j MASQUERADE
    sudo iptables -A VPN_GATEWAY_FWD -i enp0s8 -o proton0 -j ACCEPT
    sudo iptables -A VPN_GATEWAY_FWD -i proton0 -o enp0s8 -m state --state RELATED,ESTABLISHED -j ACCEPT

    # 3. "Pluga" as cadeias no topo do roteamento do sistema
    sudo iptables -t nat -I POSTROUTING 1 -j VPN_GATEWAY_NAT
    sudo iptables -I FORWARD 1 -j VPN_GATEWAY_FWD

    # iptables -t nat -I POSTROUTING -s 192.168.60.0/24 -o proton0 -j MASQUERADE
    # iptables -I FORWARD -i enp0s8 -o proton0 -j ACCEPT
    # iptables -I FORWARD -i proton0 -o enp0s8 -m state --state RELATED,ESTABLISHED -j ACCEPT
}

function cmd_iptables_drop() {
    # 1. "Despluga" suas cadeias do sistema principal
    sudo iptables -t nat -D POSTROUTING -j VPN_GATEWAY_NAT
    sudo iptables -D FORWARD -j VPN_GATEWAY_FWD

    # 2. Limpa (Flush) todas as regras de dentro das suas cadeias
    sudo iptables -t nat -F VPN_GATEWAY_NAT
    sudo iptables -F VPN_GATEWAY_FWD

    # 3. Deleta as cadeias vazias
    sudo iptables -t nat -X VPN_GATEWAY_NAT
    sudo iptables -X VPN_GATEWAY_FWD

    # iptables -F
    # iptables -t nat -F
    # iptables -X
    # iptables -P FORWARD ACCEPT
    # iptables -P INPUT ACCEPT
}

function cmd_install_all() {
    cmd_install_ips
    cmd_install_dhpcd
    cmd_install_protonvpn
}

function cmd_start() {
    [ "x$UID" != "x0" ]
    sudo service isc-dhcp-server restart
    cmd_iptables_drop || true
    cmd_iptables_apply
    protonvpn-app
}

cd "$(dirname "$0")"; _cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
