#!/usr/bin/perl

=pod

=head1 NAME

createTask.pl

=head1 DESCRIPTION

A command line interface to create tasks and associated context variables.

=head1 OPTIONS

=over

=item -this C<tag>

Sets a context variable for the new task that can be used to derive this task_id.  This
is a convenience variable that allows tasks deep in a parent/child hierarchy to find a special "master"
task_id; for example this is useful when you want child tasks to "post" data such as reporting data.

=back

=cut

use File::Basename;
use lib dirname($0);
use Carp;
use Getopt::Long;
use dbutil;
use Data::Dumper;
use Env;
use DBI;
use Env;
use ChainDB;

my $ChainDB = ChainDB::new (verbose => $debug);

$ChainDB->{dbh}->{'AutoCommit'} = 0;

my $contextAssignment = "=";
my $contextSeperator = ",";
$parent="NULL";

$status="new";

GetOptions("task:s" => \$task,
	   "context:s" => \$context,
	   "contextSeperator:s" => \$contextSeperator,
	   "contextAssignment:s" => \$contextAssignment,
#	   "name:s" => \$name,
	   "username:s" => \$username,
	   "sid:s" => \$sid,
	   "host:s" => \$host,
	   "status:s" => \$status,
	   "port:i" => \$port,
	   "poll" => \$poll,
	   "extensions:s" => \@extensions,
	   "mapper:s" => \$mapper,
	   "this:s" => \@this,
	   "parent|parent_task_id:i" =>\$parent,
	   "password:s" => \$password,
	   "debug" => \$debug);

# 
# main() ....
#

$\="\n";
$debug="true";

confess "use or -task" if (! $task);

$date=`date +%Y%m%d%H%M%S.%N`;

$ChainDB->runSQL(
	 "insert into task (task_name, taskname, status, parent_task_id, mapper) values ('$date', '$task', '$status', $parent," . 
	 ($mapper ? "'$mapper')" : "NULL)"),
	 $debug);

$ChainDB->loadSQL("select task_id from task where taskname = '$task' and task_name = '$date'", \%task, $debug);

$task_id = $task{TASK_ID}[0];
print STDERR "contextSeperator is $contextSeperator";
@contexts = split(/$contextSeperator/,$context);
foreach (@contexts) {
    ($tag, $value) = split(/$contextAssignment/, $_, 2);
    $ChainDB->runSQL ("insert into task_context (tag, value, task_id) values ('$tag', '$value', $task_id)", $debug);
}    

print "$task_id";

for my $this (@this) {
    $ChainDB->runSQL ("insert into task_context (tag, value, task_id) values ('$this', '$task_id', $task_id)", $debug) if $this;
}

# allow for extension

for my $ext (@extensions) {
    my ($lib,$func) = split (/:/,$ext);
    $func = $lib unless $func; # entry point is the same as file unless defined
    $lib .= '.pl' unless $lib =~ /\.pl$/;
    require "$lib";
    &{ $func }(dbh => $ChainDB->{dbh},
	       task_id => $task_id);
}

$ChainDB->{dbh}->commit();


if ($poll) {
    $\="";

    use IO::Handle;
    STDOUT->autoflush(1);

    undef ($debug);
    print "waiting for task to start ...";

    do {
	%actions = ();
	$ChainDB->loadSQL ("select 	action.task_id, 
				action_id, 
				actionname, 
				actionstatus,
				status,
                                failurereason
			from 	action,
				task
			where 	action.task_id in ( select task_id from task start with task_id = $task_id connect by prior task_id = parent_task_id )
			and	task.task_id = action.task_id
			order by 
				actionsequence", \%actions, $debug);

	if ($status =~ /new/) {
	    print ".";
	    sleep(1);
	} else {
	    unless ($started) {
		print "ok, will poll for logs.\n";
		$started = "true";
	    }
	    for ($i = 0 ; $i < $actions{rows} ; $i++) {
		map {eval sprintf ("\$" . lc($_) . " = \"" . $actions{$_}[$i] . "\"") if ref ($actions{$_}) =~ /ARRAY/;} (keys (%actions));

		$_ = $actionstatus;

	      SWITCH: {
		  (/finished/ || /failed/ || /succeeded/) && do {
		      unless (exists ($finished{$action_id})) {
			  $urlbase = "http://$CONTROLLER_DEPLOY_HOST/$M80_BDF/taskData/$task_id/$action_id.$actionname";
			  for (0 .. 1) {
			      $out = `wget -O - -o /dev/null $urlbase.$_`;
			      print "\n***************\n";
			      print "\nFD($_) for $actionname:\n***************\n\n$out";
			  }
			  $finished{$action_id} = "true";
		      }

		      last SWITCH;
		  };
		  (/running/ || /waiting/) && do {
		      if (exists $running{$action_id}) {
			  print ".";
		      } else {
			  print "***************\n";
			  print "\naction $actionname is in progess";

			  $running{$action_id} = "true";
		      }
		      last SWITCH;
		  };
	      }
	    }

	    if ($status =~ /failed/i || $status =~ /succ/i) {
		$done = "true";
	    } else {
		sleep (1);
	    }
	}
    } until defined $done;
    print "***************\n";
    print "task_id $task_id has completed with status of $status ($failurereason)\n";
    print "***************\n";

}

# if this is running under the context of the Statemachine, then create a link to children
if ($ENV{AUTOMATOR_STAGE_DIR}) { 
    print STDERR "<html><body>\n";
    print STDERR "Jump to task: <a href='http://$CONTROLLER_DEPLOY_HOST/$ENV{M80_BDF}/taskData/$task_id'>$task_id</a>\n";
    print STDERR "</body></html>\n";
}


exit 0;


