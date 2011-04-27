package task;   # -*-perl-*-
use FileHandle;
use Carp;
use autoUtil;
use ChainDB;
use Data::Dumper;


# PARENT automator.pl
# TITLE Task Object
# =pod

# =head1 NAME

# task.pm - object for state machine tasks

# =head1 DESCRIPTION

# ...

# =cut

sub scrub
{
    my $ret = @_[0];
    $ret =~ s/\'//g;
    return $ret;
}

use assert;

sub _options {
  my %ret = @_;
  my $once = 0;
  for my $v (grep { /^-/ } keys %ret) {
    require Carp;
    $once++ or Carp::carp("deprecated use of leading - for options");
    $ret{substr($v,1)} = $ret{$v};
  }

  $ret{control} = [ map { (ref($_) =~ /[^A-Z]/) ? $_->to_asn : $_ } 
		      ref($ret{control}) eq 'ARRAY'
			? @{$ret{control}}
			: $ret{control}
                  ]
    if exists $ret{control};

  \%ret;
}


sub _dn_options {
  unshift @_, 'dn' if @_ & 1;
  &_options;
}

sub setProperty {
    my $ref = shift;
    my ($prop, $val) = @_;

    $ref->{$prop} = $val;
#
# setPropertyCallback: the routine is called by the setProperty routine in perloo.m4.  It
# allows for custom extensions to that set property routine to be expressed in the supplied subroutine.
# Look in task.pm.m4 for an example of its use.
#
    if ($ref->{setPropertyCallback} && ref($ref->{setPropertyCallback}) =~ /CODE/) {
	$callback = $ref->{setPropertyCallback};
	&$callback ($ref, $prop, $val);
    }
}

sub setProperties {
    my $ref = shift;
    my $arg = &_dn_options;
    map {$ref->setProperty($_, $arg->{$_});} (keys (%{$arg}));
}
    

sub getProperty {
    my $ref = shift;
    my ($prop) = @_;

    if ($prop =~ /taskLogFH/ && not defined $ref->{taskLogFH}) {
	my $tlf = $ref->{taskLogFile};
	$ref->{taskLogFH} = new FileHandle;
	$ref->{taskLogFH}->autoflush(1);
	$ref->{taskLogFH}->open (">> $tlf") or 
	    confess "cannot open log file $tlf: $!";
    }
    return $ref->{$prop};
}




#
# setPropertyCallback: the routine is called by the setProperty routine in perloo.m4.  It
# allows for custom extensions to that set property routine to be expressed in the supplied subroutine.
#
    
sub setPropertyCallback
{
    my $ref=shift;
    my ($prop, $val) = @_;
    
    $ref->{debug}->debug(3, "task::setPropertyCallback($prop,$val)", $ref) if $ref->{debug};
#
# If I were a bug; this next block would be where I'd live.  Some hard thinking is required to
# determine if this program were to exit at any point in the block; if the associated task would correctly recover.
# 
# A good way to evaluate it would be to force an exit before and after every statement; run a task through it and validate
# we do the "right" thing.
#

    if ($prop =~ /actionname/i) {
	$ref->{db}->runSQL($ref->{db}->db_specific_construct("set_action",$ref->{actionname},$ref->{task_id}));
	assert::assert ("\$ref->{task_id} not defined", $ref->{task_id});
	$ref->{db}->loadSQL("select cur_action_id from task where task_id = $ref->{task_id}", \my %curInfo);
	assert::assert("failed to derive current action id", $curInfo{rows} == 1);
	$ref->setProperty(cur_action_id,$curInfo{CUR_ACTION_ID}[0]);
    }
}

%allTasks = ();

sub getOutputDir {
    my $object = shift;
    return $object->{expander}->expand (text => $object->{xmlhelper}->getProperty(xml)->{wwwroot}) . "/" . $arg->{task_id};
}

