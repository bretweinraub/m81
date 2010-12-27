#!/usr/bin/perl

=pod

=head1 NAME

automator.pl - The State Machine

=head1 SYNOPSIS

automator.pl is a generalized tool for contructing and executing
automation processes as hierarchical finite state machines (HFSM).
These state machines are described in XML configuration file(s) that
are read by the automator program on startup.

As opposed to using a threading model, parallelism is achieved through the use of the UNIX process model (fork()).

=head1 OPTIONS AND ARGUMENTS

=over 4

=item --config file.xml.m80 (required)

Specifies the config file used by the automator.  If this file can optionally contain any of 
templating directives available within m80.

=item --debug level (optional)

Specifies the debugging level; higher means more output.  Typically a level of one 

=item --maxLoops num (optional)

Specifies the life span of the process in terms of the number of times to loop through the execution main loop.
When this limit is reached, the first time through the main execution loop in which no active tasks are running
and no actions were taken, the script will exit.

=item --quiet (optional)

Suppress error reporting.  Especially useful when running from cron and you want to suppress repitive "unable to
obtain exclusive lock" messages.

=item --lockdir (optional)

Use this directory for the lock files (defaults to /tmp).

=item --MapDebug tag (Optional)

You can additional debugging around a the mapping of variables that match a  particular regular expression.  For
example:

  automator.pl -MapDebug M80_BDF

will mean additional log messages will be generated when mapping variables that contain M80_BDF in their tag.

=item --echo

When using a logging directory with the B<--logDir> flag log messages can be made to be additionally echo-ed to
STDOUT by using this flag.  Useful in debugging when it is desirable to both produce a log file as well as view
log messages on the terminal.

=item --sleep SleepVal (optional)

Allows you to set how long the automator will sleep between build loops.  The automator only sleeps if on actions
were taken in the current build loop.

=item --exitWhenIdle

When this option is set, the state machine will exit after all tasks are in either the succeeded or failed state.
This is useful when running an environment that has been pre-loaded with task data, such as in the case of regression
tests or inside a test chassis.

=back

=head1 DESCRIPTION

...

=head1 PREREQUISITES

...

=head1 CONCEPTS

automator.pl is a generalized tool for contructing and executing
automation processes as hierarchical finite state machines (HFSM).
These state machines are described in XML configuration file(s) that
are read by the automator program on startup.

The automator script uses an Oracle database schema to represent: 

- the current state of all running tasks, their hierachical
  relationships, and all contextual data associated with each task.

The main building blocks of these state machines are:

- tasks : the instantiation of a state machine described in the automator
 configuration XML.

- actions : this is a composite object.  It represents the state of a
 "task", the command associated with the state, and a set of
 transitions describing how to transition this task to next action.

- context : each text operates in its own context.  The context for each
 task is read/write and private for each task, and is made available
 to the command associated with an action via the process environment

=head1 References:

1. Multiple threads of execution in Perl : L<http://perl.hamtech.net/advprog/ch12_03.htm#ch12-pgfId-973352>
#
2. Use of the POSIX interface for waitpid(): L<http://perl.hamtech.net/cookbook/ch16_20.htm>
#
3. fork() : L<http://perl.hamtech.net/prog/ch03_040.htm#PERL2-CMD-FORK>

=head1 FEATURES 

=head2 MODULES

Modules is an optional XML block that can wrap a set of <tasks> and <actions>.  Its properties then apply
to all enclosed tasks and actions.

  <module name="MODULE_NAME"
          prop1="val1"
          ....
    <tasks/>
    <actions/>
  </module>

The valid properties are described below.  A state machine can process any number of modules. 

=head3 Command Prototypes

It is possible to define an "command prototype" for all actions in a module.  This means that if the command
is not defined in the <action> block itself the prototype is used to formulate the
command name for the action.  This might be useful if you want to use ANT (shudder)
for all the actions in a module:

  <module name="TERMITE"
	  deployDir="/usr/local/home/bweinrau/dev/sandbox/bweinrau/perf/main//sm/modules/termite"
	  commandPrototype="ant -f build.xml $(taskobj.actionname)">
...
    <tasks/>
    <actions/>
...
  </module> <!-- END MODULE -->


If you are using the StateMachine package of m80 repository macros, the Command Prototype can be expressed in
both the newAutomatorModule() and newDevelopmentAutomatorModule():

    newDevelopmentAutomatorModule(TERMITE,m80var(PERF_BUILD_MAP)/sm/modules/termite,[\$(taskobj.actionname)])

Note that the $ needs to be backslashed to tunnel through the expansion of the shell in m80.

All expansion rules apply to command prototypes.

=head3 Scoped Modules

B<A scoped module is one in which the action names are scoped to name of the module>; that is they are not global.  

This can be configured as follows:

  <module name="ALIHostAdminImpl"
          scoped="true"/>

What this means if there is an action in the above module called test, the real action name is called B<ALIHostAdminImpl-test>.

Scoped modules have no relationship to I<scoped> transition blocks, which are documented elsewhere.

Scoped modules are very useful for building interface/provider relationships between state machine modules, since you can
look up the name of a provider via a context variable and dispatch to the action of the provider.  It was just such a use
case that led the development of scoped modules.

=head2 PARALLELISM

The state machine supports "locking" of both tasks or actions based on either a hard-coded limit or a context-driven
limit.

  .... need example XML here ...

=head2 Action Timeouts

An action can be configured to be automatically failed after a certain amount of time:

  <action name="runSilentInstall"
	  timeout="900"
	  command="runSilentInstall.sh">

Or you can do it based on a context variable:

  <action name="runSilentInstall"
	  timeout="$(task.runSilentInstallTimeout)"
	  command="runSilentInstall.sh">

If you are using B<moduleHelpers> the format is like this:

                  {n => runSilentInstall,
		   extras => 'timeout="900"',
		   t => __SUCCESS__}]);

=head1 ENVIRONMENT VARIABLES

Environment variables set by this script:

=over 4

=item AUTOMATOR_WWWROOT

Set to the C<wwwroot> value from the configuration XML file.

=item AUTOMATOR_STAGE_DIR

The temporary work directory setup for a task by the automator.

=item PATH

The PATH variable has the module directory for the action, as well as "." appended to it.

=item parent_task_id

Will be set to a tasks parent task id.

=item actionname

Will be set to the name of the current action.

=item SMTP_SERVER

This is required to send spam email related to task failures.  The spam address is the set in the 
<ChainGang AdminAddress="$(env.CONTROLLER_SPAM_ADDRESS)"> XML element in the config file.

This can also be set on the command line with argument -smtpServer

=cut 

use File::Basename;
use lib dirname($0);
use lib dirname($0) . "/utils";

use Getopt::Long;
use Fcntl ':flock'; # import LOCK_* constants
use Data::Dumper;
use Carp;
use debug;
use xmlhelper;
use ChainDB;
use task;
use VariableExpander;
use assert;
use autoUtil;
use ContextExporter;
use POSIX ":sys_wait_h";
use POSIX qw(setsid);
use Net::SMTP;
use Sys::Hostname;
use re 'eval';
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval );
use Proc::ProcWrapper;
use Utils::PerlTools;

sub TV_INTERVAL {
    my ($t0,$t1) = @_;
    return tv_interval($t0,$t1) . " secs";
}

my $startTime = [gettimeofday];

require "options.pl";

delete $ENV{P4PORT};
delete $ENV{P4USER};
delete $ENV{P4PASSWD};
delete $ENV{P4CLIENT};

# 
# lock() : used to guarantee only a single copy of this tool runs.
#

sub lock {
    my ($lockfile) = @_ if @_;
    my $lockdir = dirname($lockfile);
    system( "mkdir -p $lockdir" );
    confess "$@" if $@;
    my $pid = `cat $lockfile.pid`;
    chomp($pid);
    open(LOCKFILE, ">$lockfile") or die "Can't open lockfile $lockfile: $!"; #
    unless (flock(LOCKFILE, LOCK_EX|LOCK_NB)) {
	unless ($quiet) {
	    system ("ps $pid") if $pid;
	    die basename($0) . "($$): Unable to obtain exclusive lock on $lockfile ... typically this means another automator\n is already running that is generating the same lock file name ($pid)." unless $quiet;
	}
	exit 0;
    }
    
    open(PIDFILE, ">$lockfile.pid");
    print PIDFILE $$ . "\n";
    close(PIDFILE);
}

$SIG{CHLD} = \&REAPER;
@reapList = ();
%running = ();
%xmlmodules = ();
%xmltasks = ();
%xmlactions = ();

my $skipSleep;

#
# REAPER is a signal handler - we therefore need to conform to the UNIX convention of 
# doing as little as possible in it.
#

# I'd be interested to know if the push(@reapList) call doesn't create a race condition
# if the signal handler is interrupted in the middle of that operation by another signal.
#
# now that I think about - the signal handler isn't live INSIDE the signal handler, which
# is why it has to be reinstalled at the end of the block .... which is probably why this
# has worked this wole time.  Leaving the old comment in for historical preservation.

