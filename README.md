# naoi/postfixadmin

![postfixadmin](http://i.imgur.com/UCtvKHR.png "postfixadmin")

### What is this ?

PostfixAdmin is a web based interface used to manage mailboxes, virtual domains and aliases. It also features support for vacation/out-of-the-office messages.

### Features

- Latest **Postfixadmin ver. 3.1**
- Based on **Alpine** Linux
- With **PHP7**
- **XMLRPC Support**
- MySQL/Mariadb driver
- Lightweight & secure image (no root process)

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
| **PASSVAL_MIN_LEN** | Passwords validation: minimum password length | *optional* | 5
| **PASSVAL_MIN_CHAR** | Passwords validation: must contain at least characters | *optional* | 3
| **PASSVAL_MIN_DIGIT** | Passwords validation: must contain at least digits | *optional* | 2

### docker-compose.yml

```yml

# Full example :
# https://github.com/hardware/mailserver/blob/master/docker-compose.sample.yml

postfixadmin:
  image: postfixadmin
  container_name: postfixadmin
  domainname: YOUR_DOMAIN_NAME
  hostname: postfixadmin
  environment:
    - DBHOST=172.17.0.1
    - DBNAME=postfixadmin
    - DBUSER=postfixadmin
    - DBPASS=YOUR_PASSWORD
    - SMTPHOST=localhost
  ports:
    - "8888:8888"
```

### How to setup

https://github.com/hardware/mailserver/wiki/Postfixadmin-initial-configuration

### How to run (on Ubuntu)

1. `apt -y install git docker-compose`
2. `git clone https://github.com/naoi/postfixadmin.git`
3. `cd postfixadmin`
4. `cp ./etc/systemd/system/postfixadmin.service /etc/systemd/system/postfixadmin.service`
5. `cp ./etc/systemd/system/postfixadmin-start.service /etc/systemd/system/postfixadmin.service-start`
6. `vi docker-compose.yml` (Modify this file with your systems environment)
7. `docker-compose up`
8. `sudo service postfixadmin start`