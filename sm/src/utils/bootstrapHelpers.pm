
#
# Implementation of state machine for domain specific languages
#

package bootstrapHelpers;
use shellHelpers;
use File::Basename;
use Carp;

sub moduleName {$_= basename(`pwd`); chomp; return $_}

sub startStateMachine {
    my $o=<<'EOF';
unset bootstrapScriptName
unset cron
unset bootstrap_context
docmd cd $CONTROLLER_DEPLOY_DIR
lockdir=$CONTROLLER_DEPLOY_DIR/lock
logdir=$CONTROLLER_DEPLOY_DIR/logs
mkdir -p $lockdir
docmdi rm -f nohup.out

printmsg automator.pl -quiet -config ./generatedConfig.xml.m80 -debug 1 -logDir $logdir -sleep 2 -lockdir $lockdir
nohup automator.pl -quiet -config ./generatedConfig.xml.m80 -debug 1 -logDir $logdir -sleep 2 -lockdir $lockdir &
EOF

    return $o;
}

sub _processRunning {
    my ($processname) = @_;
    $processname =~ s/^(.+?)\..*/$1/;
    my $o =<<EOF1;
    #
    # check if the cleaner ($processname.sh) is running
    ps aux --forest | grep $processname.sh | grep \$USER | grep -v grep | grep -v m80 > \$TMPFILE
EOF1

    $o .= '    ' . $processname . '_running=$(cat $TMPFILE)' . "\n";
    $o .= "    rm -f \$TMPFILE\n";
    $o .= '    if test -n "$' . $processname . '_running"; then' . "\n";
    $o .= '        cleanup 0 "looks like ' . $processname . ' is running ($' . $processname . '_running) - I am quietly exiting (cron=$cron)"' . "\n";
    $o .= "    fi\n";

}

sub stopStateMachine {
    my $o=<<'EOF';
    # the lock dir is determined in this script.
    terminateProcessWithExtremPrejudice  `statemachinePID`

    # force collections to reload in child tasks.
    docmd deleteContext.pl -task $task_id -tag loadCollectionsCompleted  
    docmd deleteContext.pl -task $task_id -tag collections
    docmd deleteContext.pl -task $task_id -tag _collections  # the statemachine must be caching this :(
    value=-force createContext.pl -task "$task_id" -tag "forceLoadCollections"
    unset loadCollectionsCompleted
    unset collections
    unset _collections
    unset bootstrap_context
    unset bootstrapScriptName
EOF

    return $o;
}

sub header {
    my $ret = ''; 
    my %arg = @_;
    if (defined $arg{getopts}) {
        $arg{getopts} .= ",(-c,cron),(s,bootstrapScriptName)";
    } else {
        $arg{getopts} = "(-c,cron),(s,bootstrapScriptName)";
    }
    print STDERR "expanding bootstrap header with: $arg{getopts}\n";
    # dedupe the require statements
    my %tmp;     @tmp{ @$arg{r}, ('CONTROLLER_DEPLOY_DIR', 'METADATA_deploy_PATH') } = 1;
    my @new_r = keys %tmp;
    $arg{r} = \@new_r;

    $ret .= shellHelpers::shellScript(%arg);

    $ret .=<<'EOF';
#
# bootstrapHelpers::header - boilerplate
#

if test -z "$bootstrapScriptName"; then
    bootstrapScriptName=$bootstrapStudy
fi

eval $(m80 --export)

terminateProcessWithExtremPrejudice () {
    loopy=true
    x=0
    while test -n "${loopy}"; do
	if test $x -gt 14; then
	    cleanup 1 exceeded capricious, arbitrary, and obscure threshold on trying to kill $*
	fi
	unset loopy
	for pid in $*; do 
	    kill $pid
            if test $? -eq 0; then
                loopy=true
            fi
	    sleep 1
	done
	((x=$x+1))
    done
}

statemachinePID () {
    cat $CONTROLLER_DEPLOY_DIR/lock/automator.pl.$M80_BDF.generatedConfig.xml.m80.pid
    if test $? -ne 0; then
        echo -n ""
    fi
}

EOF

    return $ret;
}

