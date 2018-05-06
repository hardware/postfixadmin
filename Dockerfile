FROM alpine:3.7

LABEL description "PostfixAdmin is a web based interface used to manage mailboxes" \
      maintainer="Hardware <contact@meshup.net>"

RUN echo "@community https://nl.alpinelinux.org/alpine/v3.7/community" >> /etc/apk/repositories \
 && apk -U upgrade \
 && apk add -t build-dependencies \
    ca-certificates \
    git \
 && apk add \
    nginx \
    s6 \
    su-exec \
    dovecot \
    php7-phar \
    php7-fpm@community \
    php7-imap@community \
    php7-pgsql@community \
    php7-mysqli@community \
    php7-session@community \
    php7-mbstring@community \
 && git clone -b bootstrap --single-branch --depth 1 https://github.com/abonanni/postfixadmin /postfixadmin \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/*

COPY rootfs /
RUN chmod +x /usr/local/bin/run.sh /services/*/run /services/.s6-svscan/*
EXPOSE 8888
CMD ["run.sh"]
