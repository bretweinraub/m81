#!/bin/sh

taskName=$1

sleepval=$2

query=${3:-taskHier2.sql}

sleepval=${sleepval:-5}

eval $(m80 --export)

while [ 1 -eq 1 ]; do
    clear
    echo $1 | sqlplus -s $DATABASE_NAME @$query | ./cleanOracleQuery.pl
    sleep $sleepval
done
