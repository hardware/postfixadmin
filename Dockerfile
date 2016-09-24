FROM alpine:3.4
MAINTAINER Hardware <contact@meshup.net>

ARG VERSION=3.0

# https://pgp.mit.edu/pks/lookup?search=0x63C82F1C&fingerprint=on&op=index
# pub  4096R/63C82F1C 2005-10-06 Christian Boltz (www.cboltz.de) <gpg@cboltz.de>
ARG GPG_SHORTID="0x63C82F1C"
ARG GPG_FINGERPRINT="70CA A060 DE04 2AAE B1B1  5196 C6A6 82EA 63C8 2F1C"

ENV GID=991 \
    UID=991 \
    DBHOST=mariadb \
    DBUSER=postfix \
    DBNAME=postfix \
    SMTPHOST=mailserver

RUN echo "@commuedge https://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
 && BUILD_DEPS=" \
    ca-certificates \
    gnupg" \
 && apk -U add \
    ${BUILD_DEPS} \
    nginx \
    s6 \
    su-exec \
    dovecot \
    php7-fpm@commuedge \
    php7-imap@commuedge \
    php7-mysqli@commuedge \
    php7-session@commuedge \
    php7-mbstring@commuedge \
 && cd /tmp \
 && PFA_TARBALL="postfixadmin-${VERSION}.tar.gz" \
 && wget -q https://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-${VERSION}/${PFA_TARBALL} \
 && echo "Verifying ${PFA_TARBALL} using GPG..." \
 && wget -q https://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-${VERSION}/${PFA_TARBALL}.asc \
 && gpg --keyserver keys.gnupg.net --recv-keys ${GPG_SHORTID} \
 && FINGERPRINT="$(LANG=C gpg --verify ${PFA_TARBALL}.asc ${PFA_TARBALL} 2>&1 \
  | sed -n "s#Primary key fingerprint: \(.*\)#\1#p")" \
 && if [ -z "${FINGERPRINT}" ]; then echo "Warning! Invalid GPG signature!"; fi \
 && if [ "${FINGERPRINT}" != "${GPG_FINGERPRINT}" ]; then echo "Warning! Wrong GPG fingerprint!"; fi \
 && echo "All seems good, now unpacking ${PFA_TARBALL}..." \
 && mkdir /postfixadmin && tar xzf ${PFA_TARBALL} -C /postfixadmin && mv /postfixadmin/postfixadmin-$VERSION/* /postfixadmin \
 && apk del ${BUILD_DEPS} \
 && rm -rf /var/cache/apk/* /tmp/* /root/.gnupg /postfixadmin/postfixadmin-$VERSION*

COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /etc/php7/php-fpm.conf
COPY setup /usr/local/bin/setup
COPY s6.d /etc/s6.d
COPY run.sh /usr/local/bin/run.sh

RUN chmod +x /usr/local/bin/* /etc/s6.d/*/*

EXPOSE 8888

CMD ["run.sh"]
