#!/bin/sh

if [ ! $# -eq 3 ]; then
    echo "USAGE: ${0} <config dir> <config file> <gif device>"
    exit 1
fi

# Network settings
v4host="192.168.2.1"
v4client="10.8.0.6"
vpnserver="10.8.0.1"
v6host="2001:470:8142:3::1"
v6client="2001:470:8142:3::2"
v6local="2001:470:8142:5::1"
localdevice="alc0"

configdir=${1}
configfile=${2}
gifdevice=${3}

if [ ! -d ${configdir} ]; then
    echo "[-] Configuration directory does not exist. Exiting."
    exit 1
fi

cd ${configdir}
sudo openvpn ${configfile} > /dev/null 2>&1 &
if [ ! $? -eq 0 ]; then
    echo "[-] OpenVPN failed to start! Exiting."
    exit 1
fi

echo "[+] OpenVPN started in background. Waiting for VPN to come up."
ping -o ${vpnserver} > /dev/null
sleep 10

echo "[+] VPN is up. Adding route to IPv6 tunnel server."

echo "[+] Creating IPv6 tunnel."
sudo ifconfig ${gifdevice} create
if [ ! $? -eq 0 ]; then
    echo "[-] Could not create gif device. Exiting"
    exit 1
fi
sudo ifconfig ${gifdevice} tunnel ${v4client} ${v4host}
if [ ! $? -eq 0 ]; then
    echo "[-] Could not set IPv4 tunnel on gif device. Exiting."
    exit 1
fi
sudo ifconfig ${gifdevice} inet6 ${v6client} ${v6host} prefixlen 128
if [ ! $? -eq 0 ]; then
    echo "[-] Could not set IPv6 tunnel on gif device. Exiting."
    exit 1
fi

sudo route add -inet6 default ${v6host}
if [ ! $? -eq 0 ]; then
    echo "[-] Could not add default IPv6 route. Exiting."
    exit 1
fi

echo "[+] Adding IPv6 address to local network."
sudo ifconfig ${localdevice} ${v6local}
if [ ! $? -eq 0 ]; then
    echo "[-] Could not add IPv6 address to local network. Exiting."
    exit 1
fi

echo "[+] Restarting rtadvd."
sudo /etc/rc.d/rtadvd restart

echo "[+] Tunnel successfully created!"
exit 0
