FROM alpine:3.3
MAINTAINER Hardware <contact@meshup.net>

ENV GID=991 UID=991 VERSION=2.93 DBHOST=mariadb DBUSER=postfix DBNAME=postfix

RUN apk -U add nginx php-fpm php-imap php-mysql php-mysqli dovecot supervisor \
  && rm -f /var/cache/apk/*

RUN wget http://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-$VERSION/postfixadmin-$VERSION.tar.gz -P /tmp \
  && mkdir /postfixadmin && tar -xzf /tmp/postfixadmin-$VERSION.tar.gz -C /postfixadmin && mv /postfixadmin/postfixadmin-$VERSION/* /postfixadmin \
  && rm -rf /tmp/* /postfixadmin/postfixadmin-$VERSION.tar.gz

COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /etc/php/php-fpm.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY startup /usr/local/bin/startup

RUN chmod +x /usr/local/bin/startup

VOLUME /postfixadmin
EXPOSE 80

CMD ["/usr/local/bin/startup"]