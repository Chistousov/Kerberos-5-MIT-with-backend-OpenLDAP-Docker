#!/bin/bash

if [[ -n $1 ]]; then
    
    source .env

    user="$1@${LDAP_DOMAIN_UPPER}"

    docker compose exec -it kdc kadmin.local -q "addprinc ${user}"

else
    
    echo "Invalid args. Example: bash add_user.bash testuser"
fi