sub REAPER {
    my $pid;
    while (($pid = waitpid(-1, &WNOHANG)) > 0) {
	$exit_value  = $? >> 8;
	$signal_num  = $? & 127;
	$dumped_core = $? & 128;

	if ($pid == -1) {
	    # no child waiting.  Ignore it.
	} elsif (WIFEXITED($?)) {
	    $debug->debug (1, "Process $pid exited") if $debug;
	} else {
	    $debug->debug (1, "false alarm on $pid") if $debug;
	}
#
#  TODO: is this next line really thread safe? - YES ... see the comment above.
#

	push(@reapList, { pid => $pid,
			  exit_value => $exit_value,
			  signal_num => $signal_num });
    }

    $skipSleep = 1;
    $SIG{CHLD} = \&REAPER;                  # install *after* calling waitpid
}

sub QUIESCE {
    $quiesced = "true";
    debug (1, "quiesced (SIGHUP), will exit as soon as no tasks are running (not accepting new requests)");
    # no real point in reinstalling the sig handler.
}

$SIG{HUP} = \&QUIESCE;

sub SEEYA {
    debug (1, "caught signal ... see ya");
    confess "caught signal";
}

$SIG{INT} = \&SEEYA;


sub _activeList {
    foreach $task_id (%activeList) {
	debug (1, "task_id $task_id is in the active list");
    }
    foreach my $type (keys (%running)) {
	foreach my $key (keys (%{$running{$type}})) {
	    foreach my $name (keys (%{$running{$type}{$key}})) {
		debug (1, "(parallel) $type.$key.$name : " . $running{$type}{$key}{$name});
	    }
	}
    }
	
    $SIG{USR1} = \&_activeList;
}


$SIG{USR1} = \&_activeList;

$sleep=30; 

$expansionStyle = "traditional";

my $lockdir=dirname($0);

my $smtpServer = $ENV{SMTP_SERVER};

GetOptions("config:s" => \my $configFile,
	   "debug:i" => \my $debugLevel,
	   "childDebug:i" => \my $childDebugLevel,
	   "echo" => \my $echo,
	   "once:s" => \my $once,
	   "quiet" => \$quiet,
	   "sleep:s" => \$sleep,
	   "logDir:s" => \my $logDir,
	   "lockdir:s" => \$lockdir,
	   "MapDebug:s" => \my $MapDebug,
	   "suppressParents" => \$suppressParents,
	   "smtpServer" =>  \$smtpServer,
	   "dumpxml" => \$dumpxml,
	   "printIndentyPath" => \$printIndentyPath,
	   "group:s" => \$group,
#
# By setting expansionStyle to "traditonal", you get the pre v.3 expansion style ; $(task.var) and $(env.var)
#
	   "expansionStyle" => \$expansionStyle,
	   "exitWhenIdle" => \my $exitWhenIdle,
	   "maxLoops:s" => \my $maxLoops);

die "please use -config" if ! $configFile;

$smtpServer ||= "localhost";

#my $lockfile = "$lockdir/" . basename($0) . ".$ENV{M80_BDF}." . basename($configFile);

#
# $identityFileBaseName : absolute path to the definitive "identity" file.
#

my $identityFileBaseName = "$lockdir/" . basename($0) . ".$ENV{M80_BDF}." . basename($configFile); 

if ($printIndentyPath) {
    print "$identityFileBaseName\n";
    exit 0;
}

lock($identityFileBaseName);

################################################################################################################################################################

my $runningFile = $identityFileBaseName . ".running";
system ("rm -f $runningFile");

my $debug = debug::new ('level' => ($debugLevel) ? $debugLevel : 0, 
			logDir => $logDir, 
			echo => $echo,
			logName => "StateExec");

debug(1, "state machine $identityFileBaseName is STARTING");


################################################################################################################################################################

# Look for a process group file

my $pw = Proc::ProcWrapper->new();
my $pgrp;

debug(1, "looking for process group log file");

if (open (PGRPFILE, "< $identityFileBaseName.pgrp")) {
    unless (read (PGRPFILE, $pgrp, 99)) {
	debug(1, "failed to read process group from $identityFileBaseName.pgrp"); 
    } else {
	debug(1, "previous process group was $pgrp"); 
    }
    close (PGRPFILE);
}

open (PGRPFILE, "> $identityFileBaseName.pgrp") ||
    confess "failed to open $identityFileBaseName.pgrp";

print PGRPFILE $pw->getPgrp();

debug(1, "wrote " . $pw->getPgrp() . " to $identityFileBaseName.pgrp");

$pw->killProcessGroup(pgrp => $pgrp, killSignals => ArrayRef(2,15,9));          # try and clean up after a previous state machine based on process group


################################################################################################################################################################


$xmlhelper = xmlhelper::new (configFile => $configFile, debug => $debug, dumpxml => $dumpxml);

confess "No ChainDB element found in $configFile " unless $xmlhelper->getProperty(xml)->{ChainDB}[0];

die "dumpxml is set .... exiting" if $dumpxml;

$expander = VariableExpander::new (debug => $debug, expansionStyle => $expansionStyle);
$db = ChainDB::new (debug => $debug, xmlhelper => $xmlhelper, expander => $expander);

$\ = "\n";
%activeList = ();

%spams = ();

################################################################################################################################################################

sub spammer () 
{
    my $arg = &_dn_options;
    my $task_id = $arg->{task_id};
    my $taskObject = $arg->{this};

#    print Dumper (keys (%{$taskObject}));

    $xml = $xmlhelper->getProperty(xml);
    $spamAddr= $expander->expand(text => $xml->{AdminAddress});

    if ($spamAddr && ! $spams{$task_id}) {
	$smtp = Net::SMTP->new($smtpServer);
	if ($smtp) {
	    debug(1, "connected to SMTP server " . $smtp->domain, $task_id);
	    $smtp->mail($ENV{M80_BDF} . '@' . hostname());
	    $smtp->to($spamAddr);
	    $smtp->data();
	    $smtp->datasend("To: $spamAddr\n");
	    if ($taskObject->{taskname}) {
		$smtp->datasend("Subject: action " . $taskObject->{actionname} . " of task " . $taskObject->{taskname} . " (" . $task_id . ") has failed");
	    } else {
		$smtp->datasend("Subject: task $task_id has failed, reason is " . ($arg->{failurereason} ? $arg->{failurereason} : "unknown"));
	    }
	    $smtp->datasend("\n\n");
	    $smtp->datasend("See log files at :\n");
	    $smtp->datasend("http://" . $ENV{CONTROLLER_HOST} . $expander->expand (text => $xmlhelper->getProperty(xml)->{urlbase}) . "/" . $task_id);
	    $smtp->datasend("\nOther information:\n\n");
	    foreach my $key (sort (keys (%{$taskObject}))) {
		$smtp->datasend("$key\t" . (length($key) < 8 ? "\t" : "") . $taskObject->{$key} . "\n")
		    unless ref($taskObject->{key});
	    }
	    $smtp->dataend();
	    $smtp->quit;
	    $spams{$task_id} = "true";
	} else {
	    debug (1, "failed to connect to SMTP server " . $smtpServer, $task_id);
	}
    } 
}

################################################################################################################################################################
sub setParallelKey
{
    my %args = @_;                                                              # load argument data

    my $type = $args{type};                                                     # load type data from the argument list
    my $parallelKey = $args{parallelKey};                                       # load parallelKey data from the argument list
    my $name = $args{name};                                                     # load name data from the argument list
    my $increment = $args{increment};                                           # load increment data from the argument list
    my $task_id = $args{task_id};                                               # load task_id data from the argument list

    my $cur = $running{$type}{$parallelKey}{$name};                             # cache current information

    my ($package, $filename, $line, $subroutine, $hasargs,
	$wantarray, $evaltext, $is_require, $hints, $bitmask) = caller(1);

    if ($cur) {
	$running{$type}{$parallelKey}{$name} += $increment;
    } else {
	$running{$type}{$parallelKey}{$name} = $increment;
    }
    
    debug(1, "$subroutine($task_id): running $type" . "s of type $name:$parallelKey is " . $running{$type}{$parallelKey}{$name} . ", old value was $cur" , $task_id);    

    confess "logic error parallel key set to < 0" 
	if $running{$type}{$parallelKey}{$name} < 0;
}

################################################################################################################################################################

#
# loadData : hashes up all the task and action data.
#

