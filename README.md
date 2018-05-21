# hardware/postfixadmin

![postfixadmin](http://i.imgur.com/UCtvKHR.png "postfixadmin")

### What is this ?

PostfixAdmin is a web based interface used to manage mailboxes, virtual domains and aliases. It also features support for vacation/out-of-the-office messages.

### Features

- Lightweight & secure image (no root process)
- Based on Alpine Linux
- Latest Postfixadmin version (3.2)
- MariaDB/PostgreSQL driver
- With PHP7

### Built-time variables

- **VERSION** : version of postfixadmin
- **GPG_SHORTID** : short gpg key ID
- **GPG_FINGERPRINT** : fingerprint of signing key
- **SHA256_HASH** : SHA256 hash of Postfixadmin archive

### Ports

- **8888**

### Environment variables

| Variable | Description | Type | Default value |
| -------- | ----------- | ---- | ------------- |
| **UID** | postfixadmin user id | *optional* | 991
| **GID** | postfixadmin group id | *optional* | 991
| **DBDRIVER** | Database type: mysql, pgsql | *optional* | mysql
| **DBHOST** | Database instance ip/hostname | *optional* | mariadb
| **DBPORT** | Database instance port | *optional* | 3306
| **DBUSER** | Database database username | *optional* | postfix
| **DBNAME** | Database database name | *optional* | postfix
| **DBPASS** | Database database password or location of a file containing it | **required** | null
| **SMTPHOST** | SMTP server ip/hostname | *optional* | mailserver
| **DOMAIN** | Mail domain | *optional* | `domainname` value
| **ENCRYPTION** | Passwords encryption method | *optional* | `dovecot:SHA512-CRYPT`
| **PASSVAL_MIN_LEN** | Passwords validation: minimum password length | *optional* | 5
| **PASSVAL_MIN_CHAR** | Passwords validation: must contain at least characters | *optional* | 3
| **PASSVAL_MIN_DIGIT** | Passwords validation: must contain at least digits | *optional* | 2
| **PAGE_SIZE** | Number of entries (mailboxes, alias, etc) that you would like to see in one page. | *optional* | 10
| **QUOTA_MULTIPLIER** | Number of bytes required to represent a single quota unit. You can either use '1000000', '1024000' or '1048576' | *optional* | 1024000

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
    - mariadb # postgres (adjust accordingly)
```

### How to setup

https://github.com/hardware/mailserver/wiki/Postfixadmin-initial-configuration
