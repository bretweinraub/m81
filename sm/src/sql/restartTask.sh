#!/bin/sh

if test $# -lt 1; then
    echo ""
    echo Specify taskName
    echo ""
    exit
fi

if test -n "$2"; then
    id=`echo $1 | sqlplus -s $DATABASE_NAME @taskHier2.sql | ./cleanOracleQuery.pl | grep " $2 " | awk '{ print $(NF-2) }'`
    sql="update action set actionstatus = 'error' where action_id = $id;"
    echo restarting action_id = $id

else
    id=`echo $1 | sqlplus -s $DATABASE_NAME @taskHier2.sql | ./cleanOracleQuery.pl | tail -1 | awk '{ print $2 }'`
    sql="update task set status = 'error' where task_id = $id;"
    echo restarting task_id = $id
fi


eval $(m80 --export)
sqlplus $DATABASE_NAME <<EOF
$sql
commit;
EOF
