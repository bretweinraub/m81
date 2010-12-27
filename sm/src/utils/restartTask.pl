#!/usr/bin/perl

use Getopt::Long;
use dbutil;
use DBI;
use Env;
#use taskpoll;

my $username="$CONTROLLER_USER";
my $sid="$CONTROLLER_SID";
my $host="$CONTROLLER_HOST";
my $port="$CONTROLLER_PORT";
my $password="$CONTROLLER_PASSWD";

my $task_id = $ENV{task_id};

die "failed to connect to dbi:Oracle:host=$host;sid=$sid;port=$port" 
    unless ($dbh = DBI->connect("dbi:Oracle:host=$host;sid=$sid;port=$port", "$username", "$password",
				{ RaiseError => 1,
				  AutoCommit => 0}));

$status = 'error';

GetOptions("task_id:s" => \$task_id,
	   "actionname:s" => \$actionname,
	   "status:s" => \$status,
	   "tag:s" => \$tag,
	   "debug" => \$debug,
	   "poll" => \$poll,
	   "value:s" => \$value);

die "set -task_id" unless $task_id;

dbutil::runSQL($dbh, "
	update 	task 
	set 	cur_action_id = 
		(
			select 	distinct 
				action_id 
			from 	action
			where 	task_id = $task_id 
			and 	actionname = '$actionname'
		) 
	where 	task_id = $task_id",
	       1) if $actionname;

dbutil::runSQL($dbh, "update task set status ='$status' where task_id = $task_id", "true");

$dbh->commit;

# taskpoll::poll(dbh => $dbh, 
# 	       task_id => $task_id, 
# 	       debug => $debug,
# 	       action_id => $action_id) if $poll;