sub loadData {
    $xml = $xmlhelper->getProperty(xml);
#
#   Set an environment variable representing the WWWROOT for this config.
#

    $ENV{AUTOMATOR_WWWROOT} = $expander->expand($xml->{wwwroot});

    $debug->debugCmd(11, '{print "\$xml: "; print Data::Dumper::Dumper($main::xml);}');

    %xmltasks = ();
    %xmlactions = ();
    foreach my $module (@{$xml->{module}}) {
	debug (2, "evaluating xmltask data: $module->{name}");
	my $moduleName = $expander->expand(text => $module->{name});
	my $deployDir = $expander->expand(text => $module->{deployDir});
	my $scoped = $expander->expand(text => $module->{scoped});
        debug(1, "$moduleName module is scoped ($scoped)");
#
# Action Prototype gets expanded at runtime; not load time.
#
	my $commandPrototype = $module->{commandPrototype};
	debug (1, "read commandPrototype of $commandPrototype for module $moduleName") if $commandPrototype;
	$xmlmodules{$moduleName} = $module;

# 
# record module.xml last update time.
#

	$module->{'WRITETIME'} = (stat($module->{deployDir} . "/module.xml"))[9];

	foreach (@{$module->{tasks}}) {
	    foreach (@{$_->{task}}) {
		$this = $_;
		debug (2, "evaluating xmltask data: $this->{name}");
		$this->{moduleName} = $moduleName;
		$this->{deployDir} = $deployDir;
		my $name = $expander->expand( text => ($scoped ? $moduleName . "-" : "") . $this->{name});
		confess "Duplicate task block found for $name"
		    if exists $xmltasks{$name};
		$xmltasks{$name} = $this;
	    }
	}

	$debug->debugCmd(11, '{print "\$xmltasks: "; print Data::Dumper::Dumper(%main::xmltasks);}');

	foreach (@{$module->{actions}}) {
	    foreach (@{$_->{action}}) {
		$this = $_;
		$this->{moduleName} = $moduleName;
		$this->{deployDir} = $deployDir;
		if ($commandPrototype) {
		    $this->{commandPrototype} = $commandPrototype ;
		    debug (2, "setting action prototype to $commandPrototype for $this->{name}");
		}

		debug (2, "evaluating xmlaction data: $this->{name}");
                my $name = ($scoped ? $moduleName . "-" : "") . $this->{name};
		debug (2, "found scoped action name: $this->{name} -> $name") if $scoped;
		$name = $expander->expand( text => $name);
		confess "Action names with \".\"s are disallowed ($deployDir : $moduleName : $name)" if $name =~ /\./;
		confess "Duplicate action block found for $name"
		    if exists $xmlactions{$name};
		$xmlactions{$name} = $this;
	    }
	}
	$debug->debugCmd(11, '{print "\$xmlactions: "; print Data::Dumper::Dumper(%main::xmlactions);}');
    }

################################################################################# Constuct the _AllScopedActions.pl file ###################

    my %allScopedActions;                                                       # structure for dumping all scoped actions

    foreach $moduleName (keys(%xmlmodules)) {                                   # iterate over loaded modules
	my $thisModule = $xmlmodules{$moduleName};
	if ($thisModule->{scoped}) {                                            # if a scoped module
	    my @scopedActions = @{$thisModule->{actions}};                      # deconstruct the nested hashes and arrays left behind by XML::Simple

	    foreach $scopedActionList (@scopedActions) {
		foreach $thisaction (@{$scopedActionList->{action}}) {
		    my $actioname = $thisaction->{moduleName} . "-" .
			$thisaction->{name};
		    $allScopedActions{$actioname} = "1";                        # this data will be used later by the XMLEventDispatcher
		}
	    }
	}
    }

    open PERL, ">" . dirname($0) . "/_AllScopedActions.pl"                      # Create a permanent dump for internal representation
	or confess "Could not open _AllScopedActions.pl: $@";                   # of tasks and actions (used by XMLEventDispatcher)
    
    {
	local $Data::Dumper::Purity = 1;                                        # allows evals of dumped objects to be reconstructed correctly.
	local $Data::Dumper::Varname = "ScopedActions";                         # data will be reconstucted as this variable name

	print PERL Dumper (\%allScopedActions);                                 # dump to file
    }

    print PERL "\n1;\n";
    close PERL;                                                                 # close file descriptor

}

##############################################################################################################################################################
#
# If there is no "task" object; an alternate interface to fail a task.
#

sub failTask {
    my $arg = &_dn_options;

    &spammer(task_id => $arg->{task_id},
	     failurereason => $arg->{failurereason})
	unless $task::allTasks{$task_id};
    &task::failTask;
}

sub Delete {
    my ($task_id) = @_;

    $activeList{$task_id}->closelog if $activeList{$task_id};
    delete($activeList{$task_id});	    
}

