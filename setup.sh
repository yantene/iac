#!/bin/bash

# set variables

read -p "system user name (system): " system_user
[[ -z ${system_user} ]] && system_user=system

read -p "system group name (system): " system_group
[[ -z ${system_group} ]] && system_group=system

read -p "github user name (yantene): " github_user
[[ -z ${github_user} ]] && github_user=yantene

read -p "inet interface name (ens3): " inet_interface
[[ -z ${inet_interface} ]] && inet_interface=ens3

read -p "inet ipv4 address (192.0.2.123): " inet_ipv4_address
[[ -z ${inet_ipv4_address} ]] && inet_ipv4_address="192.0.2.123"

read -p "inet ipv4 netmask (24): " inet_ipv4_netmask
[[ -z ${inet_ipv4_netmask} ]] && inet_ipv4_netmask=24

read -p "inet ipv4 gateway (192.0.2.1): " inet_ipv4_gateway
[[ -z ${inet_ipv4_gateway} ]] && inet_ipv4_gateway="192.0.2.1"

read -p "inet dns nameservers (192.0.2.201 192.0.2.202): " inet_dns_nameservers
[[ -z ${inet_dns_nameservers} ]] && inet_dns_nameservers="192.0.2.201 192.0.2.202"

read -p "inet dns search (example.jp): " inet_dns_search
[[ -z ${inet_dns_search} ]] && inet_dns_search=example.jp

read -p "inet ipv6 address (2001:db8:0:1:12:34:56:78): " inet_ipv6_address
[[ -z ${inet_ipv6_address} ]] && inet_ipv6_address="2001:db8:0:1:12:34:56:78"

read -p "inet ipv6 netmask (64): " inet_ipv6_netmask
[[ -z ${inet_ipv6_netmask} ]] && inet_ipv6_netmask=64

read -p "inet ipv6 gateway (2001:db8:0:1::1): " inet_ipv6_gateway
[[ -z ${inet_ipv6_gateway} ]] && inet_ipv6_gateway="2001:db8:0:1::1"

# install packages

apt install -y sudo git vim curl

# setup system user's authorized_keys

mkdir -m700 /home/${system_user}/.ssh
chown ${system_user}:${system_group} /home/${system_user}/.ssh
curl https://github.com/${github_user}.keys -o /home/${system_user}/.ssh/authorized_keys
chown ${system_user}:${system_group} /home/${system_user}/.ssh/authorized_keys
chmod 600 /home/${system_user}/.ssh/authorized_keys

# setup sudoers

echo -e "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-wheel-nopasswd
/usr/sbin/groupadd wheel
gpasswd -a ${system_user} wheel

# setup sshd config

echo "PasswordAuthentication no" > /etc/ssh/sshd_config.d/99-disable-password-authentication.conf
echo "PermitRootLogin no" > /etc/ssh/sshd_config.d/98-disable-root-login.conf
systemctl reload sshd.service

# setup network interface

mv /etc/network/interfaces /etc/network/interfaces.bak

echo "source /etc/network/interfaces.d/*" > /etc/network/interfaces

echo -e "auto lo\niface lo inet loopback" > /etc/network/interfaces.d/lo

echo "allow-hotplug ${inet_interface}" > /etc/network/interfaces.d/${inet_interface}
echo "iface ${inet_interface} inet static" >> /etc/network/interfaces.d/${inet_interface}
echo "  address ${inet_ipv4_address}/${inet_ipv4_netmask}" >> /etc/network/interfaces.d/${inet_interface}
echo "  gateway ${inet_ipv4_gateway}" >> /etc/network/interfaces.d/${inet_interface}
echo "  dns-nameservers ${inet_dns_nameservers}" >> /etc/network/interfaces.d/${inet_interface}
echo "  dns-search ${inet_dns_search}" >> /etc/network/interfaces.d/${inet_interface}
echo "iface ${inet_interface} inet6 static" >> /etc/network/interfaces.d/${inet_interface}
echo "  address ${inet_ipv6_address}" >> /etc/network/interfaces.d/${inet_interface}
echo "  netmask ${inet_ipv6_netmask}" >> /etc/network/interfaces.d/${inet_interface}
echo "  gateway ${inet_ipv6_gateway}" >> /etc/network/interfaces.d/${inet_interface}
systemctl restart networking.service