sub check_for_new_change {
    my $o =<<'EOF';

    #
    # if nothing has been submitted to p4, then just stop.
    #
    oldpwd=`pwd`
    cd $CONTROLLER_SRC_DIR/../..
    printmsg checking for p4 change in `pwd`/.last_p4change
    current_p4change=`(p4 changes -m 1 | awk '{print $2}')`
    if test -f .last_p4change; then
        last_p4change=`cat .last_p4change`
    fi
    printmsg "Checking if there are any new CLs. New=$current_p4change Old=$last_p4change"
    if test -n "$last_p4change"; then
         if test $current_p4change -eq $last_p4change; then
              cleanup 0 "No new CLs since the last run"
         fi
    fi
    echo $current_p4change > .last_p4change
    cd $oldpwd
EOF
    return $o;
}


sub body {
    my ($check_for_new_change) = @_;
    my $ret .=<<'EOF';

if test -n "$bootstrap_context"; then
    cleanup 0 "Bootstrap context ($bootstrap_context) has already been set - exiting 0"

elif test -n "$cron"; then
    my_sm_pid=`statemachinePID`
    if test -z "$my_sm_pid"; then
        printmsg I did not find a sm_pid - the statemachine is not running
        my_sm_is_running=
    else
        printmsg "I found a pid ($my_sm_pid), checking if the pid is running ..."
        my_sm_is_running=`ps aux --cols 4096 2>/dev/null | perl -nle "@x=split /\s+/; print if \\\$x[1] eq '$my_sm_pid'"`
    fi

    if test -n "$my_sm_is_running"; then
        cleanup 0 "StateMachine is running ($my_sm_is_running) - I am quietly exiting (cron=$cron)"
    fi

    #
    # also check if smBootstrap is running (but not me)
    # - this is 1) excludes grep 2) this bootstrap script only 3) not me
    ps aux --forest | grep $bootstrapScriptName | grep $0 | grep -v grep | grep -v $$ | grep -v m80 > $TMPFILE
    smBootstrap_running=$(cat $TMPFILE)
    rm -f $TMPFILE
    if test -n "$smBootstrap_running"; then
        printmsg "My pid is $$ and my process is $0"
        cleanup 0 "looks like smBootstrap is running ($smBootstrap_running) - I am quietly exiting (cron=$cron)"
    fi
EOF

    $ret .= check_for_new_change() if ($check_for_new_change);

    $ret .= _processRunning('cleanupRunningTasks');
    $ret .=<<'CLEANUP_STATE';
    # reset the db state of the statemachine
    if test -z "$task_id"; then
        task_ids=`runningTaskIds.pl`
    else 
        task_ids=$task_id
    fi
    for task_id in $task_ids; do
        cleanupRunningTasks.sh -t $task_id -c
    done
    resetStatemachineDBState.pl
CLEANUP_STATE

    $ret .= "    " . THIS_command();
    $ret .= "else\n" . stopStateMachine();
    $ret .=<<'EOF2';

#
# end bootstrapHelpers::header - boilerplate
#



EOF2

    return $ret;
}


sub footer {
    my $ret .=<<'EOF';




#
# bootstrapHelpers::footer - boilerplate
#

    #
    # This binds the output of test compilation to the current task_id.
    # I.e. this means that these tests will be run as children of the 
    # currently executing task.
    docmd metac -run $runset -study $METADATA_deploy_PATH/studies/$study.pl -Task $taskName -passThrough parent=$task_id
    docmd sh $METADATA_deploy_PATH/collections/studies/runsets/$runset.sh
    createContext.pl -task_id $task_id -tag bootstrap_context -value bootstrapFooter
fi
EOF

    $ret .= startStateMachine();
    $ret .=<<'EOF2';
cleanup 0

#
# end bootstrapHelpers::footer - boilerplate
#

EOF2

    return $ret;
}

sub THIS_command {
    my $ret .=<<'EOF';
# insert myself into the statemachine
docmd metac -run $bootstrapScriptName -study $METADATA_deploy_PATH/studies/$bootstrapScriptName.pl -Task runTestChassis
docmd $METADATA_deploy_PATH/collections/studies/runsets/$bootstrapScriptName.sh
EOF

    return $ret;
}

1;

    

    