sub buildRunList {
#
# This block is executed after we "restart"....
#
    foreach $task_id (keys (%activeList)) {
	my $thistask = $activeList{$task_id};
	my $status = $thistask->getProperty(status);
	if ($status =~ m/(failed|succeeded|error)/i) {
	    $debug->debug (1, "removing task $task_id from the active list: status $1", $task_id);
	    &Delete($task_id);
	}
    }

    return if $quiesced;

    if (! $loadOrphanedTasksOnce) {
	$db->runSQL("update task set status = 'new' where status = 'queued'");
	$loadOrphanedTasksOnce = "oui";
	my %inProgressTasks = %{$db->fetchDBTasks(status => [running,waiting], group => $group)};
	$debug->debug (1, "found $inProgressTasks{rows} task(s) in progress") if (%inProgressTasks);
	if ($inProgressTasks{rows} > 0) {
	    for (my $i = 0 ; $i < $inProgressTasks{rows} ; $i++) {
		my $lastAction = $inProgressTasks{ACTIONNAME}[$i];
		my $task_id = $inProgressTasks{TASK_ID}[$i];
		my $originalStatus = $inProgressTasks{STATUS}[$i];
		my $taskname = $inProgressTasks{TASKNAME}[$i];
		my $parent_task_id = $inProgressTasks{PARENT_TASK_ID}[$i];

		$debug->debug (1, "restarting waiting parent task named $taskname", $task_id)
		    if ($originalStatus =~ /waiting/);
#
# Do not restart tasks who are children and have a failed parent.
#
		if ($parent_task_id and $originalStatus =~ /running/) {
		    $debug->debug (1, "found restartable child task $task_id ; checking if parent ($parent_task_id) is still waiting");
		    my $parentStatus = task::fetchStatus (db => $db, task_id => $parent_task_id);
		    if ($parentStatus !~ /waiting/) {
			$debug->debug (1, "parent ($parent_task_id) of $task_id is no longer waiting");
			&failTask (db => $db, task_id => $task_id, failurereason => 'will not restart child task whose parent is not waiting');
			next;
		    } else {
			$debug->debug (1, "parent ($parent_task_id) of $task_id is still waiting, status $parentStatus");
		    }
		}
		if (! $lastAction) {
		    $db->runSQL("update task set status = 'new' where task_id = $task_id");
		    next;
		}
# XXX - I don't think this next block can be executed - so commenting out 10.10.2007 -ndw
# 		(! $lastAction) && do {
# 		    &failTask (db => $db, task_id => $task_id, failurereason => 'task is not defined or no start action');		
# 		    last;
# 		};
		$debug->debug(1, "last action of task_id $inProgressTasks{TASK_ID}[$i] is $lastAction", $task_id);
		if (not $expander->expand(text => $xmlactions{$lastAction}->{nonTransactional}) &&
		    (
		     (defined $xmlactions{$lastAction}->{maxFailures} && 
		      ($expander->expand(text => $xmlactions{$lastAction}->{maxFailures}) > $inProgressTasks{NUMFAILURES}[$i]))
		     ||
		     not (defined $xmlactions{$lastAction}->{maxFailures})
		     ))
		{
		    if ($expander->expand(text => $xmlactions{$lastAction}->{parent})  =~ m/^(true|y)/i) {
			$debug->debug(1, "ignoring restart of parent task : $task_id", $task_id);
		    } else {
			$debug->debug (1, "adding task_id $inProgressTasks{TASK_ID}[$i] to active list", $task_id);
			my $cur_action_id = $inProgressTasks{CUR_ACTION_ID}[$i];

			$activeList{$task_id} = &task::new (debug => $debug,
							    db => $db,
							    expander => $expander,
							    xmlhelper => $xmlhelper,
							    xml => $xmltasks{$taskname},
							    taskname => $taskname,
							    actionname => autoUtil::removeSingleQuotes($inProgressTasks{ACTIONNAME}[$i]),
							    status => ($originalStatus =~ /running/ ? 'recovering' : 'waiting'),
							    numfailures => $inProgressTasks{NUMFAILURES}[$i],
							    actionstatus => $inProgressTasks{ACTIONSTATUS}[$i], 
							    actionpid => $inProgressTasks{ACTIONPID}[$i], 
							    task_id => $task_id,
							    task_name => $inProgressTasks{TASK_NAME}[$i],
							    cur_action_id => $cur_action_id,
							    parent_task_id => $inProgressTasks{PARENT_TASK_ID}[$i],
							    type => 'restart',
							    spammerSub => \&spammer);
		    }
		} else {
		    debug (1, "cannot add task_id $inProgressTasks{TASK_ID}[$i] to active list; failing", $task_id);
		    debug (1, "nonTransactional => $xmlactions{$lastAction}->{nonTransactional}, maxFailures => $xmlactions{$lastAction}->{maxFailures}, numfailures => $inProgressTasks{NUMFAILURES}[$i]", $task_id);
		    failTask (db => $db, 
			      task_id => $task_id, 
			      failurereason => 'metadata did not support restart',
			      noparallel => 1); # do not manipulate parallel key data - since this task is orphaned
		}
	    }
	}
    }
    
    my %allTasks = %{$db->fetchDBTasks(status => [error,retry,new,cancel], group => $group)};
    
    for (my $i = 0 ; $i < $allTasks{rows} ; $i++) {
	if ($allTasks{STATUS}[$i] =~ /error/ ||
	    $allTasks{STATUS}[$i] =~ /retry/) {
	    
	    # TODO: pull requiredData validation into a subroutine.

	    my $task_id = $allTasks{TASK_ID}[$i];
	    my $actionname = $allTasks{ACTIONNAME}[$i];

	    assert::assert ("could not derive taskName from DB", $taskName = $allTasks{TASKNAME}[$i]);

	    debug (1, "found error task $task_id", $task_id);
	    debug (2, "found errored task $taskName", $task_id);
	    debug (3, "xmlaction keys: " .join (' ', keys(%xmlactions)), $task_id);
	    debug (3, "xmltask keys: " .join (' ', keys(%xmltasks)), $task_id);

#
# TODO: xmltask is a hash; maybe needs a better name; also the Dumper call above should be made on this variable.
#
	    my $ThisXMLTaskHash = $xmltasks{$taskName};
	    my $ThisXMLActionHash = $xmlactions{$actionname};

	    my $requiredData = $ThisXMLTaskHash->{requiredData};
	    my $taskContext = $db->loadTaskContext($task_id);

	    debug (2, "required data is $requiredData", $task_id);
#
#       $failReason : set to other the undef to fail the task.
#
	    my $failReason;

#
#       BEGIN requiredData expansion block.
#
	    foreach (split (/\s+/,$requiredData)) {
		$RequiredDatum = $_;
		debug (2, "validating existence of $RequiredDatum", $task_id);
		$expansion=$expander->expand(text => $RequiredDatum,taskContext => $taskContext);
		debug (2, "$RequiredDatum expanded to: $expansion", $task_id);
		unless ($expansion) {
		    $failReason="required data $RequiredDatum was not found for this task";
		    last;
		};
	    };

#
#       END requiredData expansion block.
#

	    debug (2, "processing error task $task_id; maxFailures : $ThisXMLActionHash->{maxFailures}, current failures : $allTasks{NUMFAILURES}[$i]", $task_id);

	    if (! $failReason && $ThisXMLActionHash->{maxFailures} && ($allTasks{NUMFAILURES}[$i] >= $ThisXMLActionHash->{maxFailures})) {
		$failReason = "exceeded failure threshold";
	    }
	    if (! $failReason && ($ThisXMLActionHash->{nonTransactional})) {
		$failReason = "errored action is not transactional" ;
	    }

	    if ($failReason) {
		&failTask (task_id => $task_id,
			   failurereason => $failReason ,
			   db => $db);
	    } else { 
		$activeList{$task_id} = 
		    &task::new (debug => $debug,
				db => $db,
				xml => $ThisXMLTaskHash,
				xmlhelper => $xmlhelper,
				expander => $expander,
				taskname => $taskName,
#			    mapper => $allTasks{MAPPER}[$i],
				status => $allTasks{STATUS}[$i],
				task_id => $task_id,
				task_name => $allTasks{TASK_NAME}[$i],
				type => 'retry',
				actionname => $allTasks{ACTIONNAME}[$i],
				parent_task_id => $allTasks{PARENT_TASK_ID}[$i],
				actionstatus => 'retry',
				spammerSub => \&spammer);
	    }
	}

	if ($allTasks{STATUS}[$i] =~ /new/) {
	    my $task_id = $allTasks{TASK_ID}[$i];
	    debug (1, "found new task $task_id", $task_id);
	    (! ($taskName = $allTasks{TASKNAME}[$i])) && do {
		&failTask (db => $db, task_id => $task_id, failurereason => 'no task name defined');		
		next;
	    };
	    debug (2, "found new task $taskName", $task_id);
	    debug (2, "xmlaction keys: " .join (' ', keys(%xmlactions)), $task_id);
	    debug (2, "xmltask keys: " .join (' ', keys(%xmltasks)), $task_id);

	    my $actionname = $expander->expand(text => $xmltasks{$taskName}->{startAction});
# use taskname as start action if no startAction is found.
	    $actionname = $taskName unless $actionname;
	    debug (3, "start action resolved to $actionname", $task_id);

	    (! $actionname) && do {
		&failTask (db => $db, task_id => $task_id, failurereason => 'task is not defined or no start action');		
		next;
	    };

	    my $xmltask = $xmltasks{$taskName};

	    my $requiredData = $xmltask->{requiredData};
#
#  XXX: Reloading the context again and again ; bad.
#

	    my $taskContext = $db->loadTaskContext($task_id);
	    debug (2, "required data is $requiredData", $task_id);
	    my $failTask="false";
	    my $this;
	    my $expansion;
	    foreach (split (/\s+/,$requiredData)) {
		$this = $_;
		debug (2, "validating existence of $this", $task_id);
		$expansion=$expander->expand(text => $this,taskContext => $taskContext, thistask => $thistask);
		debug (2, "$this expanded to: $expansion", $task_id);
		unless ($expansion) {
		    $failTask="true"; 
		    last;
		};
	    };

	    if ($failTask =~ m/true/) {
		&failTask (task_id => $task_id,
			   failurereason => "required data $this was not found for this task",
			   db => $db);
	    } else { 
		
#
# TODO : if start action is not found, fail the job.
#
		$activeList{$task_id} = 
		    &task::new (debug => $debug,
				db => $db,
				xml => $xmltasks{$taskName},
				xmlhelper => $xmlhelper,
				expander => $expander,
				taskname => $taskName,
				status => 'new',
				task_id => $task_id,
				task_name => $allTasks{TASK_NAME}[$i],
				parent_task_id => $allTasks{PARENT_TASK_ID}[$i],
				type => 'new',
				actionname => autoUtil::removeSingleQuotes($actionname),
				actionstatus => 'new',
				spammerSub => \&spammer);
		$activeList{$task_id}->setTaskData({status => "'queued'"});
	    }
	}

	if ($allTasks{STATUS}[$i] =~ /cancel/) {

	    my $task_id = $allTasks{TASK_ID}[$i];

	    doCancel ($task_id);
	}
    }

    debug(2, "leaving buildRunList", $task_id);
}

sub processTransitionCode
{
    my $arg = &_dn_options;
    
    my $transition = $arg->{transition};
    my $thistask = $arg->{thistask};
#	    $expansion=$expander->expand(text => $this,taskContext => $taskContext, thistask => $thistask);

    $code = $expander->expand (text => $transition->{code}, taskOBJ => $thistask);
    debug (2, "running transition code:\n$code", $task_id);
    eval $code;
    if ($@) {
	debug(1, "transition failed: $@", $task_id);
	$thistask->setTaskData({numfailures => $thistask->getProperty(numfailures) + 1,
				actionstatus => "'failed'",
				status => "'failed'",
				failurereason => "'transition failed: " . autoUtil::removeAllQuoteChars($@) . "'"});
    }
}

