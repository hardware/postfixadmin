FROM alpine:3.7

LABEL description="PostfixAdmin is a web based interface used to manage mailboxes" \
      maintainer="yas <yas.naoi@matcha.works>"

ARG VERSION=3.1

# https://pgp.mit.edu/pks/lookup?search=0xC6A682EA63C82F1C&fingerprint=on&op=index
# pub  4096R/63C82F1C 2005-10-06 Christian Boltz (www.cboltz.de) <gpg@cboltz.de>
ARG GPG_SHORTID="0xC6A682EA63C82F1C"
ARG GPG_FINGERPRINT="70CA A060 DE04 2AAE B1B1  5196 C6A6 82EA 63C8 2F1C"

RUN echo "@community https://nl.alpinelinux.org/alpine/v3.7/community" >> /etc/apk/repositories \
 && apk -U upgrade \
 && apk add -t build-dependencies \
    ca-certificates \
    gnupg \
 && apk --update add \
    su-exec \
    dovecot \
    tini@community \
    php7@community \
    php7-dom@community \
    php7-fpm@community \
    php7-imap@community \
    php7-mysqli@community \
    php7-session@community \
    php7-mbstring@community \
    php7-simplexml@community \
    php7-xmlrpc@community \
    curl \
 && cd /tmp \
 && PFA_TARBALL="postfixadmin-${VERSION}.tar.gz" \
 && wget -q https://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-${VERSION}/${PFA_TARBALL} \
 && wget -q https://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-${VERSION}/${PFA_TARBALL}.asc \
 && ( \
    gpg --keyserver pgp.mit.edu --recv-keys ${GPG_SHORTID} || \
    gpg --keyserver keyserver.pgp.com --recv-keys ${GPG_SHORTID} || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys ${GPG_SHORTID} \
    ) \
 && FINGERPRINT="$(LANG=C gpg --verify ${PFA_TARBALL}.asc ${PFA_TARBALL} 2>&1 | sed -n "s#Primary key fingerprint: \(.*\)#\1#p")" \
 && if [ -z "${FINGERPRINT}" ]; then echo "ERROR: Invalid GPG signature!" && exit 1; fi \
 && if [ "${FINGERPRINT}" != "${GPG_FINGERPRINT}" ]; then echo "ERROR: Wrong GPG fingerprint!" && exit 1; fi \
 && mkdir /postfixadmin && tar xzf ${PFA_TARBALL} -C /postfixadmin && mv /postfixadmin/postfixadmin-$VERSION/* /postfixadmin \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/* /tmp/* /root/.gnupg /postfixadmin/postfixadmin-$VERSION* \
 && curl -LO https://github.com/zendframework/zf1/releases/download/$(curl -s https://api.github.com/repos/zendframework/zf1/releases/latest | grep tag_name | cut -d '"' -f 4)/ZendFramework-$(curl -s https://api.github.com/repos/zendframework/zf1/releases/latest | grep tag_name | cut -d '"' -f 4 | sed s/release-//g)-minimal.tar.gz \
 && tar xfz ZendFramework-$(curl -s https://api.github.com/repos/zendframework/zf1/releases/latest | grep tag_name | cut -d '"' -f 4 | sed s/release-//g)-minimal.tar.gz ZendFramework-$(curl -s https://api.github.com/repos/zendframework/zf1/releases/latest | grep tag_name | cut -d '"' -f 4 | sed s/release-//g)-minimal/library \
 && mv ZendFramework-$(curl -s https://api.github.com/repos/zendframework/zf1/releases/latest | grep tag_name | cut -d '"' -f 4 | sed s/release-//g)-minimal/library /postfixadmin \
 && sed -i s'|;include_path = "\.:/php/includes"|include_path = ".:./library"|'g /etc/php7/php.ini

COPY bin /usr/local/bin
RUN chmod +x /usr/local/bin/*
EXPOSE 8888
CMD ["tini", "--", "run.sh"]
