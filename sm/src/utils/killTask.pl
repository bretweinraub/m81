#!/usr/bin/perl

=pod

=head1 NAME

killTask.pl

=head1 DESCRIPTION

A command line interface to kill a running task

=head1 OPTIONS

=over

=item -task_id C<task_id>

The task id to kill.  This will kill an entire tree if it exists.

=item -seconds C<timer>

Will issue the kill after a timer expires.  Usefull if you want to force a timeout on a running task.  Will return immediately.

=back

=head1 EXAMPLE

mexec killTask.pl -ta 327 -seconds 10

Which means kill this task in 10 seconds.

=cut

use File::Basename;
use lib dirname($0);
use Carp;
use Getopt::Long;
use dbutil;
use Data::Dumper;
use Env;

$username="$CONTROLLER_USER";
$sid="$CONTROLLER_SID";
$host="$CONTROLLER_HOST";
$port="$CONTROLLER_PORT";
$password="$CONTROLLER_PASSWD";

$seconds=0;

GetOptions("task_id:s" => \$task_id,
	   "seconds:s" => \$seconds,
	   "debug" => \$debug);

# 
# main() ....
#

confess "use -task_id" if ( ! $task_id);

confess "failed to connect to dbi:Oracle:host=$host;sid=$sid;port=$port" 
    unless ($dbh = DBI->connect("dbi:Oracle:host=$host;sid=$sid;port=$port", "$username", "$password",
				{ RaiseError => 1}));


dbutil::runSQL 
    ($dbh, 
	 "insert into task_command_queue (command,at_time) values ('cancelRunningTask($task_id)',SYSDATE+$seconds/86400)",
	 $debug);

exit 0;
