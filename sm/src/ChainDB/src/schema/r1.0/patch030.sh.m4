#!/bin/sh

PROGNAME=${0##*/}

#
# Function:	printmsg
#
# Description:	generic error reporting routine.
#               BEWARE, white space is stripped and replaced with single spaces
#
# $Id: buildPatch.sh.m4,v 1.2 2004/03/12 21:40:22 bretweinraub Exp $
#

printmsg () {
    if [ $# -ge 1 ]; then
	/bin/echo -n $PROGNAME: >&2
	while [ $# -gt 0 ]; do /bin/echo -n " "$1 >&2 ; shift ; done
	echo . >&2
    fi
}

localclean=true

localclean () {
    rm -f ${TMPFILE} /tmp/${PROGNAME}.$$.*
}

#
# Function:	cleanup
#
# Description:	
#
# $Id: buildPatch.sh.m4,v 1.2 2004/03/12 21:40:22 bretweinraub Exp $
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
	localclean # this function must be set
    fi
    if [ ${EXITCODE} -ne 0 ]; then
	# this is an error condition
	printmsg exiting with error code ${EXITCODE}
    else
	printmsg done
    fi
    exit ${EXITCODE}
}

#
# Function:	docmdqi
#
# Description:	execute a command quietly, but ignore the error code
#
# $Id: buildPatch.sh.m4,v 1.2 2004/03/12 21:40:22 bretweinraub Exp $
#

docmdqi () {
    if [ $# -lt 1 ]; then return; fi
    DQITMPFILE=/tmp/${PROGNAME}.$$.dcmdqi
    eval $* 2>&1 > ${DQITMPFILE}
    export RETURNCODE=$?
    if [ ${RETURNCODE} -ne 0 ]; then
	cat ${DQITMPFILE}
    fi
    rm -f ${DQITMPFILE}
    return $RETURNCODE
}
# $Id: buildPatch.sh.m4,v 1.2 2004/03/12 21:40:22 bretweinraub Exp $
# check for connectivity

sqlnettest () {
    TMPFILE=${TMPFILE:-/tmp/${PROGNAME}.$$.snt}
    
    sqlplus $1 2>&1 > ${TMPFILE} <<!
	whenever oserror exit failure;
	whenever sqlerror exit failure;
	select 1 from dual;
!
    
    if [ $? -ne 0 ]; then
	if [ -f ${TMPFILE} ]; then
	    cat ${TMPFILE}
	fi
	docmdqi rm -f ${TMPFILE}
	cleanup 1 the connect string of $1 is inoperable
    fi
    
    ERROR=$(grep -c 'ERROR' ${TMPFILE})
    
    if [ "$ERROR" -gt 0 ]; then
	cat $TMPFILE
	echo
	docmdqi rm -f ${TMPFILE}
	cleanup 1 the connect string of $1 is inoperable
    fi
    
    docmdqi rm -f ${TMPFILE}
}

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

usage () {
    cleanup 1 usage is $PROGNAME -d {debug .. transaction rolled back} -v {display sql code} -c [connect-string] -i {print info and exit} -n {no checking ... just execute code \(be careful\)}
}

while getopts :dvinc: c
    do case $c in
        c) DATABASE_NAME=$OPTARG;;
	d) debug=TRUE;;
	v) verbose=TRUE;;
	i) info=TRUE;;
	n) nocheck=TRUE;;
	:) printmsg $OPTARG requires a value
	   usage;;
	\?) printmsg unknown option $OPTARG
	   usage;;
    esac
done

releaseNumber=1.0
patchNumber=30
schemaName=ChainDB

buildDate="06/13/2006 17:46:44 MDT"
buildUser=bweinrau
buildHost=usbohp380-7
sourceCode=/usr/local/home/bweinrau/dev/sandbox/bweinrau/perf/perfsi_prod/etl/StateMachine/ChainDB/src/schema/src/CommandQueue.sql

if [ -n "${info}" ]; then
    echo ${PROGNAME} was built ${buildDate} on ${buildHost} by ${buildUser} from file ${sourceCode}.
    echo ${PROGNAME} is for schema ${schemaName} release ${releaseNumber}.
    exit 0
fi

test -n "${DATABASE_NAME}" || usage 

printmsg testing valid connectivity to ${DATABASE_NAME}
sqlnettest ${DATABASE_NAME}

hostname=$(hostname)
host_user=$(whoami)
host_path=$(pwd)/${PROGNAME}

# get release number  (as opposed to THIS patchs release number).

code="
  select 
    release 
  from 
    m80moduleVersion 
  where
    module_name = 'ChainDB';
"

sqlfunc

curReleaseNumber=$sqlout

# get patch number

code="
  select 
    NVL(max (patchlevel),0) 
  from
    m80patchLog 
  where
    module_name = '${schemaName}' 
  and
    release = '${curReleaseNumber}';
"

sqlfunc
curPatchNumber=$sqlout

if [ -z "${nocheck}" ]; then
    if [ "${releaseNumber}" != "${curReleaseNumber}" ]; then
	cleanup 3 r${releaseNumber} patch will not apply against r${curReleaseNumber} database
    fi
fi

if [ -z "${nocheck}" ]; then
    if (($patchNumber - $curPatchNumber != 1)); then
	cleanup 4 last patch applied was $curPatchNumber, patch $patchNumber failed
    fi
fi

code="
-- -*-perl-*-
-- M80_VARIABLE RDBMS_TYPE
-- M80_VARIABLE MODULE_NAME
-- M80_VARIABLE SEQ_INCREMENT_NO
-- M80_VARIABLE SEQ_INCREMENT_VAL

m4_include(m4/base.m4)
m4_include(db/generic/tables.m4)
m4_include(db/RDBMS_TYPE/RDBMS_TYPE.m4)

createM80StandardTable(task_command_queue,
		       (
			command			varchar2(4000),
			result_code		number,
			result_message		varchar2(512),
			is_processed		varchar2(1) default	'N' constraint task_command_ckcprocess check (is_processed is null or is_processed in ('Y', 'N')),
			at_time			DATE,
			),(task,action),,(INSTANTIATION_TABLE=true))


  INSERT INTO 
    m80patchLog (module_name, release, patchlevel, datetime_applied, hostname, host_user, host_path)
  VALUES
    ('${schemaName}', '${curReleaseNumber}', ${patchNumber}, SYSDATE, '${hostname}', '${host_user}', '${sourceCode}');

"

if [ -n "${debug}" ]; then
    code=$code"
    rollback;
"
fi

test -z "${verbose}" || eval 'echo; echo CODE IS: ; echo ; echo $code'

sqlfunc
echo $sqlout > ${PROGNAME}.$$.log

test -z "${verbose}" || eval 'echo; echo OUTPUT IS: ; echo ; cat ${PROGNAME}.$$.log; echo'

if [ -n "${debug}" ]; then
    printmsg transaction was rolled back in virtue of debug flag
fi

printmsg output was left in ${PROGNAME}.$$.log

cleanup 0

