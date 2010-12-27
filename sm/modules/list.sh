#!/bin/bash



gen () {
    while [ $# -gt 0 ]; do 
	type=$1
	shift
	echo
	echo "# $type"
	echo
	for p in $(find $type -type d -maxdepth 1 | grep -v svn | grep / | cut -d/ -f2); do
	    echo "newAutomatorModule($p,CONTROLLER,<:= \$m81path :>/sm/modules/$type/$p,$p)"
	done
    done
}

gen simple processes interfaces providers




