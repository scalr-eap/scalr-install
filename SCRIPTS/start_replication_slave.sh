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

STEP="Get dump data"
read FILE POS <<< $(grep "mysql-bin." < /var/tmp/mysql_dump.out | cut -f1-2)

REPL_PASS=$(sudo sed -n "/mysql/,+3p" /etc/scalr-server/scalr-server-secrets.json | tail -1 | sed 's/.*: "\(.*\)"/\1/')

MYSQL_PASS=$(sudo sed -n "/mysql/,+1p" /etc/scalr-server/scalr-server-secrets.json | tail -1 | sed 's/.*: "\(.*\)",/\1/')

STEP="Stop Slave"
sudo /opt/scalr-server/embedded/bin/mysql -u root -p"${MYSQL_PASS}" << !
STOP SLAVE;
!

STEP="Load Dump"
sudo /opt/scalr-server/embedded/bin/mysql -u root -p"${MYSQL_PASS}" < /var/tmp/mysqldump.sql

echo $REPL_PASS $FILE $POS

STEP="Start Slave"
sudo /opt/scalr-server/embedded/bin/mysql -u root -p"${MYSQL_PASS}" << !
CHANGE MASTER TO MASTER_HOST='${MASTER_IP}',MASTER_USER='repl', MASTER_PASSWORD='${REPL_PASS}', MASTER_LOG_FILE='${FILE}', MASTER_LOG_POS=${POS};
START SLAVE;
SHOW SLAVE STATUS;
!
