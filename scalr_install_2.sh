#!/bin/bash

cp /var/tmp/scalr-server-secrets.json /etc/scalr-server
chmod 400 /etc/scalr-server/scalr-server-secrets.json

cp /var/tmp/scalr-server.rb /etc/scalr-server
chmod 644 /etc/scalr-server/scalr-server.rb

cp /var/tmp/license.json /etc/scalr-server
chmod 644 /etc/scalr-server/license.json

scalr-server-ctl reconfigure
