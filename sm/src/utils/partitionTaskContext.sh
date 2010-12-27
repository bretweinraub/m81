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






# $m80path = {command => "m4", chmod => "+x" }


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



SSHCOMMAND="ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey"


#
# Function:	docmdqi
#
# Description:	execute a command quietly, but ignore the error code
#
# $Id: docmdqi.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $
#

docmdqi () {
    if [ $# -lt 1 ]; then return; fi
    DQITMPFILE=/tmp/${PROGNAME}.$$.dcmdqi
    eval $* 2>&1 > ${DQITMPFILE}
    export RETURNCODE=$?
    if [ ${RETURNCODE} -ne 0 ]; then
	cat ${DQITMPFILE} >&2
    fi
    rm -f ${DQITMPFILE}
    return $RETURNCODE
}




LOCALCLEAN=true
localclean () {
    rm -f /tmp/${PROGNAME}.$$*
    
}

DIRECTORY=$(pwd)


sqlfunc () {
    TMPFILE=${TMPFILE:-/tmp/${PROGNAME}.$$}
    while getopts :idq c
	do case $c in
	    i) ignoreError=true;;
	    q) quiet=true;;
	    d) DEBUG=true;;
	esac
    done

    if [ -n "${DEBUG}" ]; then
	echo \*\*\* sqlplus code is :
cat<<!
$code
!
	echo \*\*\* end sqlplus code
    fi

    sqlout=
    sqlplus -s $DATABASE_NAME <<! >/dev/null 2>&1
    whenever oserror exit 3
    whenever sqlerror exit 5
    set echo off feedb off timi off pau off pages 0 lines 500 trimsp on
    spool ${TMPFILE}.sqlfunc
    ${code}
    exit success
!
    RC=$?
    
    if [ -z "$ignoreError" ]; then
	if [ $RC -ne 0 ]; then	
	    cat ${TMPFILE}.sqlfunc
	    cleanup 1 failure of $code
	fi
    else
	if [ -z "${quiet}" ]; then	
	    cat ${TMPFILE}.sqlfunc
	    printmsg warning, failure of $code
	fi
    fi

    if [ $RC -eq 0 ]; then
	sqlout=$(cat ${TMPFILE}.sqlfunc)
    fi
    if [ -n "${DEBUG}" ]; then
	echo \*\*\* sqlplus output is :
	cat ${TMPFILE}.sqlfunc
	echo \*\*\* end sqlplus output
    fi
    return $RC
}

# The Statemachine has to be shut down to do this
sm_is_running=`ps aux | grep $M80_BDF | grep -v grep | wc -l`
printmsg "The statemachine is running?: $sm_is_running"
if test $sm_is_running -gt 0; then
    printmsg The Statemachine is running in the $M80_BDF environment
    printmsg Please stop the Statemachine and take it out of cron
    printmsg Then try and run this script again
else

# run the sql statement against the db.
 code="
set serverout on
set timi on
exec dbms_output.enable(1000000);
exec p_task_context.archive_table;
 "
 sqlfunc

# regenerate the task_context_v;
m80 --oldschool -t patch -m CONTROLLER_DB
fi
cleanup $?
