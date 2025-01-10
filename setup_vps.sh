#!/usr/bin/env bash

## Add User Stuff

sudo apt-get install -y vim ncal command-not-found

sudo useradd -m blue

sudo usermod -a -G blue sudo

## Setup User

chsh -s /bin/bash blue

## SSH Stuff

mkdir /home/blue/.ssh

chmod 700 /home/blue/.ssh

echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0NLK7075DSCgPzNH7srVO0tYCyQwlkI8D9hEnTnWnq2t1y/uIGZWmW5WJ268HTA358fkxGOC4+WRWTFLDdUluKbxNoppk1FON7UitAFhl/Pp3N2WUw8JF80Hc0QJtjDYDn+y24N5gfSkIHHIsduE900YuvluFynVALOXoyz5Q3y1l9/MP1K7pD9jTO7MJx2bNsJDkN1kxcC+8ByJ3L2IpqI5UGtJmHLS1ozDvzMc5+h5ElKf5wySA4yeOKseH0TX9O7y9EloSeuuajO7t2pL2of4lZauBmigQH2nAC99KyLiRcW4Fbzf4yNOy/i69NYB4sH1nVTgFRZBYqMVf13b/ bluesoldier23@HomeDesktop' > /home/blue/.ssh/authorized_keys

chmod 600 /home/blue/.ssh/authorized_keys

sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#AuthorizedKeysFile     .ssh\/authorized_keys .ssh\/authorized_keys2/AuthorizedKeysFile     .ssh\/authorized_keys .ssh\/authorized_keys2/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

