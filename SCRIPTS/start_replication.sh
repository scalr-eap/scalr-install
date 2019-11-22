#!/bin/bash

# Runs as login user for instance, e.g. ubuntu

exec 1>/var/tmp/$(basename $0).log

exec 2>&1

abort () {
  echo "ERROR: Failed with $1 executing '$2' @ line $3"
  exit $1
}

trap 'abort $? "$STEP" $LINENO' ERR

MASTER_IP=${1}
SLAVE_IP=${2}

STEP="Start Replication"
/opt/scalr-server/bin/kickstart-replication ${MASTER_IP}:3306 ${SLAVE_IP}:3306
