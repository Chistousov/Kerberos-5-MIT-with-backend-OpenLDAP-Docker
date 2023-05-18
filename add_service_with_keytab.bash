#!/bin/bash

if [[ -n $1 ]] && [[ -n $2 ]]; then
    
    source .env

    user="$2/$1@${LDAP_DOMAIN_UPPER}"

    docker compose exec -it kdc kadmin.local -q "addprinc -randkey ${user}"
    docker compose exec -it kdc kadmin.local -q "ktadd -k /${2}_${1}.keytab ${user}"
    docker compose cp kdc:/${2}_${1}.keytab ${2}_${1}.keytab

    echo '--------------keytab--------------'
    realpath ${2}_${1}.keytab
    echo '----------------------------------'
else
    
    echo "Invalid args. Example: bash add_user_with_keytab.bash testdns testservice"
fi
