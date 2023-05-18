FROM debian:11.6

USER root

COPY init-and-start-script.bash /

RUN /bin/bash -c 'if ! [ -z "HTTP_PROXY" ]; then echo Acquire::http::proxy \"$HTTP_PROXY\"\; >> /etc/apt/apt.conf.d/10proxy ; fi \
                  && if ! [ -z "HTTPS_PROXY" ]; then echo Acquire::https::proxy \"$HTTPS_PROXY\"\; >> /etc/apt/apt.conf.d/10proxy ; fi \
                  && if ! [ -z "NO_PROXY" ]; then echo Acquire::no::proxy \"$NO_PROXY\"\; >> /etc/apt/apt.conf.d/10proxy ; fi \
                  && cat /etc/apt/apt.conf.d/10proxy \
                  && apt update --fix-missing \
                  && apt install locales krb5-kdc krb5-kdc-ldap krb5-admin-server -y \
                  && chmod 777 /init-and-start-script.bash \
                  && apt clean \
                  && apt autoremove \
                  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/log/* \
                  && rm -rf /etc/krb5kdc/kdc.conf'

ENV KADMIN_PRINCIPAL ${KADMIN_PRINCIPAL:-kadmin/admin}
ENV REALM ${REALM:-EXAMPLE.COM}
ENV LDAP_BASE_DN ${LDAP_BASE_DN:-dc=example,dc=com}
ENV ENCRYPTION_TYPE ${ENCRYPTION_TYPE:-aes256-cts-hmac-sha1-96}
ENV SUPPORTED_ENCRYPTION_TYPES ${SUPPORTED_ENCRYPTION_TYPES:-aes256-cts-hmac-sha1-96:normal}

ENV LDAP_KDC_DN ${LDAP_KDC_DN:-cn=readonly,dc=example,dc=com}
ENV LDAP_KDC_DN_PASSWORD ${LDAP_KDC_DN_PASSWORD:-qwerty}

ENV LDAP_KADMIND_DN ${LDAP_KADMIND_DN:-cn=admin,dc=example,dc=com}
ENV LDAP_KADMIND_DN_PASSWORD ${LDAP_KADMIND_DN_PASSWORD:-1q2w3e4r}

ENV LDAP_KERBEROS_CONTAINER_DN ${LDAP_KERBEROS_CONTAINER_DN:-cn=krbContainer,dc=example,dc=com}
ENV LDAP_SERVER ${LDAP_SERVER:-ldapi:///}

ENV PORTS ${PORTS:-750}
ENV KADMIN_PORT ${KADMIN_PORT:-749}

CMD /init-and-start-script.bash