sub new {
    my $arg = &_dn_options;
    
    if (! $arg->{task_id}) {
	$main::debug->debug (0, "cannot create a task object without a task_id");
	return;
    }
    
    my $object;
    if (! ($object = $allTasks{$arg->{task_id}})) {
	$object = {};
	bless $object, "task";
	$object->{setPropertyCallback} = \&setPropertyCallback;
	$arg->{debug}->debug(4, "setPropertyCallback is " . ref($object->{setPropertyCallback}));
    } 
    # do the "actionname" property last; since it requires other things 2B set in setPropertyCallback.
    map {$arg->{debug}->debug (4, "task::new setting property $_ to $arg->{$_}") ; $object->setProperty($_, $arg->{$_}) unless /actionname/;} (keys (%{$arg}));

    assert::assert ("task::new requires a pointer to an XML config file object", $object->{xmlhelper});
    assert::assert ("task::new requires a pointer to a variable expander object", $object->{expander});
    $object->setProperty ('actionname', $arg->{actionname}) if ($arg->{actionname});
#
#   Generate a path to the output directory.
#
    $object->setProperty ('outputdir', 
			  $object->{expander}->expand (text => $object->{xmlhelper}->getProperty(xml)->{wwwroot}) . "/" . $arg->{task_id});
    my $odir = $object->{outputdir};
    system ("mkdir -p $odir");
    if (! -d $odir) {
	system ("mkdir -p $odir");
	if (! -d $odir) {
	    $arg->{debug}->debug (1, "failed to create $odir .... maybe a bad symlink; I'll try to continue but am not guaranteeing anything");
	    my $me = `whoami`;
	    chomp($me);
	    $arg->{debug}->debug (1, "If this error persists you may want to run \"mkdir -p $odir\" and set write permissions for " . $me);

	    # bombs away!
	}
    }

#
#   Open a "per-task" log.
#

    $object->setProperty('taskLogFile', $object->{outputdir} . "/task.log");

#    my $tlf = $object->{taskLogFile};
    
#    $object->{taskLogFH} = new FileHandle;
#    $object->{taskLogFH}->autoflush(1);
#    $object->{taskLogFH}->open (">> $tlf") or 
#	die "cannot open log file $tlf";

    $allTasks{$object->{task_id}} = $object;

    return $object;
};

sub setTaskData
{
    my $ref = shift;
    my ($hashref) = @_;
    
    my $taskUpdateClause;
    my $actionUpdateClause;
#
# TODO: this is fairly hackish; encapsulating within a single transaction is ideal.
#       Could be accomplished fairly simply with a call to the DBI::->autocommit flag
#       OR by writing a custom PL/SQL procedure.
#
    my $newAction;

    $newAction = "true"
	if (exists ($hashref->{actionname}) and $hashref->{actionname} != $ref->{actionname});
    
    map {
	$val = $hashref->{$_};
	$val =~ s/\'\'/\'/g;
	$val = substr ($val, 0, 255) if (/failurereason/);  # hack ; hard coded field length.
	
	if (! /actionstatus/ &&
	    ! /actionname/ &&
	    ! /numfailures/ &&
	    ! /callbacks/ &&
	    ! /actionpid/ &&
	    ! /actionmapper/ &&
	    ! /export_filter/ &&
	    ! /outputurl/) {
	    $taskUpdateClause .= "," if $taskUpdateClause;
	    $taskUpdateClause .= "$_ = $val";
	} else {
	    $actionUpdateClause .= "," if $actionUpdateClause;
	    $actionUpdateClause .= "$_ = $val";
	}

	if (/status/ && $val =~ /failed/) {
	    &{$ref->{spammerSub}}(task_id => $ref->{task_id},
				  this => $ref,
				  outputdir => $ref->{outputdir}) if ($ref->{spammerSub});
	}
    } (keys (%{$hashref}));
    
    $ref->{db}->setTaskData($ref->{task_id}, $taskUpdateClause) if $taskUpdateClause;
    
#   the following two lines NEED to be in order ..... setProperty of "actionname" calls "P_TASK.SET_ACTION"
    
    map {$ref->setProperty($_, $hashref->{$_});} (keys (%{$hashref})); 
    $ref->{db}->setActionData($ref->{task_id}, $actionUpdateClause) if $actionUpdateClause;
#
#  This is really where we should commit the entire transition block : TODO XXX
#
}

%taskTransitionMap = (SUCCESS => 'succeeded');

