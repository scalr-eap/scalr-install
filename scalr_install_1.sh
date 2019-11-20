#!/bin/bash

curl -s https://${1}:@packagecloud.io/install/repositories/scalr/scalr-server-ee/script.deb.sh | bash
apt-get install -y scalr-server
scalr-server-wizard
cp /etc/scalr-server/scalr-server-secrets.json /var/tmp
chmod 777 /var/tmp/scalr-server-secrets.json

cp /var/tmp/scalr-server-local.rb /etc/scalr-server
chmod 644 /etc/scalr-server/scalr-server-local.rb
