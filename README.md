# Torblade

**Torblade** is a minimalist, transparent Tor proxy gateway. It transforms a Linux VM into a secure bridge that forces all downstream client traffic through the Tor network, preventing leaks by design.

[<img src="https://raw.githubusercontent.com/murer/torblade/refs/heads/master/docs/torblade-lt.jpeg" width="280" />](https://github.com/murer/torblade)

### Core Features

* **Zero-Leak Policy:** Non-Tor packets are strictly blocked at the firewall level.
* **Automatic Networking:** Integrated DHCP server for easy client connectivity.
* **Secure DNS:** DNS over HTTPS (DoH) routed through Tor, including `.onion` resolution.
* **Hardened Traffic:** Default configuration limits traffic to SSH and HTTPS (customizable).

---

## Setup Guide

This setup is tested and optimized for **VirtualBox**.

### 1. Gateway VM (torblade-proxy)

Configure your VM with two Network Adapters:

1. **Adapter 1:** NAT (For internet access)
2. **Adapter 2:** Internal Network (Name it `torblade-net`, disable DHCP in VB settings)

**Initialization:**

```bash
# Set up host IP and network interfaces
./iptables.sh fix_my_ip

# Spin up the Tor and DNS containers
./docker.sh start

# Apply the transparent proxy and firewall rules
sudo ./iptables.sh apply

```

### 2. Client VM (torblade-clients)

Configure your client VM (Kali, Tails, or any Linux/Windows) with:

1. **Adapter 1:** Internal Network (Use the same name: `torblade-net`)

The client will automatically receive an IP via DHCP and route all traffic through the Torblade gateway.

---

## Customization

By default, Torblade only allows **SSH** and **HTTPS** traffic for maximum security. If you need to allow all protocols through the Tor circuit:

* Open `iptables.sh`.
* Uncomment the rule explicitly marked to allow all traffic over Tor.

---

## Verification

Once connected, use these links within the **Client VM** to verify your anonymity:

| Service | Purpose |
| --- | --- |
| [Check Tor IP](https://check.torproject.org/api/ip) | Confirms you are routing through the Tor network. |
| [Cloudflare Help](https://one.one.one.one/help/) | Verify that DNS is not leaking and is using DoH. |
| [CIA.onion](https://www.google.com/search?q=http://ciadotgov4sjwlzihbbgxnqg3xiyrg7so2r2o3lt5wz5ypk4sxyjstad.onion/) | Test `.onion` address resolution. |

---

> **Note:** This project aims for simplicity. You can understand the entire logic in under 10 minutes by reading the shell scripts.

---