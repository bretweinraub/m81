#!/usr/bin/perl

use File::Basename;
use lib dirname($0);
use Data::Dumper;
use dbutil;
use Getopt::Long;
use Term::ANSIColor qw(:constants);

require "dbConnect.pl";
require "require.pl";

GetOptions("debug" => \$debug);

use Carp;

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
$sql = "
select 	task.task_id,
        lpad(' ',3*(l-1)) indent,
	lpad(' ',3*(l-1)) || task.taskname taskname,
        actionname,
	task.status,
	ALL_HOSTS,
        actionpid,
        parent_task_id,
	decode (actionstatus, 'running', to_char((SYSDATE - action.inserted_dt) * (86400)),
				  	 (nvl(action.updated_dt,SYSDATE) - action.inserted_dt) * (86400)) secs
from	task,
	( 
select task_id,
       l,
       rownum r
from   (
		select 	task_id, 
			level l
		from 	task  
		start with 
			task_id in (select task_id from task where parent_task_id is null and status in ('running','waiting','queued') union (select task1.task_id from task task1, task task2 where task1.parent_task_id = task2.task_id and task2.status = 'succeeded' and task1.status in ('running','waiting','queued')))
		connect by prior 
			task_id = parent_task_id 
                order	siblings 
                by      task_id
)
	) iv,
	action,
	currently_running_v
where	task.task_id= iv.task_id
and	task.cur_action_id = action.action_id
and	task.task_id = currently_running_v.task_id(+)
and	task.status <> 'succeeded'
order	by r";

    
dbutil::loadSQL ($dbh, $sql, \%ret, $debug);

for ($i = 0 ; $i < $ret{rows} ; $i ++ ) {
    map {eval sprintf ("\$" . lc($_) . " = \"\"") if ref ($ret{$_}) =~ /ARRAY/;} (keys (%ret));
    map {eval sprintf ("\$" . lc($_) . " = \"" . $ret{$_}[$i] . "\"") if ref ($ret{$_}) =~ /ARRAY/;} (keys (%ret));
    
    _printNum ($ret{TASK_ID}[$i], 6);
}
print "\n";

