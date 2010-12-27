#!/bin/sh



echo 'function te () { cat /var/www/html/${M80_BDF}/taskData/$1/[0-9]* | less ; } ; '



echo 'function desc () { t=$1 ; shift ; echo "$*" >> /var/www/html/${M80_BDF}/taskData/$t/description.txt ; } ; '



echo 'function kickAutomator () { test -n "$BRANCH" && ( eval $(bash -c "`crontab -l | grep startSM | grep $BRANCH/ | cut -d\" \" -f6-` ") &) ; } ; '



echo "function killAutomator { if test -n \"$1\"; then x=\$1; else x=\$USER; fi ; kill \$(eval ps -elf --cols 1024 | grep \$x | grep automator | grep -v grep | perl -ane 'print \"\$F[3]\n\"') ; } ;"



echo 'function whichAutomator { ps -elf --cols 1024 --forest | grep $M80_BDF | grep startSM | grep -v grep ; } ;'

echo 'function allAutomators { ps -elf --cols 1024 --forest | grep $USER | egrep \(startSM\|automator\) | grep -v grep ; } ;'




echo 'function rt { m80 --execute runTask $* ; } ;'



echo 'function dp { for x in $*; do mos deploy -m $x; done ; } ;'



echo 'function build { for x in $*; do mos build -m $x; done ; } ;'



echo 'function restart { m80 --execute restartTask.pl -task $* ; } ;'



echo 'function dc { task_id=$1; shift; m80 --execute dumpContext.pl -task_id $task_id > /tmp/dc.$task_id && (source /tmp/dc.$task_id && m80 --execute $*) && rm -f /tmp/dc.$task_id ; } ;'



echo 'function newInterfaceModule { m80 --execute expandTemplate.sh -m $1 -t $TOP/templates/interfaceModule.tmpl.m80 ; } ;'



echo 'function newProviderModule { m80 --execute expandTemplate.sh -m $1 -t $TOP/templates/providerModule.tmpl.m80 ; } ;'


