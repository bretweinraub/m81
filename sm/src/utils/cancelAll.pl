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


dbutil::runSQL($dbh, "update task set status  = 'cancel' where status in ('new', 'queued', 'analyzing', 'error', 'running', 'waiting')");

$dbh->commit;

