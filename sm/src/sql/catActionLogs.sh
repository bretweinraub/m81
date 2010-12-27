#!/bin/sh

taskName=$1
action_id=$2
if test $# -lt 1; then
    echo ""
    echo Specify taskName
    echo ""
    exit
fi

if test -z "$action_id"; then
    line=`echo $1 | sqlplus -s $DATABASE_NAME @taskHier2.sql | ./cleanOracleQuery.pl | tail -1`
else
    line=`echo $1 | sqlplus -s $DATABASE_NAME @taskHier2.sql | ./cleanOracleQuery.pl | grep " $action_id "`        
fi
echo line is: $line
task_id=`echo $line | awk '{ print $2 }'`
task_name=`echo $line | awk '{ print $1 }' | cut -d'.' -f2`
action_id=`echo $line | awk '{ print $(NF-2) }'`
fileroot=/var/www/html/$M80_BDF/taskData/$task_id/$action_id.$task_name

echo "looking at $fileroot"

test -e $fileroot.0 && cat $fileroot.0
test -e $fileroot.1 && cat $fileroot.1

