#!/bin/bash

if [ ! -f .env ]; 
then

# ------------------!!!EDIT!!!----------------

LDAP_ORGANISATION="MyOrg"
LDAP_DOMAIN="example.com"
LDAP_BASE_DN="dc=example,dc=com"

LDAP_ADMIN_PASSWORD="qwerty"
LDAP_CONFIG_PASSWORD="qwerty"

LDAP_READONLY_USER_PASSWORD="qwerty"

# ------------------------------------------

LDAP_DOMAIN_UPPER=${LDAP_DOMAIN^^}
ENCRYPTION_TYPE_1="aes256-cts-hmac-sha1-96"

echo LDAP_ORGANISATION=${LDAP_ORGANISATION} >> .env
echo LDAP_DOMAIN=${LDAP_DOMAIN} >> .env
echo LDAP_DOMAIN_UPPER=${LDAP_DOMAIN_UPPER} >> .env
echo LDAP_BASE_DN=${LDAP_BASE_DN} >> .env
echo LDAP_ADMIN_PASSWORD=${LDAP_ADMIN_PASSWORD} >> .env
echo LDAP_CONFIG_PASSWORD=${LDAP_CONFIG_PASSWORD} >> .env
echo LDAP_READONLY_USER_PASSWORD=${LDAP_READONLY_USER_PASSWORD} >> .env
echo ENCRYPTION_TYPE_1=${ENCRYPTION_TYPE_1} >> .env
echo IP_LDAP_DOMAIN=${IP_LDAP_DOMAIN} >> .env

else

echo ".env is exists"

fi

chmod u+x restore-backup.sh
docker compose down || true
docker compose up -d --wait