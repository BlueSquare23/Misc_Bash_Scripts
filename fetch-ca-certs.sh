#!/bin/bash
# Fetches LE CA certs for FreeIPA & runs update-ca-certificates.
# John R., Oct. 2024.

[[ $EUID -ne 0 ]] && echo "Run as root!" && exit 23

set -x
if ! [[ -d /usr/local/share/ca-certificates/extra ]]; then
    mkdir -p /usr/local/share/ca-certificates/extra
fi

wget -O /usr/local/share/ca-certificates/extra/isrgrootx1.crt https://letsencrypt.org/certs/isrgrootx1.pem
wget -O /usr/local/share/ca-certificates/extra/isrg-root-x2.crt https://letsencrypt.org/certs/isrg-root-x2.pem
wget -O /usr/local/share/ca-certificates/extra/lets-encrypt-r3.crt https://letsencrypt.org/certs/lets-encrypt-r3.pem
wget -O /usr/local/share/ca-certificates/extra/lets-encrypt-e1.crt https://letsencrypt.org/certs/lets-encrypt-e1.pem
wget -O /usr/local/share/ca-certificates/extra/lets-encrypt-r4.crt https://letsencrypt.org/certs/lets-encrypt-r4.pem
wget -O /usr/local/share/ca-certificates/extra/lets-encrypt-e2.crt https://letsencrypt.org/certs/lets-encrypt-e2.pem
wget -O /usr/local/share/ca-certificates/extra/e5.crt https://letsencrypt.org/certs/2024/e5.pem
wget -O /usr/local/share/ca-certificates/extra/e6.crt https://letsencrypt.org/certs/2024/e6.pem
wget -O /usr/local/share/ca-certificates/extra/r10.crt https://letsencrypt.org/certs/2024/r10.pem
wget -O /usr/local/share/ca-certificates/extra/r11.crt https://letsencrypt.org/certs/2024/r11.pem

update-ca-certificates