sub processTransitions
{
    my $arg = &_dn_options;
    my $ThisXMLActionHash = $arg->{ThisXMLActionHash};
    my $reapObject = $arg->{reapObject};
    my $thistask = $arg->{thistask};
# childStatus is set if this routine is called by (manageParents).
    my $childStatus = $arg->{childStatus};
    my $actionsTaken = 0;
    my $task_id = $thistask->getProperty(task_id);
    my $taskContext;
    my $taskHistory;

    my $processedTranstitions;

    $debug->debug (2, "entered processedTranstitions; reapObject is " . ((! $reapObject) ? "null" : "defined") . ", child status is $childStatus", $task_id);
    $debug->debug (2, "processingTransition: task_id($task_id), exitvalue($reapObject->{exit_value})", $task_id);

    foreach (@{$ThisXMLActionHash->{transitionMap}[0]->{transition}}) {
	my $fallthru;
	my $derivedValue;
	my $scopeValue;
	$transition=$_;
	$debug->debug (2, "processingTransition: task_id($task_id), transvalue($transition->{value}), type($transition->{type})", $task_id);
	foreach my $scope (@{$transition->{scope}}) {
	    $taskContext = $db->loadTaskContext($task_id) unless $taskContext;
	    $taskHistory = $db->loadTaskHistory($task_id) unless $taskHistory;
	    $derivedValue = $expander->expand(text => $scope->{field},
					      taskContext => $taskContext,
					      taskHistory => $taskHistory,
					      taskOBJ => $thistask);
	    $scopeValue = $scope->{value};
	    $debug->debug (1, "comparing scope $derivedValue =~ " . $scopeValue, $task_id);
	    if ($derivedValue =~ m/$scopeValue/) {
		$debug->debug (2, "scopetest valid for:  $derivedValue =~ " . $scopeValue, $task_id);
	    } else {
		$debug->debug (2, "scopetest not valid for:  $derivedValue =~ " . $scopeValue, $task_id);
		$fallthru = "true";
		break;
	    }

	}

	if (! $fallthru) {
	    $debug->debug (2, "($fallthru) matched scoped transition $derivedValue =~ " . $scopeValue, $task_id);
	    if ($arg->{reapObject}) { # not sure why testing $reapObject itself doesn't seem to work here)
		$debug->debug (2, "checking $reapObject->{exit_value} =~ m/$transition->{value}/ for task " . $task_id);
		if ($transition->{type} =~ /returnCode/) {
		    $debug->debug(3, "evaluating $transition->{type} transition", $task_id);

                    #
                    # bret - if $reapObject->{exit_value} = 10 || 20, etc... and
                    #   $transition->{value} is 0 - then a failed action will transistion to success.
                    #
		    if ($reapObject->{exit_value} =~ m/$transition->{value}/) {
			$debug->debug(3, "matched $transition->{value}", $task_id);
			$processedTranstitions = "true";

			processTransitionCode (transition => $transition, thistask => $thistask);
			goto endTransition;
		    }
		} elsif ($transition->{type} =~ /parent/) {
		    1;
		} else {
		    confess "transition type $transition->{type} not implemented";
		}
	    } else { #parent processing.
		$processedTranstitions = "true";
		if ($transition->{type} =~ /parent/ && $transition->{value} =~ /$childStatus/) {

                    # decrement the running variables associated with this task.
		    my $actionname = autoUtil::removeSingleQuotes($thistask->{actionname});
		    my $taskname = autoUtil::removeSingleQuotes($thistask->{taskname});

		    my $ThisXMLTaskHash = $xmltasks{$taskname};

		    my $taskContext = $db->loadTaskContext($task_id) unless $taskContext;
		    
		    my $taskParallelKey = $expander->expand (text => $ThisXMLTaskHash->{parallelismKey}, taskContext => $taskContext) || "nokey";
		    my $actionParallelKey = $expander->expand (text => $ThisXMLActionHash->{parallelismKey}, taskContext => $taskContext) || "nokey";
		    
		    setParallelKey ( task_id => $task_id,
				     type => 'task',
				     parallelKey => $taskParallelKey,
				     name => $taskname,
				     increment => -1 );

		    setParallelKey ( task_id => $task_id,
				     type => 'action',
				     parallelKey => $actionParallelKey,
				     name => $actionname,
				     increment => -1 );

		    processTransitionCode ( transition => $transition,
					    thistask => $thistask);		    

		    goto endTransition;
		}
	    }
	}
	undef $fallthru;
    } 

    if (! $ThisXMLActionHash) {
	$thistask->setTaskData({numfailures => $thistask->getProperty(numfailures) + 1,
				actionstatus => "'failed'",
				status => "'failed'",
				failurereason => "'no transition was found for return code $reapObject->{exit_value}, task " . $task_id . "'"});
	confess ("logic error no XML action hash variable available in processTransitions");
    }

    if (! $processedTranstitions) {
	$debug->debug (1, "no transition was found for return code $reapObject->{exit_value}, task " . $task_id . "; considering this error", $task_id);

	$thistask->setTaskData({numfailures => $thistask->getProperty(numfailures) + 1,
				actionstatus => "'failed'",
				status => "'failed'",
				failurereason => "'no transition was found for return code $reapObject->{exit_value}, task " . $task_id . "'"});
    }
  endTransition:
    $actionsTaken++;

    return $actionsTaken;
}

sub reap {
    my $actionsTaken = 0;

    while ($reapObject = pop (@reapList)) {
	my $pid = $reapObject->{pid};
	$debug->debug (PID, "pid that exited is $pid");
	unless ($pidMap{$pid}) {
	    $debug->debug (1, "SORROW: pid $pid was reaped but could not associated with a task");
	    next;
	}
	my $thistask = $pidMap{$pid};
	delete ($pidMap{$pid});
#
# TODO: should generate a warning if we are "reaping" and not finding a task object.
#
	next unless $thistask;

	my $task_id = ($thistask ? $thistask->getProperty(task_id) : -1);
	my $actionname=autoUtil::removeSingleQuotes($thistask->getProperty(actionname));
	my $taskname=autoUtil::removeSingleQuotes($thistask->getProperty(taskname));

	$debug->debug (1, "reap: reaping $reapObject->{pid}, error code $reapObject->{exit_value}, signal $reapObject->{signal_num}", $task_id);
	$debug->debug (1, "pid $reapObject->{pid} seems associated with task " . $thistask->getProperty(task_id) . ", action $actionname", $task_id);

	my $ThisXMLActionHash = $xmlactions{$actionname};

	print Dumper($ThisXMLActionHash) if ($debug->getProperty(level)) >= 4 ;

# TODO: need to update this for parallelismKey
	my $actionParallelKey = $thistask->getProperty(actionParallelKey);
	my $taskParallelKey = $thistask->getProperty(taskParallelKey);

	setParallelKey ( task_id => $task_id,
			 type => 'task',
			 parallelKey => $taskParallelKey,
			 name => $taskname,
			 increment => -1 );

	setParallelKey ( task_id => $task_id,
			 type => 'action',
			 parallelKey => $actionParallelKey,
			 name => $actionname,
			 increment => -1 );


# 	debug(PID,"reap(): running actions of type $actionname:$actionParallelKey is " . --$running{action}{$actionParallelKey}{$actionname}, $task_id)
# 	    if $running{action}{$actionParallelKey}{$actionname};
	
# 	debug(PID,"reap(): running tasks of type $taskname:$taskParallelKey is " . --$running{task}{$taskParallelKey}{$taskname}, $task_id)
# 	    if $running{task}{$taskParallelKey}{$taskname};

#
# TODO: need to define a transition type called "content"....
#

#
# TODO: cannot transition based on a signal number.
#

	if ($reapObject->{signal_num} > 0) {
	    $thistask->setTaskData({numfailures => $thistask->getProperty(numfailures) + 1,
				    actionstatus => "'failed'",
				    status => "'failed'",
				    failurereason => "'caught signal $reapObject->{signal_num}'"
				    });
	    last;
	}

#
# TODO: If there is only one transition this will not be an array.....
#

	$actionsTaken += &processTransitions(ThisXMLActionHash => $ThisXMLActionHash,
					     reapObject => $reapObject,
					     thistask => $thistask);
					     
    }
    $stop = "true" if $once;
    return $actionsTaken;
}

#
# mashHash .... mashes two hash tables together.
#

sub mashHash {return @_;}

#
# Performs expansion and "argument folding"  things inside quotes become single arguments to exec();
#
# See man execvp(2) or the bash source code (execute_cmd.c).

sub expandCommand {
    my ($command, $taskContext, $thistask) = @_;

    $debug->debug(1, "expand: pre command is $command");

# wrap the command we execute in a "/bin/sh -c '$command'"
# This guarantees we will really exec something valid, regardless if $command is bogus.
    $command =~ s/\$\(([^.]+)\.([^\)]+)\)/$expander->_expand(type=> $1, variable => $2, taskContext => $taskContext, taskOBJ => $thistask)/ge;
    $command =~ s/^\'(.+?)\'$/$1/;   # annoying edge case - for some reason commandPrototypes end up with multiple quote characters. XXX 
    $command = "/bin/bash --noprofile --norc -c '" . $command . "'";

    $debug->debug(1, "expand: post command is $command", $task_id);

    @args = split /\s+/, $command;
    my @execList = ();
    my $folding;
    my $pusharg;
    foreach (@args) {
	debug (4, "there are $#execList args in \@execList", $task_id);		
	$thisArg=$_;
	debug (4, "examing argument $_", $task_id);	
	if ($folding) {
	    $pusharg = $thisArg;
	    $pusharg =~ s/\'//g;
	    $folding.=" $pusharg";
	    debug (4, "folded argument is now $folding", $task_id);
	    $thisArg =~ m/\'$/ && do {
		debug (4, "pushing $folding", $task_id);
#		push(@execList,"'" . $folding . "'");
		push(@execList,$folding);
		debug (4, "there are $#execList args in \@execList", $task_id);		
		$folding="";
	    };

	} else {
	    if ($thisArg =~ m/^\'.+?\'$/) {
		$thisArg =~ s/\'//g;		
		debug (4, "pushing $thisArg", $task_id);
		push(@execList,$thisArg);
		debug (4, "there are $#execList args in \@execList", $task_id);		
	    } elsif ($thisArg =~ m/^\'/) {
		$thisArg =~ s/\'//g;
		$folding=$thisArg;
		debug (4, "folded argument is now $folding", $task_id);
	    } else {
		$thisArg =~ s/\'//g;	    
		push (@execList, $thisArg);
	    }
#	  lastFoldParse:
	}	    
    }

    for (my $i = 0 ; $i <= $#execList ; $i++) {
	debug (3, "expanded argument $i is $execList[$i]", $task_id);
    }
    return \@execList;
}

