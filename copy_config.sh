#!/bin/bash

chmod 400 ~/.ssh/id_rsa

for ip in $*
do
  scp -o StrictHostKeyChecking=no /var/tmp/scalr-server-secrets.json /var/tmp/scalr-server.rb /var/tmp/license.json ubuntu@$ip:/var/tmp
done
