#!/usr/bin/perl

use File::Basename;
use lib dirname($0);
use Data::Dumper;
use dbutil;
use Getopt::Long;
use Term::ANSIColor qw(:constants);
use Carp;


require "dbConnect.pl";
require "require.pl";

GetOptions("task:s" => \$task,
	   "id:s" => \$id);

confess "set -task or -id" unless ($task or $id);

if ($task) {
    $extras = "						where	taskname = '$task'";
} elsif ($id) {
    $extras = "						where	task_id = $id";
}

$sql = "
select	task_id,
	actionname,
	v.action_id
from 	action,
	(
		select	max(action.action_id) action_id
		from    action,
		        ( 
		                select  task_id
		                from    task  
				where	status = 'failed'
		                start with 
		                        task_id = (
		                                      select  max(task_id)
		                                      from    task
		                                      $extras
		                                   )
		                connect by prior 
		                        task_id = parent_task_id 
		        ) iv
		where	iv.task_id = action.task_id
                and     actionstatus = 'failed'
	) v
where	action.action_id = v.action_id
";

dbutil::loadSQL ($dbh, $sql, \%ret);

$action_id = $ret{ACTION_ID}[0];
$task_id = $ret{TASK_ID}[0];
$actionname = $ret{ACTIONNAME}[0];

$c = "cat /var/www/html/$ENV{M80_BDF}/taskData/$task_id/$action_id.$actionname.*";

print "$c\n";
system ($c);

exit 0;