sub scalarValue {return $_[0];}

sub eval2value {
    if ($_[0]) { 
	my $ret = eval $_[0] ;
	return $ret if (! $@);
    }
    return $absolutelyNothing;
}

###############################################################################################################################################
sub execute {
    my $actionsTaken = 0;

    $debug->debug (3, "entered main::execute", $task_id);

#
# loop through all the keys on the active list; but lower task_ids first.
# This gives older tasks some "priority" in the processing.
#
    
    my $contextBundle = {};
    $db->fetchContextBundle(taskList => \%activeList,
			    returnHashRef => $contextBundle);

    foreach my $task_id (sort {$a <=> $b} keys (%activeList)) {
	$debug->debug(2, "execute: activeList task_id: $task_id", $task_id);
	my $thistask = $activeList{$task_id};
	my $actionname = autoUtil::removeSingleQuotes($thistask->{actionname});
	my $taskname = autoUtil::removeSingleQuotes($thistask->{taskname});
	my $status  = $thistask->{status};
	my $type = $thistask->{type};
	my $recoverdWaitingTask = 1                                             # in this case we adjust internal structures, but
	    if $status =~ /waiting/ and                             # do not restart the task or alter its state.
	    $type =~ /restart/;

	$debug->debug(1, "processing task $taskname, status $status, type $type (recovery? $recoverdWaitingTask)");

	next if $thistask->getProperty(status) =~ /running/ && $thistask->getProperty(actionstatus) =~ /running/;

	unless (exists $xmlactions{$actionname}) {
	    $debug->debug (1, "failing task since action block for action $actionname not found",$task_id);
	    $thistask->setTaskData({status => "'failed'",
				    failurereason => "'no action named " . $actionname . " found'"});
	    &Delete($task_id);	    
	    next;
	}

	$debug->debug (2, "execute: task name is $taskname", $task_id);
	$debug->debug (2, "execute: action name is $actionname", $task_id);

	$ThisXMLActionHash = $xmlactions{$actionname};
	$ThisXMLTaskHash = $xmltasks{$taskname};

	# TODO: eventually I see all debug statements to be peformed via a macro
	if ($debugLevel >= 2) {                                                 # perf enhancement .... dont format if its not ok to debug()
	    $debug->debug (2, "task XML is " . Dumper($ThisXMLTaskHash), $task_id);
	    $debug->debug (2, "action XML is " . Dumper($ThisXMLActionHash), $task_id);
	}
	
	$debug->debug (2, "main::execute maxFailures for $thistask->{actionname} is $ThisXMLActionHash->{maxFailures}", $task_id);
	$debug->debug (2, "main::execute nonTransactional for $thistask->{actionname} is $ThisXMLActionHash->{nonTransactional}", $task_id);

	my $taskContext;

	if ($thistask->getProperty(status) =~ /queued/ && $thistask->getProperty(task_context)) {
	    $taskContext = $thistask->getProperty(task_context); 
	} else {
	    $taskContext = $db->LoadContextFromBundle (contextBundle => $contextBundle,
						       task_id => $task_id);
	}

	$thistask->setProperty("task_context", $taskContext);

	# check maxParallelism here.

	my $taskParallelKey = $expander->expand (text => $ThisXMLTaskHash->{parallelismKey}, taskContext => $taskContext);

	$taskParallelKey = "nokey" unless $taskParallelKey;

	my $actionParallelKey = $expander->expand (text => $ThisXMLActionHash->{parallelismKey}, taskContext => $taskContext);

	$actionParallelKey = "nokey" unless $actionParallelKey;

	$thistask->setProperty(taskParallelKey, $taskParallelKey);
	$thistask->setProperty(actionParallelKey, $actionParallelKey);

	if (exists $ThisXMLTaskHash->{maxParallelism}) {
	    my $maxParallelism = $expander->expand (text => $ThisXMLTaskHash->{maxParallelism}, taskContext => $taskContext);

	    if ($running{task}{$taskParallelKey}{$taskname} && $maxParallelism && $running{task}{$taskParallelKey}{$taskname} >= $maxParallelism) { 
		$debug->debug( 2, "task $task_id FAILED maxParallelism test for task $taskname:$taskParallelKey ($running{task}{$taskParallelKey}{$taskname} task(s) are already running)", $task_id);
		next;
	    }
	}

	if (exists $ThisXMLActionHash->{maxParallelism}) {
	    my $maxParallelism = $expander->expand (text => $ThisXMLActionHash->{maxParallelism}, taskContext => $taskContext);

	    if ($running{action}{$actionParallelKey}{$actionname} && $maxParallelism && $running{action}{$actionParallelKey}{$actionname} >= $maxParallelism) { 
		$debug->debug( 2, "task $task_id FAILED maxParallelism test for action $actionname:$actionParallelKey ($running{action}{$actionParallelKey}{$actionname} action(s) are already running)", $task_id);
		next;
	    }
	}

	# check maxfailures
	
	if ((autoUtil::removeSingleQuotes($thistask->{status}) =~ /running/ and
	     autoUtil::removeSingleQuotes($thistask->{status}) =~ /error/) or	     
	    autoUtil::removeSingleQuotes($thistask->{actionstatus}) =~ /failed/) {
	    if (! $ThisXMLActionHash->{nonTransactional}) {
		if ($thistask->{numfailures} >= $ThisXMLActionHash->{maxFailures}) {
		    $thistask->setTaskData({status => "'failed'",
					    failurereason => "'failure threshold exceeded'"});
		    next;
		}
	    } else {
		$thistask->setTaskData({status => "'failed'",
					failurereason => "'metadata did not support restart'"});
		next;
	    }
	}
	
	next if (autoUtil::removeSingleQuotes($thistask->{status}) =~ /running/ &&
		 autoUtil::removeSingleQuotes($thistask->{actionstatus}) =~ /running/);
	
	$debug->debug(2, "this task current status is $thistask->{status}", $task_id);

	unless ($recoverdWaitingTask) {

	    next if (autoUtil::removeSingleQuotes($thistask->{status}) =~ /waiting/ &&
		     autoUtil::removeSingleQuotes($thistask->{actionstatus}) =~ /waiting/);

	    my  $command = $ThisXMLActionHash->{command};
	    $debug->debug (1, "command read from XML action is : $command", $task_id);
	    unless ($command) {
		$command = $ThisXMLActionHash->{commandPrototype} || "$actionname.sh" ;
		$debug->debug (1, "XML action not found, using inferred command of $command", $task_id);
	    }
	    $debug->debug (1, "command has resolved to $command", $task_id);
	
# XXX: This model of doing setTaskData is basically non-rentrant; and needs to get encapsulated in a PL/SQL block.
	
	    $thistask->setTaskData({status => "'running'", 
				    actionstatus => "'starting'",
				    actionname => "'" . $actionname . "'"});
	

	    $debug->debugCmd(4, "{print Data::Dumper::Dumper($thistask));}", $task_id)
		if ($debugLevel >= 4);

#
# Generate staging directory and assign to environment variable.
#

	    my $stageDir= $expander->expand(text=> $xmlhelper->getProperty(xml)->{stageDir});
	    if ($stageDir) {
		$stageDir .= "/$task_id";
		system ("mkdir -p $stageDir");
		confess "$@" if $@;;
		$ENV{AUTOMATOR_STAGE_DIR} = "$stageDir";
	    }

	    my %unifiedContext = (%ENV, %{$taskContext});

	    $debug->debug (2, "keys of hash mash are" . join ",", keys (%unifiedContext));
	    my @execList = @{&expandCommand($command, \%unifiedContext, $thistask)};

	    $debug->debug (1, "exec list is (" . join (",", @execList) . ")", $task_id);
	    
	    my $action_id = $thistask->getProperty(cur_action_id);
	    
	    $fileout = $thistask->getProperty(outputdir) . "/" . $action_id . "." . $actionname;
	    $debug->debug (1, "writing STDOUT to $fileout", $task_id);
	    my $wwwroot = $expander->expand(text => $xmlhelper->getProperty(xml)->{wwwroot});

	    # link the parent task ids
	    my $parent_task_id = $thistask->getProperty(parent_task_id);
	    if ($parent_task_id) {
		$debug->debug  (1, "ln -s " . $wwwroot . "/" . $parent_task_id . " " . $thistask->getProperty(outputdir) . "/" . $parent_task_id);
		$debug->debug  (1, "ln -s " . $thistask->getProperty(outputdir) . " " . $wwwroot . "/" . $parent_task_id . "/" . $task_id);
	    }

	    $date=`date`;
	    chomp($date);
	    my $mapper = $thistask->getMapper();
	    my @exportData = () ;                                                   # unravel task hierarchy and determine which env variables to export
	    $thistask->buildExportData(taskContext => $taskContext,
				       arrayref => \@exportData);                   # pass by reference (routine will load this array).
	    $debug->debug (1, "export data derived as " . join (",", @exportData));
	    my $export_filter = task::getExportFilter(\@exportData);
	    $debug->debug (1, "export filter derived as $export_filter");
	    $thistask->setTaskData({export_filter => "'" . $export_filter . "'"})
		if $export_filter;

	    $pid = fork();                                                          # The big moment
	    if ($pid) {                                                             # I am the parent process in virtue of having the PID of the child
		$debug->debug (1, "continuing to process in the parent, child pid is $pid", $task_id);

		$actionsTaken++;                                                    # mark this so we skip over our sleep loop
		
		$thistask->setTaskData({actionpid => $pid,
					actionstatus => "'running'"});
		$pidMap{$pid} = $thistask;
		$debug->debug(PID, "assigned pid entry $pid to $thistask", $task_id);

		# update the parallel keys ("default" if none specified).  this is checked in the "exec" code to determine whether it is valid
		# to start new tasks or not.

		setParallelKey ( task_id => $task_id,
				 type => 'task',
				 parallelKey => $taskParallelKey,
				 name => $taskname,
				 increment => 1 );

		setParallelKey ( task_id => $task_id,
				 type => 'action',
				 parallelKey => $actionParallelKey,
				 name => $actionname,
				 increment => 1 );

#
# set up a timeout if required.
		my $timeout = $expander->expand (text => $ThisXMLActionHash->{timeout}, taskContext => $taskContext );
#
		$db->runSQL("insert into task_command_queue (command,at_time) values ('cancelRunningAction($action_id)',SYSDATE+$timeout/86400)")
		    if $timeout;

	    } else {
		$db = undef;                                                    # don't play w/ the DBI handle in the child.
		$debug->{level} = $childDebugLevel 
		    if defined ($childDebugLevel);
		$debug->debug (1, "before exportContext M80_BDF is $ENV{M80_BDF}", $task_id);
		ContextExporter::exportContext ( mapper => $mapper, 
						 debug => $debug,
						 unifiedContext => \%unifiedContext,
						 task_id => $task_id,
						 MapDebug => $MapDebug,
						 exportData => \@exportData);

		$debug->debug (1, "after exportContext M80_BDF is $ENV{M80_BDF}", $task_id);

		open STDOUT, ">> $fileout.0";
		open STDERR, ">> $fileout.1";
		print STDOUT "\n$date($$) : ---------- BEGIN EXECUTION ----------\n";
		print STDOUT "\n" . join (' ' , @execList) . "\n";
		print STDERR "\n$date($$) : ---------- BEGIN EXECUTION ----------\n";
		
		my $deployDir = $ThisXMLActionHash->{deployDir};
		$debug->debug(1, "changing directory to " . $deployDir , $task_id);
		chdir($deployDir) or die "failed to chdir to $deployDir";
		if ($debug->getProperty(level) >= 4) {
		    foreach (keys (%ENV)) {
			print STDERR "$$: key $_ is set";
		    }
		    system("env");
		}
		foreach (keys (%ENV)) {
		    $debug->debug (2, "key $_ is set to " . $ENV{$_} );
		}


# 
# If exporting magic variables you'll want to make sure they pass through any export filter.
# 
# See task:: getExportFilter()
#
		
		$ENV{PATH} = ".:" . $ENV{PATH}; 
		$ENV{parent_task_id} = $thistask->getProperty(parent_task_id);
		$ENV{actionname} = autoUtil::removeSingleQuotes ($thistask->getProperty(actionname));
		$ENV{action_id} = $action_id;                                       # export the current action id 
		$debug->debug (1, "automator.pl signing off, child process exec is : " . join(" ", @execList) , $task_id);	    
		$debug->debug (1, "before exec M80_BDF is $ENV{M80_BDF}", $task_id);

		exec (@execList);  # never returns .... Why do people always people put this in a comment !?!?

		# turns out it returns if the env is too big - make a guess at the size
		my $env_size = 0;
		my $env_dump = '';
		for $k (sort keys %ENV) {
		    $env_dump .= $k . $ENV{$k} . "\n";
		    $env_size += length($k) + length($ENV{$k});
		}
		die "Env Dump:\n$env_dump\n\n\ninsanity ... you've been banished to the Nth level of hell -- estimated env size of the subshell is: $env_size ";
	    }
	} else {
	    $debug->debug(1, "rigged parallel key data for restarted (sort of) waiting tasks name ($taskname)", $task_id);
	    setParallelKey ( task_id => $task_id,
			     type => 'task',
			     parallelKey => $taskParallelKey,
			     name => $taskname,
			     increment => 1 );

	    setParallelKey ( task_id => $task_id,
			     type => 'action',
			     parallelKey => $actionParallelKey,
			     name => $actionname,
			     increment => 1 );
	    $thistask->setTaskData(status => "'waiting'",
				   actionstatus => "'waiting'");
	    $thistask->{type} = undef;
	    
	}
    }
    $debug->debug (3, "exiting main::execute", $task_id);
    return $actionsTaken;
}


