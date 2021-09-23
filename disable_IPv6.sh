#!/bin/sh

##########################################
#
# Script made by Geds3169
#
# 28/10/2020
#
# Disable IPv6 definitively
#
# Work in Debian 10.2.0
#
##########################################

echo "test the actual IP settings to see if IPv6 is enabled"
ip a

sleep 0.5

echo "\n======================\n"

echo "Disabling IPv6"
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.all.autoconf=0
sysctl -w net.ipv6.conf.default.disable_ipv6=0
sysctl -w net.ipv6.conf.default.autoconf=0

echo "\n======================\n"

sleep 0.2

echo " writing configuration to disable ipv6 in /etc/sysctl.conf"

echo '# désactivation de ipv6 pour toutes les interfaces
net.ipv6.conf.all.disable_ipv6 = 1

# désactivation de l’auto configuration pour toutes les interfaces
net.ipv6.conf.all.autoconf = 0

# désactivation de ipv6 pour les nouvelles interfaces (ex:si ajout de carte réseau)
net.ipv6.conf.default.disable_ipv6 = 1

# désactivation de l’auto configuration pour les nouvelles interfaces
net.ipv6.conf.default.autoconf = 0' >> /etc/sysctl.conf

echo "\n======================\n"

sleep 0.2

echo "restart networking service"
systemctl restart networking.service

echo "\n======================\n"

sleep 0.2

STATUS="$(systemctl is-active networking.service)"
if [ "${STATUS}" = "active" ]; then
	echo "networking service work well and this is new configuration :"
	ip a
else
	echo "networking service doesn't work"
	ifup --all
	ip a
fi

sleep 0.2

echo "\n====THE END =======\n"
exit 0
