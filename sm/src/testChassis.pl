#!/usr/bin/perl
use File::Basename;
use lib dirname($0);
use lib dirname($0) . "/utils";
use Term::ANSIColor qw(:constants);
use Getopt::Long;
use Carp;
use Data::Dumper;
use dbutil;
use POSIX qw(setsid);
use POSIX ":sys_wait_h";
require "require.pl";

GetOptions("config:s" => \$config,
	   "debug" => \$debug,
	   "DebugLevel:s" => \$DebugLevel,
	   );

_require(config);
require "automatorBase.pl";
eval { require "$config"; };
confess "require puked: $@" if $@;


sub REAPER {
    my $pid;
    while (($pid = waitpid(-1, &WNOHANG)) > 0) {
	$exit_value  = $? >> 8;
	$signal_num  = $? & 127;
	$dumped_core = $? & 128;

	if (WIFEXITED($?)) {
	    print BOLD, RED, "Looks like the state machine puked .... sorry (check the log) .... unless of course a test called bumpSM", RESET;
	    print "\n";
	    confess "see ya";
	} 
    }
    $SIG{CHLD} = \&REAPER;                  # install *after* calling waitpid
}

$progname=basename($0);

sub debug {
    while (@_) {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$now = sprintf ("%2.2d/%2.2d/%02d-%2.2d:%2.2d:%2.2d",$mon+1,$mday,$year+1900,$hour,$min,$sec);
	print "$now($$): " . @_[0] . "\n";
	shift;
    }
}

sub startSlave {
    system("make");
    $id = `m80 --execute ./aurchestrator.pl -config $testXMLFile -logDir . -debug 1 -sleep 0 -print` ;
    chomp($id);

    $pidfile = $id . ".pid";
    $id .= ".running";

    debug("pidfile is $pidfile");

    system ("rm -f $id");
    $pid = fork();
    debug ("fork returned $pid");
    if ($pid) {
	$SIG{CHLD} = \&REAPER;
	while ( ! -f $id) {
	    debug ("waiting for file $id to appear");
	    sleep (1);
	}
	$smpid = `cat $pidfile`;
    } else {
	system ("mkdir logs.$$");
	exec("m80 --execute " . ($debug ? "perl -d:ptkdb " : "") . "./aurchestrator.pl -config $testXMLFile -logDir logs.$$ -debug " . (defined $DebugLevel ? $DebugLevel : 1)  . " -sleep 0");
    }
}

sub seeya {
    delete $SIG{CHLD} ;
    $smpid = `cat $pidfile`;
    chomp($smpid);
    debug "Shutting down the state machine ($smpid)\n";
    system ("kill $smpid");
    system ("kill -9 $smpid");
}

sub bumpSM {
    seeya;
    startSlave;
}

debug "before start slave";
startSlave();
debug "after start slave";
$testNum = 0;
$numFails = 0;
my @all_tests = ();

foreach $test (@tests) {
    $testNum++;
    foreach $command (@{$test->{commands}}) {
	if ($command->{type} =~ /internal/) {
	    debug ("running internal command $command->{command}\n");		
	    eval "$command->{command}";
	    debug ("ran internal command $command->{command}\n");		
	} else {
	    debug ("sprintf (\"" . $command->{command} . "\")");
	    $c = eval "sprintf (\"" . $command->{command} . "\")";
	    debug ("running command $c");
	    $taskId = `m80 --execute $c 2>/dev/null`;
	    chomp($taskId);
	    if ( $command->{name}) {
		$tasks{$command->{name}} = $taskId ;
		debug ("$command->{name} started task id $taskId");
	    } else {
		debug ("command output is $taskId\n");
	    }
	}
    }
    debug ( "Sleeping $test->{wait} seconds waiting for answers\n");
    sleep($test->{wait});
    $thisFail=0;
    foreach $expectation (@{$test->{expectations}}) {
	%results = ();
	eval {
	    dbutil::loadSQL($dbh, "select $expectation->{field} from $expectation->{table} where task_id = " . $tasks{$expectation->{name}}, \%results,1);
	  };
	seeya() if $@;
	$result = $results{uc($expectation->{field})}[0];
	debug "Comparing expectation($expectation->{expectation}) to result($result).\n";
	debug "Test $testNum:\t";
	if ($result =~ /$expectation->{expectation}/) {	    
	    print BOLD, GREEN, "Success", RESET;
	    print "\n";
	} else {
	    $test->{failed} = "true";
	    print BOLD, RED, "FAILED";
	    print RESET, "\n";
	    $thisFail=1;
	}
    }
    $numFails += $thisFail;
    push(@all_tests,$test);
}
print "Tests (success/total) = (" . ($testNum - $numFails) . "/$testNum)\n";

seeya() unless $debug;




