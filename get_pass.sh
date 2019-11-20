#!/bin/bash

cat << !
***********************************************************************************
*
* Admin Password (only shown once. Not an Output) = $(sudo cat /etc/scalr-server/scalr-server-secrets.json | grep admin_password | cut -d\" -f4)
*
***********************************************************************************
!
