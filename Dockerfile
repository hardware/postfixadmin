FROM alpine:3.3
MAINTAINER Hardware <contact@meshup.net>

ARG VERSION=2.93

ARG GPG_Goodwin="2D83 3163 D69B B8F6 BFEF  179D 4ECC 3566 EB7E B945"

ENV GID=991 \
    UID=991 \
    DBHOST=mariadb \
    DBUSER=postfix \
    DBNAME=postfix

RUN echo "@commuedge http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
 && echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
 && BUILD_DEPS=" \
    ca-certificates \
    gnupg" \
 && apk -U add \
    ${BUILD_DEPS} \
    nginx \
    php7-fpm@testing \
    php7-imap@testing \
    php7-mysqli@testing \
    php7-session@testing \
    php7-mbstring@testing \
    dovecot \
    supervisor \
    tini@commuedge \
 && cd /tmp \
 && PFA_TARBALL="postfixadmin-${VERSION}.tar.gz" \
 && wget -q https://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-${VERSION}/${PFA_TARBALL} \
 && echo "Verifying ${PFA_TARBALL} using GPG..." \
 && wget -q https://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-${VERSION}/${PFA_TARBALL}.asc \
 && gpg --keyserver keys.gnupg.net --recv-keys 0xEB7EB945 \
 && FINGERPRINT="$(LANG=C gpg --verify ${PFA_TARBALL}.asc ${PFA_TARBALL} 2>&1 \
  | sed -n "s#Primary key fingerprint: \(.*\)#\1#p")" \
 && if [ -z "${FINGERPRINT}" ]; then echo "Warning! Invalid GPG signature!" && exit 1; fi \
 && if [ "${FINGERPRINT}" != "${GPG_Goodwin}" ]; then echo "Warning! Wrong GPG fingerprint!" && exit 1; fi \
 && echo "All seems good, now unpacking ${PFA_TARBALL}..." \
 && mkdir /postfixadmin && tar xzf ${PFA_TARBALL} -C /postfixadmin && mv /postfixadmin/postfixadmin-$VERSION/* /postfixadmin \
 && apk del ${BUILD_DEPS} \
 && rm -rf /var/cache/apk/* /tmp/* /postfixadmin/postfixadmin-$VERSION*

COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /etc/php7/php-fpm.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY setup /usr/local/bin/setup
COPY startup /usr/local/bin/startup

RUN chmod +x /usr/local/bin/startup /usr/local/bin/setup

EXPOSE 80

CMD ["/sbin/tini","--","startup"]