sub transitionTo
{
    my $ref = shift;
    my ($destination, $actionmapper, $callback, $pop);

    my $task_id = $ref->{task_id};

    if ($_[0] =~ /^(nextaction|actionmapper|callback|pop)$/) {
	%args = @_;
	$destination = $args{nextaction};
	$actionmapper = $args{actionmapper};
	$callback = $args{callback};
	$pop = $args{pop} ? "true" : "false";
    } else {
	($destination, $actionmapper, $callback, $p) = @_;
	$pop = $p ? "true" : "false";
    }

    $ref->{debug}->debug(1, "($destination, $actionmapper, $callback, $pop)");

    $pop =~ "false" unless $ref->{callbacks};
    
    $ref->{debug}->debug (1, "task $task_id transition to state $destination with action mapper $actionmapper", $task_id);

#
# this block process terminal states (anything inside  __
#
    if (($pop =~ /false/ or ($pop =~ /true/ and not $ref->{callbacks})) and scrub($destination) =~ m/__(\w+)__/) {
	my $match=$1;
	my $numFailureIncrement = $ref->{numfailures} ? $ref->{numfailures} : 0;
	$numFailureIncrement++ if ($match =~ /ERROR/ || $match =~ /FAILED/);
	$ref->{debug}->debug (3, "numFailureIncrement is $numFailureIncrement", $task_id);

	$ref->setTaskData ({status => "'" . ($taskTransitionMap{$match} ? $taskTransitionMap{$match} : lc($match)) . "'",
			    actionstatus => "'" . ($taskTransitionMap{$match} ? $taskTransitionMap{$match} : lc($match)) . "'",
			    failurereason => "'state transition $match'",
			    numfailures => $numFailureIncrement});

	$ref->{debug}->debug (1, "task $task_id " . $taskTransitionMap{$match} ? $taskTransitionMap{$match} : lc($match), $task_id);

	if ($match =~ /WAITING/) {
# OK ... .things are getting out of hand now!  Thank god at least we are single threaded :) LOL!
#
# On the other hand, if this weren't perl  .... we be re-architecting the whole damn program.  Double edged sword!
#
# Instead will just write our data into the "main::" namespace 23:59 HACK!!!!!
#
# The purpose of this block is to increment the "running" counter with all "waiting tasks" ... since the count of waiting tasks 
# happens in a very way from "running" tasks, we unfortunately need to calculate running where the action happens.

	    my $thistask = $ref;
	    my $actionname = autoUtil::removeSingleQuotes($thistask->{actionname});
	    my $taskname = autoUtil::removeSingleQuotes($thistask->{taskname});

	    my $ThisXMLActionHash = $main::xmlactions{$actionname};
	    my $ThisXMLTaskHash = $main::xmltasks{$taskname};

	    my $taskContext = $main::db->loadTaskContext($task_id);
	    my $taskParallelKey = $main::expander->expand (text => $ThisXMLTaskHash->{parallelismKey}, taskContext => $taskContext) || "nokey";
	    my $actionParallelKey = $main::expander->expand (text => $ThisXMLActionHash->{parallelismKey}, taskContext => $taskContext) || "nokey";
	    
	    $main::running{task}{$taskParallelKey}{$taskname} = (($main::running{task}{$taskParallelKey}{$taskname} >= 0) ? ($main::running{task}{$taskParallelKey}{$taskname} + 1) : 1);
	    $main::running{action}{$actionParallelKey}{$actionname} = (($main::running{action}{$actionParallelKey}{$actionname} >= 0) ? ($main::running{action}{$actionParallelKey}{$actionname} + 1) : 1);
	}

    } else {
#
# 'new' means start me......
#
	$frameSeparator="~~~";

	if ($pop =~ /true/ && $ref->{callbacks}) {
	    my $oldcalls = $ref->{callbacks};
	    $oldcalls =~ s/\'//g;

	    my @callbacks = split (/$frameSeparator/, $oldcalls);

	    my $frame;

	    eval "\$frame = $callbacks[0];";
	    
	    my $destination = $frame->{nextaction};
	    my $actionmapper = $frame->{actionmapper};

	    undef $actionmapper if $actionmapper =~ /NULL/;

	    shift(@callbacks);

	    my $callbacks = join ($frameSeparator,@callbacks);
	    
	    my $taskData = {status => "'running'",
			    actionname => "'" . $destination . "'",
			    actionstatus => "'new'",
			    actionmapper => ($actionmapper ? "'$actionmapper'"  : "NULL")};

	    if ($callbacks) {
		$taskData->{callbacks} = "'" . $callbacks . "'" ;
	    } else {
		undef ($ref->{callbacks});
	    }

	    $ref->setTaskData ($taskData);
	} else {
	    my $callbackClause;

	    if ($callback) {
		$callbackClause .= "{nextaction => q(" . scrub($callback) . ")";
		$callbackClause .= ", actionmapper => q(" . scrub($ref->{actionmapper}) . ")" if $ref->{actionmapper};
		$callbackClause .= "}";
	    
		$callbackClause .= $frameSeparator if $ref->{callbacks};
		$callbackClause .= scrub($ref->{callbacks});
	    }

	    $destination =~ s/\'//g;

	    my $taskData = {status => "'running'",
			    actionname => "'$destination'",
			    actionstatus => "'new'",
			    actionmapper => ($actionmapper ? "'$actionmapper'"  : "NULL")};

	    if ($callbackClause) {
		$taskData->{callbacks} = "'" . scrub($callbackClause) . "'" if $callbackClause;
	    } elsif ($ref->{callbacks}) {
		$taskData->{callbacks} = "'" . scrub($ref->{callbacks}) . "'";
	    }
	    $ref->setTaskData ($taskData);
	}
    }
}

