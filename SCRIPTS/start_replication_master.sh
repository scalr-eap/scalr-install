#!/bin/bash

# Runs as login user for instance, e.g. ubuntu

exec 1>/var/tmp/$(basename $0).log

exec 2>&1

abort () {
  echo "ERROR: Failed with $1 executing '$2' @ line $3"
  exit $1
}

trap 'abort $? "$STEP" $LINENO' ERR

SLAVE_IP=${1}

STEP="Start Replication"
#/opt/scalr-server/bin/kickstart-replication ${MASTER_IP}:3306 ${SLAVE_IP}:3306

STEP="Dump Master"

MYSQL_PASS=$(sudo sed -n "/mysql/,+1p" /etc/scalr-server/scalr-server-secrets.json | tail -1 | sed 's/.*: "\(.*\)",/\1/')

sudo /opt/scalr-server/embedded/bin/mysql -u root -p"${MYSQL_PASS}" << ! > /var/tmp/mysql_dump.out
RESET MASTER;
FLUSH TABLES WITH READ LOCK;
SHOW MASTER STATUS;
\! /opt/scalr-server/embedded/bin/mysqldump -u root -p"${MYSQL_PASS}" --all-databases > /var/tmp/mysqldump.sql
UNLOCK TABLES;
!

STEP="chmod"
chmod 400 ~/.ssh/id_rsa

STEP="SCP files to Slave"
scp -o StrictHostKeyChecking=no /var/tmp/mysqldump.sql /var/tmp/mysql_dump.out ubuntu@${SLAVE_IP}:/var/tmp
