#!/bin/sh

taskName=$1

sleepval=$2

sleepval=${sleepval:-5}

eval $(m80 --export)

while [ 1 -eq 1 ]; do
    clear
    echo $1 | sqlplus -s $DATABASE_NAME @taskHier3.sql | ./cleanOracleQuery.pl
    sleep $sleepval
done
