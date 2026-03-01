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
    true
}

function cmd_install_all() {
    cmd_install_protonvpn
    cmd_install_dhpcd
}

cd "$(dirname "$0")"; _cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
