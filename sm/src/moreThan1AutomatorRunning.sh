#!/bin/bash

user=$1

if test -z "$user"; then
    echo "Specify a user!"
    exit 1
fi

how_many=`ps aux --forest | grep $user | grep automator.pl | grep perl | grep -v grep | wc -l`
if test 1 -lt $how_many; then
    echo There are more than 1 automators running for user $user
    ps aux --forest | grep $user | grep automator.pl | grep perl | grep -v grep
    exit 1
fi

exit 0
