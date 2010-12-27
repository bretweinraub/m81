# -*-shell-script-*-
#! /bin/bash
#
# M80 ---- see the License file for restrictions
#



PROGNAME=${0##*/}
TMPFILE=/tmp/${PROGNAME}.$$

if [ -n "${DEBUG}" ]; then	
	set -x
fi

PSCMD="ps axc"  








#
# $Header: /cvsroot/m80/m80/lib/shell/printmsg.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $
#
# Function:	printmsg
#
# Description:	generic error reporting routine.
#               BEWARE, white space is stripped and replaced with single spaces
#
# Call Signature:
#
# Side Effects:
#
# Assumptions:
#

printmsg () {
    if [ -z "${QUIET}" ]; then 
	if [ $# -ge 1 ]; then
	    /bin/echo -n ${M80_OVERRIDE_DOLLAR0:-$PROGNAME}:\($$\) >&2
		while [ $# -gt 0 ]; do /bin/echo -n " "$1 >&2 ; shift ; done
		if [ -z "${M80_SUPRESS_PERIOD}" ]; then
		    echo . >&2
		else
		    echo >&2
		fi
	fi
    fi
}


#
# Function:	cleanup
#
# Description:	generic KSH funtion for the end of a script
#
# History:	02.22.2000	bdw	passed error code through to localclean
#
# $Id: cleanup.sh,v 1.2 2004/04/06 22:42:02 bretweinraub Exp $
#

cleanup () {
    export EXITCODE=$1
    shift
    if [ $# -gt 0 ]; then
	printmsg $*
    fi
    if [ -n "${DQITMPFILE}" ]; then
	rm -f ${DQITMPFILE}
    fi
    if [ -n "${LOCALCLEAN}" ]; then
	localclean ${EXITCODE} # this function must be set
    fi
    if [ ${EXITCODE} -ne 0 ]; then
	# this is an error condition
	printmsg exiting with error code ${EXITCODE}
    else
	printmsg done
    fi
    exit ${EXITCODE}
}

trap "cleanup 1 caught signal" INT QUIT TERM HUP 2>&1 > /dev/null


require () {
    while [ $# -gt 0 ]; do
	#printmsg validating \$${1}
	derived=$(eval "echo \$"$1)
	if [ -z "$derived" ];then
	    printmsg \$${1} not defined
	    usage
	fi
	shift
    done
}



# 
# filesize () : returns the number of bytes for a file; more reliable than ls.
#

filesize () {
    if [ $# -ne 1 ]; then
	cleanup 1 illegal arguments to shell function filesize
    fi
    echo $1 | perl -nle '@stat = stat($_); print $stat[7]'
}


#
# Function:	docmd
#
# Description:	a generic wrapper for ksh functions
#
# $Id: docmd.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $

docmd () {
    if [ $# -lt 1 ]; then
	return
    fi
    #print ; eval "echo \* $*" ; print
    eval "echo '$*'"
    eval $*
    RETURNCODE=$?
    if [ $RETURNCODE -ne 0 ]; then
	cleanup $RETURNCODE command \"$*\" returned with error code $RETURNCODE
    fi
    return 0
}


#
# Function:	docmdi
#
# Description:	execute a command, but ignore the error code
#
# $Id: docmdi.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $

docmdi () {
    if [ $# -lt 1 ]; then
	return
    fi
#    print ; eval "echo \* $*" ; print
    eval "echo '$*'"
    eval $*
    export RETURNCODE=$?
    if [ $RETURNCODE -ne 0 ]; then
	printmsg command \"$*\" returned with error code $RETURNCODE, ignored
    fi
    return $RETURNCODE
}


#
# Function:	checkfile
#
# Description:	This function is used to check whether some file ($2) or
#               directory meets some condition ($1).  If not print out an error
#               message ($3+).
#
# $Id: checkfile.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $

checkfile () {
    if [ $# -lt 2 ]; then
	cleanup 1 illegal arguments to the checkfile \(\) function
    fi
    FILE=$2
    if [ ! $1 $FILE ]; then
	shift; shift
	cleanup 1 file $FILE $*
    fi
}

checkNotFile () {
    if [ $# -lt 2 ]; then
	cleanup 1 illegal arguments to the checkNotfile \(\) function
    fi
    FILE=$2
    if [ $1 $FILE ]; then
	shift; shift
	cleanup 1 file $FILE $*
    fi
}



SSHCOMMAND="ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey"




unset QUIET


usage () {
  printmsg  I am unhappy ...... a usage message follows for your benefit
  printmsg  Usage is -c {command} -t {task_id} -r {reload=TRUE} -s {suppressdump=TRUE} -a {action_id} -A {allowallenvs=TRUE} 

printmsg  Required variables: command 


  cleanup 1
} 

OPTIND=0
while getopts :c:t:rsa:A c 
    do case $c in        
	c) export command=$OPTARG;;
	t) export task_id=$OPTARG;;
	r) export reload=TRUE;;
	s) export suppressdump=TRUE;;
	a) export action_id=$OPTARG;;
	A) export allowallenvs=TRUE;;
	:) printmsg $OPTARG requires a value
	   usage;;
	\?) printmsg unknown option $OPTARG
	   usage;;
    esac
done
















test -z "${command}" && {
	printmsg missing value for command
	usage
}








eval $(m80 --export)

if [ -n "$action_id" ]; then
    internal_id=$action_id
else
    internal_id=$task_id
fi

export AUTOMATOR_STAGE_DIR=/data/deployments/${M80_BDF}/stage/$internal_id

mkdir -p $AUTOMATOR_STAGE_DIR

if [ ! -f /tmp/$PROGNAME.$internal_id -o -n "$reload" ]; then
    echo "reloading  id $internal_id"
    if [ -n "$task_id" ]; then
	dumpContext.pl -task_id $task_id > /tmp/$PROGNAME.$internal_id
	if [ $? -ne 0 ]; then
	    cleanup 1 cannot dump context
	fi
    else
	dumpContext.pl -action_id $action_id | grep -v "export COMMAND=" | grep -v "export GROUPS=" > /tmp/$PROGNAME.$internal_id
	if [ $? -ne 0 ]; then
	    cleanup 1 cannot dump context
	fi
    fi
fi

if [ -n "$action_id" -a -z "${allowallenvs}" ]; then
    for e in $(env | cut -d= -f1 | perl -nle 'print if /^[A-Za-z]/ && not /(ORACLE|PATH|M80|PERL|TERM|SHELL|command|task_id|debug|reload|mapper|suppressdump|task_id|action_id|PROGNAME|COMMAND|TOP|DISPLAY)/'); do
	unset $e
    done
fi


. /tmp/$PROGNAME.$internal_id

if [ $command = "eval" ]; then
    eval $COMMAND
else
    printmsg unknown command
fi

cleanup $?
