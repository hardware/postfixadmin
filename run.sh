#!/bin/sh

# ENV
export DOMAIN

DOMAIN=${DOMAIN:-$(hostname --domain)}

if [ -z "$DBPASS" ]; then
  echo "Mariadb database password must be set !"
  exit 1
fi

# Set permissions
chown -R $UID:$GID /postfixadmin /etc/nginx /etc/php7 /var/log /var/lib/nginx /tmp /etc/s6.d

# Local postfixadmin configuration file
cat > /postfixadmin/config.local.php <<EOF
<?php

\$CONF['configured'] = true;

\$CONF['database_type'] = 'mysqli';
\$CONF['database_host'] = '${DBHOST}';
\$CONF['database_user'] = '${DBUSER}';
\$CONF['database_password'] = '${DBPASS}';
\$CONF['database_name'] = '${DBNAME}';

\$CONF['encrypt'] = 'dovecot:SHA512-CRYPT';
\$CONF['dovecotpw'] = "/usr/bin/doveadm pw";

\$CONF['smtp_server'] = '${SMTPHOST}';
\$CONF['domain_path'] = 'YES';
\$CONF['domain_in_mailbox'] = 'NO';
\$CONF['fetchmail'] = 'NO';

\$CONF['admin_email'] = 'admin@${DOMAIN}';
\$CONF['footer_text'] = 'Return to ${DOMAIN}';
\$CONF['footer_link'] = 'http://${DOMAIN}';
\$CONF['default_aliases'] = array (
  'abuse'      => 'abuse@${DOMAIN}',
  'hostmaster' => 'hostmaster@${DOMAIN}',
  'postmaster' => 'postmaster@${DOMAIN}',
  'webmaster'  => 'webmaster@${DOMAIN}'
);

?>
EOF

# RUN !
exec su-exec $UID:$GID /bin/s6-svscan /etc/s6.d
