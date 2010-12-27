#!/bin/bash


if [ $# -ne 2 ]; then
    echo Usage: mapper.sh match-string replacement-string
    exit 1
fi

startStr=$1
endStr=$2

for file in $(find . -type f); do
    if [ -n "$(grep $startStr $file)" ]; then
	cmd="perl -pi -e 's/"$startStr"/"$endStr"/g' $file"
	echo $cmd
	eval $cmd
	if [ $? -ne 0 ]; then
	    echo Warning: $cmd returned an error.
	fi
    fi
done

