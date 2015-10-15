#!/usr/bin/env bash

set -e

RADIUS_ADDR=radius.toughstruct.com
RADIUS_SECRET=testing123
RADIUS_AUTH_PORT=1812
RADIUS_ACCT_PORT=1813

sudo apt-get update -y
sudo apt-get install -y pptpd iptables libfreeradius-client2 libfreeradius-client-dev supervisor

# setup pptp

sudo cat pptp/pptpd.conf > /etc/pptpd.conf
sudo cat pptp/ppp/pptpd-options > /etc/ppp/pptpd-options

# setup freeradius-client

sudo cat radius/radiusclient.conf > /etc/radiusclient/radiusclient.conf
sudo cat radius/servers > /etc/radiusclient/servers
sudo cat radius/dictionary/dictionary.microsoft >  /etc/radiusclient/dictionary.microsoft
sudo cat radius/dictionary/dictionary.pppd > /etc/radiusclient/dictionary.pppd
sudo cat radius/dictionary/dictionary > /etc/radiusclient/dictionary


# start logging
service rsyslog start

sed -i "s/RADIUS_ADDR RADIUS_SECRET/$RADIUS_ADDR $RADIUS_SECRET/g" /etc/radiusclient/servers
sed -i "s/RADIUS_ADDR:RADIUS_AUTH_PORT/$RADIUS_ADDR:$RADIUS_AUTH_PORT/g" /etc/radiusclient/radiusclient.conf
sed -i "s/RADIUS_ADDR:RADIUS_ACCT_PORT/$RADIUS_ADDR:$RADIUS_ACCT_PORT/g" /etc/radiusclient/radiusclient.conf
echo "" > /etc/radiusclient/port-id-map

# enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# configure firewall
iptables -t nat -A POSTROUTING -s 10.79.97.0/24 -o eth0 -j MASQUERADE
iptables -A FORWARD -s 10.79.97.0/24 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1356


exec "$@"