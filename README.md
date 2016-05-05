# hardware/postfixadmin

![postfixadmin](http://i.imgur.com/UCtvKHR.png "postfixadmin")

Postfix Admin is a web based interface used to manage mailboxes, virtual domains and aliases. It also features support for vacation/out-of-the-office messages.

### Requirement

- Docker 1.0 or higher
- MySQL

### How to use

```
docker run -d \
  --name postfixadmin
  -e DBHOST=mysql \
  -e DBUSER=postfix \
  -e DBNAME=postfix \
  -e DBPASS=xxxxxxx \
  -h mail.domain.tld \
  hardware/postfixadmin
```

### Reverse proxy example with nginx

https://github.com/hardware/mailserver/wiki/Reverse-proxy-configuration

### Initial configuration

https://github.com/hardware/mailserver/wiki/Postfixadmin-initial-configuration

### Environment variables

- **GID** = postfixadmin user id (*optional*, default: 991)
- **UID** = postfixadmin group id (*optional*, default: 991)
- **DBHOST** = MySQL instance ip/hostname (*optional*, default: mariadb)
- **DBUSER** = MYSQL database username (*optional*, default: postfix)
- **DBNAME** = MYSQL database name (*optional*, default: postfix)
- **DBPASS** = MYSQL database (**required**)

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
    - /docker/mysql/db:/var/lib/mysql
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