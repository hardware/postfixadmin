#!/bin/sh

GID=${GID:-991}
UID=${UID:-991}
DOMAIN=${DOMAIN:-$(hostname --domain)}
DBHOST=${DBHOST:-mariadb}
DBUSER=${DBUSER:-postfix}
DBNAME=${DBNAME:-postfix}
DBPASS=$([ -f $DBPASS ] && cat $DBPASS || echo ${DBPASS:-})
SMTPHOST=${SMTPHOST:-mailserver}
ENCRYPTION=${ENCRYPTION:-"dovecot:SHA512-CRYPT"}

if [ -z "$DBPASS" ]; then
  echo "Mariadb database password must be set !"
  exit 1
fi

# Create smarty cache folder
mkdir -p /postfixadmin/templates_c

# Set permissions
chown -R $UID:$GID /postfixadmin

# Local postfixadmin configuration file
cat > /postfixadmin/config.local.php <<EOF
<?php
\$CONF['configured'] = true;

\$CONF['database_type'] = 'mysqli';
\$CONF['database_host'] = '${DBHOST}';
\$CONF['database_user'] = '${DBUSER}';
\$CONF['database_password'] = '${DBPASS}';
\$CONF['database_name'] = '${DBNAME}';

\$CONF['encrypt'] = '${ENCRYPTION}';
\$CONF['dovecotpw'] = "/usr/bin/doveadm pw";

\$CONF['smtp_server'] = '${SMTPHOST}';
\$CONF['domain_path'] = 'YES';
\$CONF['domain_in_mailbox'] = 'NO';
\$CONF['fetchmail'] = 'YES';
\$CONF['sendmail'] = 'YES';

\$CONF['admin_email'] = 'postfixadmin@${DOMAIN}';
\$CONF['footer_text'] = 'Return to ${DOMAIN}';
\$CONF['footer_link'] = 'http://${DOMAIN}';
\$CONF['default_aliases'] = array (
  'abuse'      => 'abuse@${DOMAIN}',
  'hostmaster' => 'hostmaster@${DOMAIN}',
  'postmaster' => 'postmaster@${DOMAIN}',
  'webmaster'  => 'webmaster@${DOMAIN}'
);

\$CONF['quota'] = 'YES';
\$CONF['domain_quota'] = 'YES';
\$CONF['quota_multiplier'] = '1024000';
\$CONF['used_quotas'] = 'YES';
\$CONF['new_quota_table'] = 'YES';

\$CONF['aliases'] = '0';
\$CONF['mailboxes'] = '0';
\$CONF['maxquota'] = '0';
\$CONF['domain_quota_default'] = '0';
?>
EOF

# RUN !
exec su-exec $UID:$GID php7 -S 0.0.0.0:8888 -t /postfixadmin
