#!/usr/bin/perl

use strict;

use File::Basename;
use lib dirname($0);
use Data::Dumper;
use dbutil;
use Getopt::Long;
use Term::ANSIColor qw(:constants);
use ChainDB;
use Carp;

require "require.pl";

my $awidth=80; # with of actionname

GetOptions("task:s" => \my $task,
	   "flip" => \my $flip,
	   "debug" => \my $debug,
	   "refresh:i" => \my $refresh,
	   "perf" => \my $perf,
	   "width:i" => \my $awidth,
	   "summary" => \my $summary,
	   "html" => \my $html,
#	   "ShowSql" => \my $showSql,
           'noQueued' => \my $noQueued,
	   "id:s" => \my $id);

my $ChainDB = ChainDB::new (verbose => $debug);

unless (defined $refresh){ $refresh = 4; }
unless ($summary) {
    confess "set -task or -id" unless ($task or $id);
}
sub _print {
    print _sprint(@_);
}

sub _sprint {
    my ($string, $width) = @_;

    my $format = "%-$width" . "s";
    my $ret = sprintf "$format ", substr($string, 0, $width-1);
    return $ret;
}

sub _sprintNum {
    my ($num, $width) = @_;

    my $format = "%-$width" . "d";
    my $ret = sprintf "$format ", $num;
    return $ret;
}

sub _printNum {
    print _sprintNum(@_);
}

my $orderby = "action_id";
if ($perf ) {
    $orderby = "to_number (decode (actionstatus, 'running', to_char((SYSDATE - action.inserted_dt) * (86400)), (nvl(action.updated_dt,SYSDATE) - action.inserted_dt) * (86400))) asc" ;
} 

system("clear") if $refresh;

sub colorize {
    my ($status, $type, $text) = @_;

    if ($html || $status =~ /new/) {
	print $text;
	return;
    }
    if ($status =~ /failed/  || $status =~ /canceled/) {
	print BOLD, RED, $text, RESET;
    } elsif ($status =~ /succeeded/) {
	unless ($type =~ /taskname/) {
	    print BOLD, GREEN, $text, RESET;
	} else {
	    print $text;
	}
    } elsif ($status =~ /running/) {
	print BOLD, MAGENTA, $text, RESET;
    } elsif ($status =~ /waiting/) {
	print BOLD, BLUE, $text, RESET;
    } else {
	print $text;
    }
}

if ($html) {
    print <<"EOF";

<html>
<head></head>
<body>
<pre>
EOF
}

my $extras;
my $sql;


while (1) {
    if ($task) {
	$extras = "						where	taskname = '$task' and status not in ('queued','canceled')";
    } elsif ($id) {
	$extras = "						where	task_id = $id";
    }

    my %ret = ();

    unless ($summary) {
	$sql = $ChainDB->db_specific_construct("smtop-task",$extras,$orderby,$id);
    } else {
        my $action_status_list = '';
        if ($noQueued) {
            $action_status_list = "('running', 'waiting')";
        } else {
            $action_status_list = "('running', 'waiting', 'queued')";
        }
	$sql = "
select 	task.task_id,
        lpad(' ',3*(l-1)) indent,
	lpad(' ',3*(l-1)) || task.taskname taskname,
        actionname,
	task.status,
        actionpid,
	task.mapper || action.actionmapper mapper,
        actionstatus,
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
			task_id in (select task_id from task where parent_task_id is null and status in $action_status_list union (select task1.task_id from task task1, task task2 where task1.parent_task_id = task2.task_id and task2.status = 'succeeded' and task1.status in $action_status_list))
		connect by prior 
			task_id = parent_task_id 
                order	siblings 
                by      task_id
)
	) iv,
	action
where	task.task_id= iv.task_id
and	task.cur_action_id = action.action_id
and	task.status in ('waiting', 'queued','running')
order	by r";
	$sql .= " desc" if $flip;
    }


    print $sql if $debug;
    $ChainDB->loadSQL ($sql, \%ret, $debug);

    system("clear") if $refresh;

    my $i;
    my $mapper;
    my $parent_task_id;
    my $status;
    my $actionpid;
    my $actionname;
    my $action_id;
    my $ud;
    my $secs;
    my $insd;
    my $taskname;
    my $indent;

    for ($i = 0 ; $i < $ret{rows} ; $i ++ ) {
	map {eval sprintf ("\$" . lc($_) . " = \"\"") if ref ($ret{$_}) =~ /ARRAY/;} (keys (%ret));
	map {eval sprintf ("\$" . lc($_) . " = \"" . $ret{$_}[$i] . "\"") if ref ($ret{$_}) =~ /ARRAY/;} (keys (%ret));

	my $actionstatus;
	unless ($summary) {
	    colorize($actionstatus, "taskname", _sprint ($ret{AN}[$i], $awidth));

	    if ($html) {
		print "<a href=\"http://$ENV{CONTROLLER_DEPLOY_HOST}/$ENV{M80_BDF}/taskData/" . _sprintNum ($ret{TASK_ID}[$i], 6) . "\">" . _sprintNum ($ret{TASK_ID}[$i], 6) . "</a>";
	    } else {
		_printNum ($ret{TASK_ID}[$i], 6);
	    }
 	    _print ($mapper, 24);

	    colorize($status, "status", _sprint($status,10));

	    colorize ($actionstatus, "actionstatus", _sprint ($actionstatus, 10));
	    
#	    print RESET;
	    _printNum ($action_id,6);
	    _printNum ($secs,4);
#	  _print ($callbacks,60);
	    _print ($insd, 10);
	    _print ($ud, 10);
	    _printNum ($actionpid,5);

	} else {
	    
	    colorize ($status, "status", 
		      _sprintNum ($ret{TASK_ID}[$i], 6) .
		      ($parent_task_id ?
		       _sprint ($indent . $actionname, 60)
		       : _sprint ($taskname . "." . $actionname, 60)) .
		      _sprint ($status, 10) .
		      _sprint ($mapper, 40) .
		      _sprint ( $actionstatus, 32 ) .
		      (($parent_task_id) ?
		       _sprintNum ($secs, 4) :
		       _sprint ("",4)) .
		      _sprintNum ($actionpid, 6));
#	    print RESET;
	}
	print "\n";
#    write();
    }

    exit 0 unless $refresh;
    sleep ($refresh);

};

#print Dumper(%ret);

