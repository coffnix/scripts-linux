#!/bin/bash
source ~/bin/zmshutil ; zmsetvars ; /opt/zimbra/mysql/bin/mysqldump --user=root --password=$mysql_root_password --socket=$mysql_socket --all-databases --single-transaction --flush-logs > $1
