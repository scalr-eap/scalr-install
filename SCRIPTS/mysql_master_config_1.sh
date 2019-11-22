#!/bin/bash

# Runs as root via sudo

exec 1>/var/tmp/$(basename $0).log

exec 2>&1

abort () {
  echo "ERROR: Failed with $1 executing '$2' @ line $3"
  exit $1
}

trap 'abort $? "$STEP" $LINENO' ERR

DB_S=${1}

STEP="Create Master Config"

cat << ! > /etc/scalr-server/scalr-server-local.rb
# Enable the MySQL component
mysql[:enable] = true

# Set unique ID of this MySQL server
mysql[:server_id] = 1

# Enable binary log needed for replication
mysql[:binlog] = true

# Allow remote root access is required by the kickstart-replication script
mysql[:allow_remote_root] = true

# Specify which IP the slave will connect from to grant the correct privileges to the replication user
mysql[:repl_allow_connections_from] = '${DB_S}'
!
