FROM alpine:3.6

LABEL description "PostfixAdmin is a web based interface used to manage mailboxes" \
      maintainer="Hardware <contact@meshup.net>"

ARG VERSION=3.1

# https://pgp.mit.edu/pks/lookup?search=0xC6A682EA63C82F1C&fingerprint=on&op=index
# pub  4096R/63C82F1C 2005-10-06 Christian Boltz (www.cboltz.de) <gpg@cboltz.de>

ARG GPG_SHORTID="0xC6A682EA63C82F1C"
ARG GPG_FINGERPRINT="70CA A060 DE04 2AAE B1B1  5196 C6A6 82EA 63C8 2F1C"

ENV GID=991 \
    UID=991 \
    DBHOST=mariadb \
    DBUSER=postfix \
    DBNAME=postfix \
    SMTPHOST=mailserver

RUN echo "@community https://nl.alpinelinux.org/alpine/v3.6/community" >> /etc/apk/repositories \
 && apk -U upgrade \
 && apk add -t build-dependencies \
    ca-certificates \
    gnupg \
 && apk add \
    nginx \
    s6 \
    su-exec \
    dovecot \
    php7-fpm@community \
    php7-imap@community \
    php7-mysqli@community \
    php7-session@community \
    php7-mbstring@community \
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
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/* /tmp/* /root/.gnupg /postfixadmin/postfixadmin-$VERSION*

COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /etc/php7/php-fpm.conf
COPY setup /usr/local/bin/setup
COPY s6.d /etc/s6.d
COPY run.sh /usr/local/bin/run.sh

RUN chmod +x /usr/local/bin/* /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*

EXPOSE 8888

CMD ["run.sh"]
