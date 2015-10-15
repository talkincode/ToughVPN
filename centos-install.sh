#!/usr/bin/env bash

set -e

RADIUS_ADDR=radius.toughstruct.com
RADIUS_SECRET=testing123
RADIUS_AUTH_PORT=1812
RADIUS_ACCT_PORT=1813

yum update -y
yum install -y pptpd iptables gcc make


cd /usr/local/src &&\
  wget ftp://ftp.freeradius.org/pub/freeradius/freeradius-client-1.1.7.tar.gz && \
  tar xzvf freeradius-client-1.1.7.tar.gz && \
  cd  /usr/local/src/freeradius-client-1.1.7 && \
  ./configure --prefix=/usr/local && \
  make && make install

# setup pptp

cat pptp/pptpd.conf > /etc/pptpd.conf
cat pptp/ppp/pptpd-options > /etc/ppp/pptpd-options

# setup freeradius-client

cat radius/radiusclient.conf > /etc/radiusclient/radiusclient.conf
cat radius/servers > /etc/radiusclient/servers
cat radius/dictionary/dictionary.microsoft >  /etc/radiusclient/dictionary.microsoft
cat radius/dictionary/dictionary.pppd > /etc/radiusclient/dictionary.pppd
cat radius/dictionary/dictionary > /etc/radiusclient/dictionary


# start logging
service rsyslog start

sed -i "s/RADIUS_ADDR RADIUS_SECRET/$RADIUS_ADDR $RADIUS_SECRET/g" /etc/radiusclient/servers
sed -i "s/RADIUS_ADDR:RADIUS_AUTH_PORT/$RADIUS_ADDR:$RADIUS_AUTH_PORT/g" /etc/radiusclient/radiusclient.conf
sed -i "s/RADIUS_ADDR:RADIUS_ACCT_PORT/$RADIUS_ADDR:$RADIUS_ACCT_PORT/g" /etc/radiusclient/radiusclient.conf
#echo "" > /etc/radiusclient/port-id-map

# enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# configure firewall
iptables -t nat -A POSTROUTING -s 10.79.97.0/24 -o eth0 -j MASQUERADE
iptables -A FORWARD -s 10.79.97.0/24 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1356
iptables save

exec "$@"