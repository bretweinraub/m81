package taskpoll;
use DBI;
use dbutil;
use Env;

sub poll {
    no strict;
    my %args = @_;

    $\="";

    $loadSQL = \&dbutil::loadSQL;
    use IO::Handle;
    STDOUT->autoflush(1);

    print "waiting for task to start ...";

    do {
	%actions = ();
	&{$loadSQL} ($args{dbh}, "select 	action.task_id, 
				action_id, 
				actionname, 
				actionstatus,
				status,
                                failurereason
			from 	action,
				task
			where 	action.task_id = $args{task_id} 
			and	task.task_id = action.task_id
			order by 
				actionsequence", \%actions, $args{debug});

	if ($status =~ /new/) {
	    print ".";
	    sleep(1);
	} else {
	    unless ($started) {
		print "ok, will poll for logs.\n";
		$started = "true";
	    }
	    for ($i = 0 ; $i < $actions{rows} ; $i++) {
		{
		    no strict;
		    map {eval sprintf ("\$" . lc($_) . " = \"" . $actions{$_}[$i] . "\"") if ref ($actions{$_}) =~ /ARRAY/;} (keys (%actions));
		}

		$_ = $actionstatus;

	      SWITCH: {
		  (/finished/ || /failed/ || /succeeded/) && do {
		      unless (exists ($finished{$action_id})) {
			  $urlbase = "http://$CONTROLLER_DEPLOY_HOST/$M80_BDF/taskData/$args{task_id}/$action_id.$actionname";
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
    print "task_id $arg{task_id} has completed with status of $status ($failurereason)\n";
    print "***************\n";
}

1;

