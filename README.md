# **Kerberos 5 (MIT) with backend OpenLDAP (Docker)**

![Kerberos 5 (MIT) and OpenLDAP](krb5mit_and_openldap.png)

## Description

An example of running Kerberos 5 and OpenLDAP in Docker (A simple alternative to Active Directory).
[osixia/docker-openldap](https://github.com/osixia/docker-openldap) is used as OpenLDAP.

Пример запуска Kerberos 5 и OpenLDAP в Docker (Простая альтернатива Active Directory).
В качестве OpenLDAP используется [osixia/docker-openldap](https://github.com/osixia/docker-openldap).

### TODO 

- [ ] cluster KDC

## Build Kerberos 5 (MIT) Docker Image

### Proxy
#### Docker (Debian)

```bash
mkdir -p /etc/systemd/system/docker.service.d

# set proxy
cat > /etc/systemd/system/docker.service.d/http-proxy.conf <<-EOF
[Service]
Environment="HTTP_PROXY=http://proxyuser:proxypass@192.168.20.4:8822/"
Environment="HTTPS_PROXY=http://proxyuser:proxypass@192.168.20.4:8822/"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF

# restart docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# check
systemctl show --property=Environment docker

```

#### APT (Docker image)
If you need to specify a proxy server (apt see kerberos/Dockerfile), then uncomment HTTP_PROXY (HTTPS_PROXY or/and NO_PROXY) and edit HTTP_PROXY (HTTPS_PROXY or/and NO_PROXY)

Если необходимо указать прокси сервер (apt see kerberos/Dockerfile), то раскомментируйте HTTP_PROXY (HTTPS_PROXY or/and NO_PROXY) и отредактируйте HTTP_PROXY (HTTPS_PROXY or/and NO_PROXY)

```bash
 #!/bin/bash

export HTTP_PROXY="http://proxyuser:proxypass@192.168.20.4:8822/"
export HTTPS_PROXY="http://proxyuser:proxypass@192.168.20.4:8822/"
export NO_PROXY="localhost,127.0.0.1"

REPO_IMAGE="chistousov"
...

```

### Build

```bash
cd kerberos5
bash build_image.bash
```

## Getting Started

![kerberos5+OpenLDAP](kerberos5+OpenLDAP.png "kerberos5+OpenLDAP")

Requires Docker and Docker Compose.

Требуется Docker and Docker Compose.

Let's say the KDC will run in REALM EXAMPLE.COM with domain example.com. DESCRIBE the IP ADDRESS of example.com IN THE FILE /etc/hosts FOR THE KDC SERVER AND CLIENTS.

Допустим KDC будет работать в REALM EXAMPLE.COM с domain example.com.
ОПИСЫВАЕМ IP АДРЕС example.com В ФАЙЛЕ /etc/hosts ДЛЯ СЕРВЕРА И КЛИЕНТОВ KDC.

```bash
echo '172.20.23.3 example.com' >> /etc/hosts
# check
ping example.com
```
Edit the environment variables at the beginning of the start.bash file.

Редактируем переменные окружения в начале файла start.bash.
```bash

# ------------------!!!EDIT!!!----------------

LDAP_ORGANISATION="MyOrg"
LDAP_DOMAIN="example.com"
LDAP_BASE_DN="dc=example,dc=com"

LDAP_ADMIN_PASSWORD="qwerty"
LDAP_CONFIG_PASSWORD="qwerty"

LDAP_READONLY_USER_PASSWORD="qwerty"

# ------------------------------------------
...
```

Editing extra_hosts in the docker-compose file.yaml for service kdc

Редактируем extra_hosts в файле docker-compose.yaml для service kdc

```yaml
networks:
  - kdc-network
extra_hosts:
  - "example.com:172.20.23.3"
  - "someuser1:172.20.23.1"
  - "someservice2:172.20.23.2"
```

Start

Запускаем.

```bash
bash start.bash
```

## Stop

We stop containers with saving data (volume).

Останавливаем контейнеры с сохранением данных (volume).

```bash
bash stop.bash
```

## Stop and clean

We stop containers and delete all data (volume).

Останавливаем контейнеры и удаляем все данные(volume).

```bash
bash stop_and_clean.bash
```

## Example SSH with Kerberos5

**REALM is FOO.COM**

| Type           | DNS, Hostname  | IP            |
| -------------  | -------------  | ------------- |
| KDC            | foo.com    | 192.168.0.101 |
| ssh server     | ssh.custom.com | 192.168.0.104 |

### KDC

Editing extra_hosts in the docker-compose file.yaml for service kdc

Редактируем extra_hosts в файле docker-compose.yaml для service kdc

```yaml
networks:
  - kdc-network
extra_hosts:
  - "foo.com:192.168.0.101"
  - "ssh.custom.com:192.168.0.104"
```

Editing the settings

Редактируем настройки

```bash
vi start.bash

# LDAP_ORGANISATION="MyOrg"
# LDAP_DOMAIN="foo.com"
#LDAP_BASE_DN="dc=foo,dc=com"

#LDAP_ADMIN_PASSWORD="somesuperpass1"
#LDAP_CONFIG_PASSWORD="somesuperpass2"

#LDAP_READONLY_USER_PASSWORD="somesuperpass3"

```

Start

Запускаем.

```bash
bash start.bash
```

Let's add service for SSH to KDC.

Добавим service для SSH в KDC.
```bash
bash add_service_with_keytab.bash ssh.custom.com host
```

Copy host_ssh.custom.com.keytab to ssh server computer (example /host_ssh.custom.com.keytab).
You can use scp.

Копируем host_ssh.custom.com.keytab на компьютер ssh server (example /host_ssh.custom.com.keytab).
Можно использовать scp.

Let's add a user for SSH login to the KDC.

Добавим пользователя для login SSH в KDC.
```bash
bash add_user.bash someuser
```

### SSH Server

For ssh server, you need to create a user some user in Linux.

Для ssh server нужно создать пользователя someuser в Linux.
```bash
# Debian create user
sudo adduser someuser
```
Adding dns - ip mappings.

Добавляем сопоставления dns - ip.

```bash
echo '192.168.0.101 foo.com' >> /etc/hosts
# check
ping foo.com

echo '192.168.0.104 ssh.custom.com' >> /etc/hosts
# check
ping ssh.custom.com

```

Edit /etc/ssh/sshd_config as follows.

Редактируем /etc/ssh/sshd_config следующим образом.
```bash
...
# add GSSAPI (Kerberos 5)
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
...
```

Also, krb5-user must be installed on the service KDC computer

Также на компьютер service KDC необходимо установить krb5-user
```bash
apt install krb5-user
```

Editing /etc/krb5.conf

Редактируем /etc/krb5.conf
```bash
cat > /etc/krb5.conf <<-EOF
[libdefaults]
    default_realm = FOO.COM
    forwardable = TRUE
[realms]
    FOO.COM = {
            kadmind_port = 749
            kdc = foo.com:750
            admin_server = foo.com
    }
[domain_realm]
        foo.com = FOO.COM
        ssh.custom.com = FOO.COM
EOF
```

Installing keytab (host_ssh.custom.com.keytab)

Устанавливаем keytab (host_ssh.custom.com.keytab)

```bash
chown root:root /host_ssh.custom.com.keytab
mv /host_ssh.custom.com.keytab /etc/krb5.keytab
```

Restarting the ssh service.

Перезапускаем службу ssh.
```bash
sudo systemctl restart sshd
# check
sudo systemctl status sshd
```

### Client KDC

Adding dns - ip mappings.

Добавляем сопоставления dns - ip.

```bash
echo '192.168.0.101 foo.com' >> /etc/hosts
# check
ping foo.com

echo '192.168.0.104 ssh.custom.com' >> /etc/hosts
# check
ping ssh.custom.com

```

Also, krb5-user must be installed on the service KDC computer

Также на компьютер service KDC необходимо установить krb5-user
```bash
apt install krb5-user
```

Editing /etc/krb5.conf

Редактируем /etc/krb5.conf
```bash
cat > /etc/krb5.conf <<-EOF
[libdefaults]
    default_realm = FOO.COM
    forwardable = TRUE
[realms]
    FOO.COM = {
            kadmind_port = 749
            kdc = foo.com:750
            admin_server = foo.com
    }
[domain_realm]
        foo.com = FOO.COM
        ssh.custom.com = FOO.COM
EOF
```

Authenticating to the KDC

Аутентифицируемся в KDC

```bash
kinit someuser
# check ticket
klist
```

Connecting to SSH

Подключаемся в SSH

```bash
ssh someuser@ssh.custom.com
```

## Debug

To debug kerberos (client or server):
```bash
export KRB5_TRACE=/dev/stdout
```

To debug ssh server:
```bash
/usr/sbin/sshd -f /etc/ssh/sshd_config -d -e
```

<hr>

## Backup and Restore from backup. SMB/CIFS (Advansed)

If you want to make periodic backups or you are transferring application data from one system to another system and want to restore data from a backup, then this section is for you.

Если Вы хотите делать переодические backup или Вы переносите данные приложения с одной системы
на другую систему и хотите восстановить данные с backup, то эта секция для Вас.

Create an SMB/CIFS share where you will store your backups.

Создайте SMB/CIFS share, где будите хранить backupЫ.

Uncomment (Расскоментируйте):
- services (containers \*restore\*, \*backup\*)
- volumes \*-backup-volume
- depends_on containers \*restore\*, \*backup\*

Edit volumes \*-backup-volume with the options you need.

Отредактируйте volumes \*-backup-volume с необходимыми параметрами для Вас.

BACKUP_CRON_EXPRESSION = when does the backup take place (cron).

BACKUP_CRON_EXPRESSION = когда происходит backup (cron).

<hr>

## Creators

Nikita Konstantinovich Chistousov 

chistousov.nik@yandex.ru

## License

MIT