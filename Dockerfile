FROM ubuntu:latest
MAINTAINER jamiesun <jamiesun.net@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y
RUN apt-get install -y pptpd iptables libfreeradius-client2 libfreeradius-client-dev supervisor
RUN apt-get clean all

#RUN cd /usr/local/src &&\
#  wget ftp://ftp.freeradius.org/pub/freeradius/freeradius-client-1.1.7.tar.gz && \
#  tar xzvf freeradius-client-1.1.7.tar.gz && \
#  cd  /usr/local/src/freeradius-client-1.1.7 && \
#  ./configure --prefix=/usr/local && \
#  make && make install

# setup pptp

COPY pptp/pptpd.conf /etc/pptpd.conf
COPY pptp/ppp/pptpd-options /etc/ppp/pptpd-options

# setup freeradius-client

COPY radius/radiusclient.conf /usr/local/etc/radiusclient/radiusclient.conf
COPY radius/servers /usr/local/etc/radiusclient/servers
COPY radius/dictionary/dictionary.microsoft /usr/local/etc/radiusclient/dictionary.microsoft
COPY radius/dictionary/dictionary /usr/local/etc/radiusclient/dictionary

COPY supervisord.conf /etc/supervisord.conf


EXPOSE  1723

COPY entrypoint.sh /entrypoint.sh
RUN chmod 0700 /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-n","-c","/etc/supervisord.conf"]
