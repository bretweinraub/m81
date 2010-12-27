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

$sql = "select 	lpad(' ',3*(l-1)) || task.taskname || '.' || actionname an, 
        task.parent_task_id,
	action.task_id, 
	action_id,
        actionpid
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
and     action.actionstatus = 'running'
order by 
        action_id
";

dbutil::loadSQL ($dbh, $sql, \%ret, $debug);

for ($i = 0 ; $i < $ret{rows} ; $i ++ ) {
    map {eval sprintf ("\$" . lc($_) . " = \"\"") if ref ($ret{$_}) =~ /ARRAY/;} (keys (%ret));
    map {eval sprintf ("\$" . lc($_) . " = \"" . $ret{$_}[$i] . "\"") if ref ($ret{$_}) =~ /ARRAY/;} (keys (%ret));
    if ($debug) {
        _print( $an , 40 );
        _printNum( $task_id, 6 );
        _printNum( $parent_task_id, 6 );
        _printNum( $action_id, 6 );
    }
    _printNum( $actionpid, 6 );
    print "\n";
}
exit 0;


