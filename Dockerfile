FROM centos:centos7
MAINTAINER jamiesun <jamiesun.net@gmail.com>


RUN yum update -y
RUN yum install -y pptpd iptables
RUN yum install -y libffi-devel openssl openssl-devel git gcc  python-devel python-setuptools crontabs
RUN yum install -y  mysql-devel MySQL-python
RUN yum clean all

RUN cd /usr/local/src &&\
  wget ftp://ftp.freeradius.org/pub/freeradius/freeradius-client-1.1.7.tar.gz &&\
  tar xzvf freeradius-client-1.1.7.tar.gz && \
  cd  freeradius-client-1.1.7 && \
  make && make install

# setup pptp

COPY ./pptp/pptpd.conf /etc/pptpd.conf
COPY ./pptp/ppp/pptpd-options /etc/ppp/pptpd-options

# setup freeradius-client

COPY ./pptp/radiusclient/radiusclient.conf /usr/local/etc/radiusclient/radiusclient.conf
COPY ./pptp/radiusclient/servers /usr/local/etc/radiusclient/servers
COPY ./pptp/radiusclient/dictionary/dictionary.microsoft /usr/local/etc/radiusclient/dictionary.microsoft
COPY ./pptp/radiusclient/dictionary/dictionary /usr/local/etc/radiusclient/dictionary


COPY entrypoint.sh /entrypoint.sh
RUN chmod 0700 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["pptpd", "--fg"]