#
# can fail a task without a task object
#

sub failTask {
    my $arg = &_dn_options;

    assert::assert ("task::failTask will not run without a \$task_id variable", ($task_id = $arg->{task_id}));
    assert::assert ("task::failTask will not run without a \$db variable", ($db = $arg->{db}));
    if ($allTasks{$task_id}) {
	$allTasks{$task_id}->setTaskData({status => "'failed'",
					  failurereason => "'" . $arg->{failurereason} . "'"});
    } else {
	$arg->{db}->setTaskData($arg->{task_id}, "status = 'failed' " . ($arg->{failurereason} ? ", failurereason = '" . $arg->{failurereason} . "'" : ""));
    }
}

sub fetchContextSimple {
    $ref = shift;
    return $ref->{db}->fetchContextSimple($_[0], $ref->{task_id});
}

sub closelog {
    $ref = shift;

    if ($ref->{taskLogFH}) {
	$ref->{taskLogFH}->close; 
	delete($ref->{taskLogFH});
    }
}

sub _getMapper {
    my $arg = &_dn_options;

    my $task_id = $arg->{task_id};
    my $ChainDB = $arg->{ChainDB};
    my $debug = $arg->{debug};

    my $ret;

    my %mappers = ();

    $ChainDB->loadSQL ($ChainDB->db_specific_construct("getMapper",$task_id), \%mappers);

    for (my $i = 0 ; $i < $mappers{rows}; $i++) {
	$ret .= $mappers{MAPPER}[$i] if $mappers{MAPPER}[$i];
	$ret .= $mappers{ACTIONMAPPER}[$i] if $mappers{ACTIONMAPPER}[$i];
#	$ref->{debug}->debug (1, "mapper is $ret", $task_id);
    }
    $debug->debug (1, "derived mapper for task $task_id: $ret", $task_id) if $debug;
    return $ret;
}

#
# =pod
#
# =over 4
#
# =item getMapper()
#
# Since mappers exist in hierarchical context, we need to load them via a hierarchical query.
#
# EXAMPLE
#
# $thistask->getMapper
#
# =back
#
# =cut
#

sub getMapper {
    my $ref = shift;

    return _getMapper(task_id => $ref->{task_id}, ChainDB => $ref->{db}, debug => $ref->{debug});
}

sub DESTROY {
# close any open file descriptors
    my $ref = shift;

    $ref->{debug}->debug(1, "destroy called for task_id " .  $ref->{task_id}, $ref->{task_id});
    $ref->closelog;

    undef $allTasks{$task_id};
}