sub debug {$debug->debug(@_[0],@_[1],@_[2]);}

sub _processParent {
    my $arg = &_dn_options;
    my %parents  = %{$arg->{data}};
    my $i = $arg->{index};
    my $status = $arg->{transition};
    my $task_id = $arg->{task_id};
    my $taskname = $parents{TASKNAME}[$i];
    my $actionname = $parents{ACTIONNAME}[$i];

    assert::assert("status must be defined in _processParent", defined($status));

    $debug->debug(1,"in _processParent ($i, $status, $task_id, $taskname, $actionname)", $task_id);

    my $thistask = &task::new (debug => $debug,
			       task_id => $task_id,
			       taskname => $taskname,
			       xmlhelper => $xmlhelper,
			       actionname => $actionname,
			       expander => $expander,
			       db => $db,
			       spammerSub => \&spammer);

    my $ThisXMLActionHash = $xmlactions{$actionname};
    processTransitions(ThisXMLActionHash => $ThisXMLActionHash,
		       thistask => $thistask,
		       childStatus => $status);
# right now the task is STILL in a waiting state until execute() sets it back to running
# updating the processed row allows allready processed children to be excluded from future transitions

    $db->runSQL ("update task set processed = 1 where parent_task_id = $task_id");
    $debug->debug(1,"leaving _processParent", $task_id);
}

##
#
# describe: takes a hash and unravels it into a string.
# useful for generating a debugging message.


sub describe {
    my %hash = %{$_[0]};
    my $ret;

    foreach my $key (keys(%hash)) {
	$ret .= ($ret ? " " : "") . "$key=\"$hash{$key}\"";
    }
    $ret;
}

sub manageParents {
    $debug->debug(2,"in manageParents");

    $db->loadSQL("select * from child_status_v where parent_status = 'waiting' and num_child_tasks > 0", \my %parentData);
    
    my %parents = ();
    my $numActions = 0;

    for (my $i = 0; $i < $parentData{rows} ; $i++) {                            # initialize the %parents rows
	my $task_id = $parentData{TASK_ID}[$i];

	$parents{$task_id}{child_tasks} = 0;
	$parents{$task_id}{finished} = 0;
	$parents{$task_id}{succeeded} = 0;
	$parents{$task_id}{failed} = 0;
    }

    for (my $i = 0; $i < $parentData{rows} ; $i++) {
	my $task_id = $parentData{TASK_ID}[$i];
	my $child_status = $parentData{CHILD_STATUS}[$i];
	my $num_child_tasks = $parentData{NUM_CHILD_TASKS}[$i];

	$parents{$task_id}{child_tasks} += $num_child_tasks;
#	$parents{$task_id}{finished} = 0;
	$parents{$task_id}{index} = $i;

	if ($child_status =~ /succeeded/) {
	    $parents{$task_id}{finished} += $num_child_tasks;
	    $parents{$task_id}{succeeded} += $num_child_tasks;
	} elsif ($child_status =~ /(failed|canceled)/) {
	    $parents{$task_id}{finished} += $num_child_tasks;
	    $parents{$task_id}{failed} += $num_child_tasks;
	}
    }
    foreach my $task_id (keys(%parents)) {
	my %this = %{$parents{$task_id}};

	if ($this{finished} == $this{child_tasks}) {
	    $debug->debug(1, "parental transition for task_id $task_id is " . 
			  ($this{succeeded} == $this{child_tasks} ? "ALLSUCCESS" : "ANYFAIL") . " " . describe(\%this),
			  $task_id);
	    $numActions += _processParent(data => \%parentData, 
					  index => $this{index}, 
					  task_id => $task_id,
					  transition => ($this{succeeded} == $this{child_tasks} ? "ALLSUCCESS" : "ANYFAIL"));
	}
    }
    $debug->debug(2,"leaving manage parents");
    return $numActions;
}

