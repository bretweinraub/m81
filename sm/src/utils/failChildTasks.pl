#!/usr/bin/perl

use File::Basename;
use lib dirname($0);
use Data::Dumper;
use dbutil;
use Getopt::Long;
use Term::ANSIColor qw(:constants);
use Env;
require "dbConnect.pl";
require "require.pl";

GetOptions("task_id:s" => \$task_id,
	   "debug" => \$debug);

use Carp;
confess "set -task_id" unless ($task_id);

sub _print {
    my ($string, $width) = @_;

    my $format = "%-$width" . "s";
    printf "$format ", substr($string, 0, $width-1);
}

sub _printNum {
    my ($num, $width) = @_;

    my $format = "%-$width" . "d";
    printf "$format ", $num;
}


%ret = ();

$sql = "update task set status = 'failed' where task_id in 
(select	action.task_id
from 	action,
	task,
	( 
		select 	task_id, 
			level l
		from 	task  
		start with 
			task.task_id = 	(
						select 	task_id
						from	task
						where   task.task_id = $task_id
					)
		connect by prior 
			task.task_id = parent_task_id 
	) iv
where 	action.task_id = iv.task_id
and	task.task_id = action.task_id
and     task.task_id <> $task_id
)";

dbutil::runSQL ($dbh, $sql, $debug);
exit 0;


