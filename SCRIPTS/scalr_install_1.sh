#!/bin/bash

# Runs as root via sudo

exec 1>/var/tmp/$(basename $0).log

exec 2>&1

abort () {
  echo "ERROR: Failed with $1 executing '$2' @ line $3"
  exit $1
}

trap 'abort $? "$STEP" $LINENO' ERR

TOKEN="${1}"
LICENSE="${2}"

STEP="curl to down load repo"
curl -s https://${TOKEN}:@packagecloud.io/install/repositories/scalr/scalr-server-ee/script.deb.sh | bash

STEP="apt-get install scalr-server"
apt-get install -y scalr-server

STEP="scalr-server-wizard"
scalr-server-wizard

STEP="cp /etc/scalr-server/scalr-server-secrets.json /var/tmp"
cp /etc/scalr-server/scalr-server-secrets.json /var/tmp
STEP="chmod 777 /var/tmp/scalr-server-secrets.json"
chmod 777 /var/tmp/scalr-server-secrets.json

# Conditional because MySQL Master wont have it's local file yet
STEP="cp /var/tmp/scalr-server-local.rb /etc/scalr-server"
[[ -f /var/tmp/scalr-server-local.rb ]] && cp /var/tmp/scalr-server-local.rb /etc/scalr-server
STEP="chmod 644 /etc/scalr-server/scalr-server-local.rb"
[[ -f /etc/scalr-server/scalr-server-local.rb ]] && chmod 644 /etc/scalr-server/scalr-server-local.rb

STEP="Create License"
echo "${LICENSE}" > /etc/scalr-server/license.json