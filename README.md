# hardware/postfixadmin

![postfixadmin](http://i.imgur.com/UCtvKHR.png "postfixadmin")

### What is this ?

PostfixAdmin is a web based interface used to manage mailboxes, virtual domains and aliases. It also features support for vacation/out-of-the-office messages.

### Features

- Lightweight & secure image (no root process)
- Based on Alpine Linux
- Latest Postfixadmin version (3.1)
- MySQL/Mariadb driver
- With PHP7

### Built-time variables

- **VERSION** : version of postfixadmin (default: **3.1**)
- **GPG_SHORTID** : short gpg key ID
- **GPG_FINGERPRINT** : fingerprint of signing key

### Ports

- **8888**

### Environment variables

| Variable | Description | Type | Default value |
| -------- | ----------- | ---- | ------------- |
| **UID** | postfixadmin user id | *optional* | 991
| **GID** | postfixadmin group id | *optional* | 991
| **DBHOST** | MariaDB instance ip/hostname | *optional* | mariadb
| **DBUSER** | MariaDB database username | *optional* | postfix
| **DBNAME** | MariaDB database name | *optional* | postfix
| **DBPASS** | MariaDB database password or location of a file containing it | **required** | null
| **SMTPHOST** | SMTP server ip/hostname | *optional* | mailserver
| **DOMAIN** | Mail domain | *optional* | `domainname` value
| **ENCRYPTION** | Passwords encryption method | *optional* | `dovecot:SHA512-CRYPT`

### Docker-compose.yml

```yml
# Full example :
# https://github.com/hardware/mailserver/blob/master/docker-compose.sample.yml

postfixadmin:
  image: hardware/postfixadmin
  container_name: postfixadmin
  domainname: domain.tld
  hostname: mail
  environment:
    - DBPASS=xxxxxxx
  depends_on:
    - mailserver
    - mariadb
```

### How to setup

https://github.com/hardware/mailserver/wiki/Postfixadmin-initial-configuration
