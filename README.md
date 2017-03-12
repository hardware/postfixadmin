# hardware/postfixadmin

![postfixadmin](http://i.imgur.com/UCtvKHR.png "postfixadmin")

### What is this ?

PostfixAdmin is a web based interface used to manage mailboxes, virtual domains and aliases. It also features support for vacation/out-of-the-office messages.

### Features

- Lightweight & secure image (no root process)
- Based on Alpine Linux
- Latest Postfixadmin version (3.0.2)
- MySQL/Mariadb driver
- With Nginx and PHP7

### Built-time variables

- **VERSION** : version of postfixadmin (default: **3.0.2**)
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
| **DBPASS** | MariaDB database password | **required** | null
| **SMTPHOST** | SMTP server ip/hostname | *optional* | mailserver
| **DOMAIN** | Mail domain | *optional* | domainname of the container

### Reverse proxy example with nginx

https://github.com/hardware/mailserver/wiki/Reverse-proxy-configuration

### Initial configuration

https://github.com/hardware/mailserver/wiki/Postfixadmin-initial-configuration

### Docker-compose

#### Docker-compose.yml

```
postfixadmin:
  image: hardware/postfixadmin
  container_name: postfixadmin
  domainname: domain.tld
  hostname: mail
  links:
    - mariadb:mariadb
  environment:
    - DBHOST=mariadb
    - DBUSER=postfix
    - DBNAME=postfix
    - DBPASS=xxxxxxx

mariadb:
  image: mariadb:10.1
  container_name: mariadb
  volumes:
    - /mnt/docker/mysql/db:/var/lib/mysql
  environment:
    - MYSQL_ROOT_PASSWORD=xxxx
    - MYSQL_DATABASE=postfix
    - MYSQL_USER=postfix
    - MYSQL_PASSWORD=xxxx
```

#### Run !

```
docker-compose up -d
```
