#!/bin/sh

GID=${GID:-991}
UID=${UID:-991}
DOMAIN=${DOMAIN:-$(hostname --domain)}
DBDRIVER=${DBDRIVER:-mysql}
DBHOST=${DBHOST:-mariadb}
DBPORT=${DBPORT:-3306}
DBUSER=${DBUSER:-postfix}
DBNAME=${DBNAME:-postfix}
DBPASS=$([ -f "$DBPASS" ] && cat "$DBPASS" || echo "${DBPASS:-}")
SMTPHOST=${SMTPHOST:-mailserver}
ENCRYPTION=${ENCRYPTION:-"dovecot:SHA512-CRYPT"}
# Password validation
PASSVAL_MIN_LEN=${PASSVAL_MIN_LEN:-5}
PASSVAL_MIN_CHAR=${PASSVAL_MIN_CHAR:-3}
PASSVAL_MIN_DIGIT=${PASSVAL_MIN_DIGIT:-2}

if [ -z "$DBPASS" ]; then
  echo "MariaDB/PostgreSQL database password must be set !"
  exit 1
fi

# Create smarty cache folder
mkdir -p /postfixadmin/templates_c

# MySQL/MariaDB should use mysqli driver
case "$DBDRIVER" in
  mysql) DBDRIVER=mysqli;
esac

# Local postfixadmin configuration file
cat > /postfixadmin/config.local.php <<EOF
<?php

\$CONF['theme'] = 'bootstrap';
\$CONF['theme_css'] = 'css/bootstrap.css';

\$CONF['configured'] = true;

\$CONF['database_type'] = '${DBDRIVER}';
\$CONF['database_host'] = '${DBHOST}';
\$CONF['database_user'] = '${DBUSER}';
\$CONF['database_password'] = '${DBPASS}';
\$CONF['database_name'] = '${DBNAME}';
\$CONF['database_port'] = '${DBPORT}';

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

\$CONF['password_validation'] = array(
    '/.{${PASSVAL_MIN_LEN}}/'                => 'password_too_short ${PASSVAL_MIN_LEN}',
    '/([a-zA-Z].*){${PASSVAL_MIN_CHAR}}/'    => 'password_no_characters ${PASSVAL_MIN_CHAR}',
    '/([0-9].*){${PASSVAL_MIN_DIGIT}}/'      => 'password_no_digits ${PASSVAL_MIN_DIGIT}',
);
?>
EOF

# Fix permissions
chown -R $UID:$GID /postfixadmin /services /var/log /var/lib/nginx

# Permit nginx to log error to container stdout
chmod o+w /dev/stdout

# RUN !
exec su-exec $UID:$GID /bin/s6-svscan /services
