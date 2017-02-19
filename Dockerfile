FROM alpine:3.5
MAINTAINER Hardware <contact@meshup.net>

ARG VERSION=3.0.2

# https://pgp.mit.edu/pks/lookup?search=0xEB7EB945&fingerprint=on&op=index
# pub  4096R/EB7EB945 2012-01-25 David Goodwin (PalePurple) <david@palepurple.co.uk>
ARG GPG_SHORTID="0xEB7EB945"
ARG GPG_FINGERPRINT="2D83 3163 D69B B8F6 BFEF  179D 4ECC 3566 EB7E B945"

ENV GID=991 \
    UID=991 \
    DBHOST=mariadb \
    DBUSER=postfix \
    DBNAME=postfix \
    SMTPHOST=mailserver

RUN echo "@testing https://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
 && BUILD_DEPS=" \
    ca-certificates \
    gnupg" \
 && apk -U add \
    ${BUILD_DEPS} \
    nginx \
    s6 \
    su-exec \
    dovecot \
    php7.1-fpm@testing \
    php7.1-imap@testing \
    php7.1-mysqli@testing \
    php7.1-session@testing \
    php7.1-mbstring@testing \
 && cd /tmp \
 && PFA_TARBALL="postfixadmin-${VERSION}.tar.gz" \
 && wget -q https://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-${VERSION}/${PFA_TARBALL} \
 && echo "Verifying ${PFA_TARBALL} using GPG..." \
 && wget -q https://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-${VERSION}/${PFA_TARBALL}.asc \
 && gpg --keyserver keys.gnupg.net --recv-keys ${GPG_SHORTID} \
 && FINGERPRINT="$(LANG=C gpg --verify ${PFA_TARBALL}.asc ${PFA_TARBALL} 2>&1 \
  | sed -n "s#Primary key fingerprint: \(.*\)#\1#p")" \
 && if [ -z "${FINGERPRINT}" ]; then echo "Warning! Invalid GPG signature!" && exit 1; fi \
 && if [ "${FINGERPRINT}" != "${GPG_FINGERPRINT}" ]; then echo "Warning! Wrong GPG fingerprint!" && exit 1; fi \
 && echo "All seems good, now unpacking ${PFA_TARBALL}..." \
 && mkdir /postfixadmin && tar xzf ${PFA_TARBALL} -C /postfixadmin && mv /postfixadmin/postfixadmin-$VERSION/* /postfixadmin \
 && apk del ${BUILD_DEPS} \
 && rm -rf /var/cache/apk/* /tmp/* /root/.gnupg /postfixadmin/postfixadmin-$VERSION*

COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /etc/php7.1/php-fpm.conf
COPY setup /usr/local/bin/setup
COPY s6.d /etc/s6.d
COPY run.sh /usr/local/bin/run.sh

RUN chmod +x /usr/local/bin/* /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*

EXPOSE 8888

CMD ["run.sh"]