sub applyMapper {
    my $arg = &_dn_options;
    my $mapper = $arg->{mapper};
    my $data = $arg->{data};
    my $matchref = $arg->{matchref};

    return $data unless $mapper;

    $_ = $arg->{data};
    eval eval "sprintf (\"" . autoUtil::removeSingleQuotes($mapper) . "\")";
    carp($@ . "(regexp=" . autoUtil::removeSingleQuotes($mapper) . ")\n\n ") if "$@";

    my $ret=$_;

    if ($ret ne $arg->{data}) {
	print STDERR "# mapper applied ($arg->{data} => $ret)\n" ;
	${$matchref} = 1 if $matchref;
    } else {
	${$matchref} = 0 if $matchref;
    }
	    
    $ret;
}

################################################################################################################################################################


sub buildExportData {
    my $ref = shift;
    my %args = @_;
    my $arrayref = $args{arrayref};                                             # the data to be returned by this sub
    my $taskContext = $args{taskContext};
    my %taskHierarchy;                                                          # an unraveling of the parent child relationships.
                                                                                # We will use this to build a complete reference of all
                                                                                # the applicable <export> statements.

    
    $ref->{db}->loadSQL ($ref->{db}->db_specific_construct("buildExportData",$ref->{task_id}), \%taskHierarchy);

    for (my $i = 0; $i < $taskHierarchy{rows} ; $i++) {
	my $task_id = $taskHierarchy{TASK_ID}[$i];
	my $taskname = $taskHierarchy{TASKNAME}[$i];
	my $actionname = $taskHierarchy{ACTIONNAME}[$i];
	my $xmltask = $main::xmltasks{$taskname};                               # fetch the XML reference for this task
	my $xmlaction = $main::xmlactions{$actionname};                         # fetch the XML reference for this action
	my $taskmodule = $main::xmlmodules{$xmltask->{moduleName}} 
	    if ($xmltask);
	my $actionmodule;                                                       # potentially the action is in a different module

	$actionmodule = $main::xmlmodules{$xmlaction->{moduleName}}
            unless ($xmlaction->{moduleName} eq $xmltask->{moduleName});

	my $chaindb = $main::xmlhelper->getProperty(xml);

	foreach my $xml ($taskmodule, $xmltask, $actionmodule, $xmlaction, $chaindb) {
	    $ref->_loadExports(xml => $xml, 
			       exportref => $arrayref,
			       taskContext => $taskContext);
	}
    }
    $ref->{debug}->debug (1, "task $ref->{task_id} exportlist resolved to (" . join(",",@{$arrayref}) . ")" , $ref->{task_id});

    
}

################################################################################################################################################################

sub _loadExports {
    my $ref = shift;
    my %arg = @_;
    my %exports;                                                                # this is a list of all exports loaded; so we don't get dupes.

    my $xml = $arg{xml};
    my $exportref = $arg{exportref};
    my $taskContext = $arg{taskContext};                                        # expand all export statements against the task context

    if ($xml && $xml->{exports}) {
	foreach $export (@{$xml->{exports}[0]->{export}}) {                     # unravel XML structure left by XML::Simple
	    my $expandedText =                                                  # do variable expansion based on the task context
		$ref->{expander}->expand (text => $export->{value},
					  taskContext => $taskContext);
	    if ($expandedText) {
		unless ($exports{$expandedText}) {                              # havent seen this export before so add it in
		    push (@{$exportref}, $expandedText);
		    $exports{$expandedText} = 1;                                # restrict from being added in twice
		}
	    }
	}
    }
}

################################################################################################################################################################


sub filteredjoin {
    my ($delim, @list) = @_;
    my (%seen, @out);
    for my $l (@list) {
        push @out, $l unless $seen{ $l };
        $seen{$l}++;
    }
    return join $delim, @out;
}


sub getExportFilter {
    my $arrayref = shift;
    return filteredjoin('|',@{$arrayref});
}

################################################################################

sub fetchStatus
{
    my $arg = &_dn_options;
    my $db = $arg->{db};
    my $task_id = $arg->{task_id};

    my %results = ();

    $db->loadSQL("select status from task where task_id = $task_id", \%results);

    assert::assert ("one and only one row should be returned from task status query", $results{rows} eq 1);
    $results{STATUS}[0];
}


1;
