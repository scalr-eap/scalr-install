#!/bin/bash

exec 1>/var/tmp/$(basename $0).log

exec 2>&1

abort () {
  echo "ERROR: Failed with $1 executing '$2' @ line $3"
  exit $1
}

trap 'abort $? "$STEP" $LINENO' ERR

STEP="cat"
cat << !
***********************************************************************************
*
* Admin Password (only shown once. Not an Output) = $(sudo cat /etc/scalr-server/scalr-server-secrets.json | grep admin_password | cut -d\" -f4)
*
***********************************************************************************
!
 
