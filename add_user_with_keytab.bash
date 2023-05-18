#!/bin/bash

if [[ -n $1 ]]; then
    
    source .env

    user="$1@${LDAP_DOMAIN_UPPER}"

    docker compose exec -it kdc kadmin.local -q "addprinc -randkey ${user}"
    docker compose exec -it kdc kadmin.local -q "ktadd -k /${1}.keytab ${user}"
    docker compose cp kdc:/${1}.keytab ${1}.keytab

    echo '--------------keytab--------------'
    realpath ${1}.keytab
    echo '----------------------------------'
else
    
    echo "Invalid args. Example: bash add_user_with_keytab.bash testuser"
fi