sub processCommandQueue {
    my %commandsToProcess = ();

    $db->loadSQL("select * from task_command_queue where is_processed <> 'Y' and (at_time is null or at_time < SYSDATE)", \%commandsToProcess);
#    print Dumper(%commandsToProcess) if $commandsToProcess{rows} > 0;
    for (my $i = 0; $i < $commandsToProcess{rows} ; $i++) {
	my $code = eval "sprintf (\"" . $commandsToProcess{COMMAND}[$i] . "\")";
	debug (1, "running command queue statement \"$code\"");
	my $returndata;
	eval {
	    $returndata = eval $code;
	};
	$returndata = $@ if $@;
	debug (1, "running command queue statement \"$code\" returned data \"$returndata\"");
	$db->runSQL("update task_command_queue set is_processed = 'Y', result_message = '$returndata'  where task_command_queue_id = $commandsToProcess{TASK_COMMAND_QUEUE_ID}[$i]");
    }
    return 0;
}

sub _cancelrunningtask {
    my ($taskid, $actionpid) = @_;
    my $thistask = $activeList{$task_id};

    my $pid = fork();
    if ($pid) { # parent
	debug (1, "spawned killActionHelper pid $pid for task_id $task_id");
    } else {
	exec ("killActionHelper.sh", "-p", $actionpid);  # never returns .... Why do people always people put this in a comment !?!?
	debug (1, "insanity .... you failed an exec call.  Potentially the environment size is to big.  Consult your local state machine guru or priest.");
    }
}

sub cancelRunningAction {
    my $action_id = shift;
    $debug->debug (1, "cancelRunningAction called for action_id $action_id",$action_id);
    $db->loadSQL("select task_id, actionstatus, actionpid from task_v where cur_action_id = $action_id",\my %actionsToKill);
    for (my $i = 0 ; $i < $actionsToKill{rows} ; $i++) {
	my $task_id = $actionsToKill{TASK_ID}[$i];
	my $actionstatus = $actionsToKill{ACTIONSTATUS}[$i];
	my $actionpid = $actionsToKill{ACTIONPID}[$i];
	_cancelrunningtask($task_id,$actionpid) if ($actionstatus =~ /running/);
    }
}

sub doCancel {
#
# XXX ; as far as I can tell - the burning problem with this code is that parallel key management is not updated.  Better to 
# force the code that does this (in execute) manage this.
#

    my ($task_id, $doDecrement) = @_;                                           # doDecrement means adjust parallel keys
                                                                                # this mains we were "waiting"
    my $thistask = task::new (debug => $debug,
			      db => $db,
			      expander => $expander,
			      xmlhelper => $xmlhelper,
			      task_id => $task_id);

    $debug->debug (1,  "doCancel called for task_id $task_id", $task_id);

    $activeList{$task_id} = $thistask;
    
    if ($doDecrement) {
	my $actionname=autoUtil::removeSingleQuotes($thistask->getProperty(actionname));
	my $taskname=autoUtil::removeSingleQuotes($thistask->getProperty(taskname));
	my $ThisXMLActionHash = $xmlactions{$actionname};

	my $actionParallelKey = $thistask->getProperty(actionParallelKey);
	my $taskParallelKey = $thistask->getProperty(taskParallelKey);

	setParallelKey ( task_id => $task_id,
			 type => 'task',
			 parallelKey => $taskParallelKey,
			 name => $taskname,
			 increment => -1 );

	setParallelKey ( task_id => $task_id,
			 type => 'action',
			 parallelKey => $actionParallelKey,
			 name => $actionname,
			 increment => -1 );
    }

    $activeList{$task_id}->setTaskData({status => "'canceled'"});
    &Delete($task_id);	    
}

sub cancelRunningTask {
    my $task_id = shift;
    $debug->debug (1, "cancelRunningTask called for task_id $task_id",$task_id);
    my %tasksToKill;
    $db->loadSQL("select task_id, status, actionpid from task_v start with task_id = $task_id connect by prior task_id = parent_task_id",\%tasksToKill);
    for (my $i = 0 ; $i < $tasksToKill{rows} ; $i++) {
	my $task_id = $tasksToKill{TASK_ID}[$i];
	my $status = $tasksToKill{STATUS}[$i];
	my $actionpid = $tasksToKill{ACTIONPID}[$i];

	if ($status =~ /running/) {
	    _cancelrunningtask($task_id,$actionpid) 
	} elsif ($status =~ /waiting/) {
	    doCancel($task_id, 1);
	} elsif ($status =~ /queued/) {
	    doCancel($task_id);
	} elsif ($status =~ /new/) {
	    doCancel($task_id);
	}
    }

    return "success";
}

sub checkForUpdatedModules
{
    my $reload;
    $reload = "true" unless ($xmlhelper->getProperty('WRITETIME') == (stat($configFile))[9]);

    foreach $moduleName (keys (%xmlmodules)) {
	if ($xmlmodules{$moduleName}->{'WRITETIME'} != (stat($xmlmodules{$moduleName}->{'deployDir'} . "/module.xml"))[9]) {
	    $reload = "true" ;
	    break;
	}
    }

    if ($reload) {
	debug (1, "reloading XML file");
	undef $xmlhelper;
	$xmlhelper = xmlhelper::new (configFile => $configFile, debug => $debug);
	&loadData;
	return;
    }
}

sub validateInternalState
{
    # validate the parallel key structures 
    my $keyTotal = 0;

    foreach my $hkey (keys (%running)) {                                        # %running contains all relevent parallelism data.
	foreach $parallelKey (keys (%{$running{$hkey}})) {
	    foreach $name (keys (%{$running{$hkey}{$parallelKey}})) {
		confess "illegal value (" .
		    $running{$hkey}{$parallelKey}{$name} .
		    ") for parallel key ($hkey) ($parallelKey) ($name): "
		    if ($running{$hkey}{$parallelKey}{$name} < 0);
		$keyTotal += $running{$hkey}{$parallelKey}{$name};
	    }
	}
    }
    if (! keys (%activeList) && $keyTotal > 0) {
	foreach my $type (keys (%running)) {
	    foreach my $key (keys (%{$running{$type}})) {
		foreach my $name (keys (%{$running{$type}{$key}})) {
		    $debug->debug (1, "(parallel) $type.$key.$name : " . $running{$type}{$key}{$name})
			if $running{$type}{$key}{$name} > 0;
		}
	    }
	}
	confess "illegal key value detected ... check the state machine logs";
    }
}

&loadData;
$actionsTaken=0;
$loops=0;

system ("touch $runningFile");

debug(1, "state machine $identityFileBaseName is RUNNING");
debug(1, "server start took " . tv_interval ( $startTime, [gettimeofday]) . " seconds");

while (! $stop) {
#
# XXX : if think there is a bug in this logic; does "activeList" also contain a list of those tasks that are blocked.
# If not then the maxLoops and quiesced logic will not correctly recognize "blocked" tasks.
#


    $loops++;
    my $t1 = [gettimeofday];
    $actionsTaken += &reap;

    my $t2 = [gettimeofday];

    
    $debug->debug (1, "reap() took " . TV_INTERVAL ($t1,$t2));

    if ($loops > 1) {                                                           # skip first time through as buildRunList() will fix orphaned parent tasks 
	# manage child/parent relationships separate from "reaping" of pids.
	$actionsTaken += &manageParents if ! $suppressParents;

    }
    my $t3 = [gettimeofday];
    $debug->debug (1, "manageParents() took " . TV_INTERVAL ($t2,$t3));

    &buildRunList;  # unless $quiesced;

    my $t4 = [gettimeofday];
    $debug->debug (1, "buildRunList() took " . TV_INTERVAL ($t3,$t4));

    $actionsTaken += &execute;
    my $t5 = [gettimeofday];
    $debug->debug (1, "execute () took ". TV_INTERVAL($t4,$t5));

    $actionsTaken += processCommandQueue();
    my $t6 = [gettimeofday];
    $debug->debug (1, "processCommandQueue () took ". TV_INTERVAL($t5,$t6));

    sleep($sleep) unless $actionsTaken > 0 && not defined $skipSleep;

    undef $skipSleep;
    $actionsTaken = 0;

    my $t6 = [gettimeofday];

    &checkForUpdatedModules;

    my $t7 = [gettimeofday];
    $debug->debug (1, "checkForUpdatedModules () took ". TV_INTERVAL($t6,$t7));

    validateInternalState();                                                    # makes sure internal data structure consistency

    my $t8 = [gettimeofday];
    $debug->debug (1, "validateInternalState () took ". TV_INTERVAL($t7,$t8));

    if ($maxLoops && $loops >= $maxLoops && ! keys(%activeList)) {
	debug (1, "my life is over, total loops $loops maxLoops $maxLoops; no active tasks");
	exit (0);
    }
    if ($quiesced && ! keys(%activeList)) {
	debug (1, "SIGHUP received; no active tasks");
	exit (0);
    }
    if ($exitWhenIdle &&  ! keys(%activeList)) {
	debug (1, "No tasks left and -exitWhenIdle was set; see ya");
	exit (0);
    }
}

