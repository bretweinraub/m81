package ChainDB; # -*-perl-*-

use DBI;
use Carp;
use task;
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval );


use assert;
use Carp;

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

    return $ref->{$prop};
}

sub slurp
{
    local ($DATA, $cursor, $verbose) = @_;
    my @row;

    $DATA->{rows} = 0;
    my $max = $cursor->{NUM_OF_FIELDS};
    my $rows = 0;

    for (my $i = 0; $i < $max; $i++) {
	push (@{$DATA->{_fields}},uc($cursor->{NAME}->[$i]));
	print uc($cursor->{NAME}->[$i]) . "\t" if $verbose;
    }
    print "\n" if $verbose;
    while (@row = $cursor->fetchrow_array()) {
	$rows++;
	for (my $i = 0; $i < $max ; $i++) {
	    push (@{$DATA->{uc($cursor->{NAME}->[$i])}},$row[$i]);
	    print $row[$i] . "\t" if $verbose;
	}
	print "\n" if $verbose;
    }
    $DATA->{rows} = $rows;
    $cursor->finish;
}

sub TV_INTERVAL {
    my ($t0,$t1) = @_;
    return tv_interval($t0,$t1) . " secs";
}

sub loadSQL
{
    $ref = shift;
    local ($sql, $DATA, $verbose) = @_;

    if ($ref->{dbtype} eq "Pg") {
	$sql =~ s/nvl/coalesce/gi;
    }

    my $t0 = [gettimeofday];
    $ref->{debug}->debug (1, "$sql")
	if $ref->{debug};
    my $stmt = $ref->{dbh}->prepare($sql);
    $stmt->execute or confess "ERROR: $DBI::errstr";
    my $t1 = [gettimeofday];

    $ref->{debug}->debug (1, "$sql : " . TV_INTERVAL($t0,$t1) ) if $ref->{debug};

    slurp($DATA,$stmt,$verbose) if $DATA;
    return $DATA;
}

sub runSQL
{
    $ref = shift;
    my ($sql) = @_;

    my $t0 = [gettimeofday];

    $ref->{debug}->debug (2, "executing ($sql)");
    $ref->{dbh}->prepare($sql)->execute 
	or confess "ERROR: $DBI::errstr for query $sql";
    my $t1 = [gettimeofday];
    $ref->{debug}->debug (1, "$sql : " . TV_INTERVAL($t0,$t1) ) if $ref->{debug};
}

sub new {
    my $arg = &_dn_options;

    my $ref = {};
    bless $ref, "ChainDB";
    
    map {$ref->setProperty($_, $arg->{$_});} (keys (%{$arg}));

    my $ChainDBxmlElement;

    $ChainDBxmlElement = $ref->{xmlhelper}->getProperty(xml)->{ChainDB}[0]
	if $ref->{xmlhelper};

    if ($ChainDBxmlElement) {
#	my $ChainDBxmlElement = $ref->{xmlhelper}->getProperty(xml)->{ChainDB}[0];
	my $host = $ref->{expander}->expand(text => $ChainDBxmlElement->{host});
	my $sid = $ref->{expander}->expand(text => $ChainDBxmlElement->{sid});
	my $port = $ref->{expander}->expand(text => $ChainDBxmlElement->{port});
	my $username = $ref->{expander}->expand(text => $ChainDBxmlElement->{username});
	my $password = $ref->{expander}->expand(text => $ChainDBxmlElement->{password});
	my $dbtype = $ref->{expander}->expand(text => $ChainDBxmlElement->{dbtype});

	$ref->setProperty('dbtype', $dbtype);
	if ($dbtype eq "oracle") {
	    $ref->setProperty('dbh', DBI->connect("dbi:Oracle:host=$host;sid=$sid;port=$port", "$username", "$password"));
	} elsif ($dbtype eq "Pg") {

	    $ref->setProperty('dbh', DBI->connect("dbi:Pg:host=$host;database=$sid;port=$port", "$username", "$password"));
	} else {
	    confess "you haven't set a dbtype in you ChainDB XML block ... and that makes me mad";
	}
    } else {
	local $dbh;
	require "dbConnect.pl";
	$ref->setProperty('dbtype',"$CONTROLLER_type");
	$ref->setProperty('dbh', $dbh);
    }

#
# Validate that we have the right DB patchlevel.
#


#
#  XXX - this is the old code block where we validated the DB patchlevel
#

    # $ref->loadSQL ("select max(patchlevel) pl from m80patchLog where module_name = 'ChainDB'",
    # 		      \%PL);

    # require "requiredPatchlevel.pl";
    
    # confess 'failed to load $requiredPatchlevel from requiredPatchlevel.pl' unless $requiredPatchlevel;

    # $ref->setProperty("ChainDBPatchLevel", $PL{PL}[0]);

    # confess 'failed to derive database module ChainDB patchlevel' unless $ref->{ChainDBPatchLevel};

    # confess "required ChainDB patchlevel of $ref->{ChainDBPatchLevel}, required $requiredPatchlevel"
    # 	unless $requiredPatchlevel <= $ref->{ChainDBPatchLevel};
    
    return $ref;
};

sub fetchDBTasks
{
    my $ref = shift;
    my $arg = &_dn_options;

    my $group = $arg->{group};
    my $statusListRef= $arg->{status};

    my $dbStatus;

    foreach my $status (@{$statusListRef}) {
	$dbStatus .= ", " if $dbStatus;
	$dbStatus .= "'$status'";
    }
    
    my $sqlstring = "select * from task_v where status in ($dbStatus) and nvl(start_by, " . $ref->db_specific_construct("sysdate") . $ref->db_specific_construct("date_arithmatic","-",1) . ") < " . $ref->db_specific_construct("sysdate") . "";
    $sqlstring .= " and task_group = '$group'" if $group;

    print $sqlstring;

    return $ref->loadSQL($sqlstring, \my %tasks);
}

sub loadTaskHistory
{
    my $ref = shift;
    my ($task_id) = @_;

    my $ret = {};

    $ref->loadSQL($ref->db_specific_construct("loadTaskHistory",$task_id),
		  \my %results, $ref->{verbose});

    for (my $i = 0 ; $i < $results{rows}; $i++) {
	$ret->{$results{ACTIONNAME}[$i]}{$results{ACTIONSTATUS}[$i]} = "true";
    }

    return $ret;
}

sub fetchParentTaskId
{
    my $ref = shift;
    my ($task_id) = @_;

    $ref->loadSQL(
		  "select parent_task_id from task where task_id = $task_id",
		  \my %parent, $ref->{verbose});
    return $parent{PARENT_TASK_ID}[0];
}


sub loadTaskContext
{
    my $ref = shift;
    my ($task_id) = @_;

    my $ret = {};


    $ref->loadSQL($ref->db_specific_construct("recursive_context",$task_id),
		  \my %namespace, $ref->{verbose});

    for (my $i = 0 ; $i < $namespace{rows}; $i++) {
	$ret->{$namespace{TAG}[$i]} = $namespace{VALUE}[$i];
    }

    $ret->{task_id} = $task_id;


    return $ret;
}

BEGIN {
    $ChainDB::failing = 0;
}


sub setTaskData
{
    my $ref = shift;
    my ($task_id, $updateClause) = @_;

    confess "Infinite loop in process $$" if 
	$ChainDB::failing > 1;
    $ChainDB::failing++;
    eval {
	$ref->runSQL("update task set $updateClause where task_id = $task_id");
    };
    confess "end of file detected on database handle for statement update task set $updateClause where task_id = $task_id "
	if $@ =~ /03113/;
    task::failTask(task_id => $task_id,
		   db => $ref,
		   failurereason => substr($@, 0, 255))
	if $@;
    $ChainDB::failing--;
}

sub setActionData
{
    my $ref = shift;
    my ($task_id, $updateClause) = @_;

    eval { 
	$ref->runSQL("update action set $updateClause where action_id = (select cur_action_id from task where task_id = $task_id)");
    };
    task::failTask(task_id => $task_id,
		   db => $ref,
		   failurereason => substr($@, 0, 255))
	if $@;
}

sub fetchContextSimple {
    $ref = shift;
    my ($tag,$task_id) = @_;

    $ref->loadSQL("
select	*
from	(
		select	tag,
			value
		from	task_context
		where	task_id in
			(
				select		task_id
				from 		task 
				start with 	task_id = $task_id
				connect by 	prior parent_task_id = task_id
			)
		and	tag = '$tag'
		order	by
			task_id desc
	)
where	ROWNUM = 1",
		  \my %context);

    return $context{VALUE}[0];
}

sub fetchMappedContext {
    my $ref = shift;
    my %args = @_;
    my $data = {};
    my $task_id = $args{task_id};
    my $argMapper = $args{argMapper};
    my $filter = $args{filter};

    my %context = %{$ref->loadTaskContext($task_id)};
    my $mapper = $argMapper ? $argMapper : task::_getMapper (task_id => $task_id, ChainDB => $ref);

    if ($mapper) {
	for $lmapper (split /;/, $mapper) {
	    map {
		my $d = $_;
		my $matchref;
		{
		    $mapped = task::applyMapper (mapper => $lmapper, data => $d, matchref => \$matchref);
		    $data->{$mapped} = $context{$d} unless ($filter and not $matchref);
		    $data->{$d} = context{$data} if ($mapped ne $d) ;
		}
	    } (keys(%context));
	}
    } else {
	map {
	    my $d = $_;
	    $data->{$d} = $context{$d};
	} (keys(%context));
    }
    return $data;
}

################################################################################################################################################################

sub fetchContextBundle
{
    my $ref = shift;

    my %args = @_;                                                              # load data from @_ array
    my $taskList = $args{taskList};
    my $returnHashRef = $args{returnHashRef};
    my %taskList = %{$taskList};                                                # convert back to a hash from a hashref
    my $sql = "";                                                                    # builds out the SQL query.

    my $doit = undef;

    foreach my $task_id (keys (%taskList)) {
	next if ($taskList{$task_id}->getProperty("status") =~ /queued/ and
		 $taskList{$task_id}->getProperty("task_context"));


	$doit=true;
	if ($sql) {
	    $sql .= " union ";
	}

	$sql .= "select root_id, task_id, tag, value from (";

	$sql .= $ref->db_specific_construct("fetchContextBundle",$task_id); 
	
	$sql .= ") AS sql"

    }

    $_sql = $sql;
    $sql = "select root_id, task_id, tag, value from ($_sql) AS IV order by task_id";

#    confess "$sql";

    $ref->loadSQL($sql,$returnHashRef) if $doit;
}    

################################################################################################################################################################

sub LoadContextFromBundle
{
    my $ref = shift;

    my %args = @_;                                                              # load data from @_ array
    my $contextBundle = $args{contextBundle};
    my %contextBundle = %{$contextBundle};
    my $task_id = $args{task_id};
    my $ret = {};

    for (my $i = 0; $i < $contextBundle{rows}; $i++) {
	$ret->{$contextBundle{TAG}[$i]} = $contextBundle{VALUE}[$i]
	    if ($contextBundle{ROOT_ID}[$i] eq $task_id);
    }

    $ret->{task_id} = $task_id;

    return $ret;
}

sub db_specific_construct
{
    my $ref = shift;
    my $construct = shift;

    my $ret;

    if ($ref->{dbtype} eq "oracle") {
	if ($construct eq "sysdate") {
	    $ret = "sysdate";
	} elsif ($construct eq "date_arithmatic") {
	    $op = shift;
	    $val = shift;
	    $ret = "$op $val";
	} elsif ($construct eq "recursive_context") {
	    $ret = "select tag, value from task_context where task_id in (select task_id from task start with task_id = $task_id connect by prior parent_task_id = task_id) order by task_id";
	} elsif ($construct eq "set_action") {
	    $actionname = shift;
	    $task_id = shift;
	    $ret = "BEGIN P_TASK.SET_ACTION(task_id => $task_id, actionname => '$actionname'); END;";
	} elsif ($construct eq "loadTaskHistory") {
	    $task_id = shift;
	    $ret="select actionname, actionstatus from action where task_id in ( select task_id from task start with task_id = $task_id connect by prior parent_task_id = task_id )";
	} elsif ($construct eq "fetchContextBundle") {
	    $task_id = shift;
	    $ret = "select $task_id root_id, task_id , tag, value from  task_context where task_id in (select task_id from task start with task_id = $task_id connect by prior parent_task_id = task_id)";
	} elsif ($construct eq "getMapper") {
	    $task_id = shift;
	    $ret = "select mapper, actionmapper from task_v, ( select task_id from task start with task_id = $task_id connect by prior parent_task_id = task_id ) tlist where task_v.task_id = tlist.task_id order by task_v.task_id";
	} elsif ($construct eq "buildExportData") {
	    $task_id = shift;
	    $ret = "select task_v.task_id, taskname, actionname from task_v , ( select task_id from task start with task_id = $task_id connect by prior parent_task_id = task_id ) tlist where task_v.task_id = tlist.task_id order by task_v.task_id";
	}

    } elsif ($ref->{dbtype} eq "Pg") {
	if ($construct eq "sysdate") {
	    $ret = "now()";
	} elsif ($construct eq "date_arithmatic") {
	    $op = shift;
	    $val = shift;
	    $ret = "$op interval '$val day'";
	} elsif ($construct eq "recursive_context") {
	    $task_id = shift;
	    $ret = $ref->task_hierarchical_query($task_id,"select tag, value from child_tasks, task_context where child_tasks.task_id = task_context.task_id order by child_tasks.task_id ");
	} elsif ($construct eq "set_action") {
	    $actionname = shift;
	    $task_id = shift;
	    if ( $actionname =~ /\'/) {
		$ret = "select set_action($task_id,$actionname);";
	    } else {
		$ret = "select set_action($task_id,'$actionname');";
	    }
	} elsif ($construct eq "loadTaskHistory") {
	    $task_id = shift;
	    $ret = $ref->task_hierarchical_query($task_id,"select action.task_id,  action_id,  actionname,actionstatus from  child_tasks,  action where  child_tasks.task_id = action.task_id");
	} elsif ($construct eq "fetchContextBundle") {
	    $task_id = shift;
	    $ret = $ref->task_hierarchical_query($task_id,"select $task_id root_id, child_tasks.task_id, tag, value from task_context, child_tasks where task_context.task_id = child_tasks.task_id");
	} elsif ($construct eq "getMapper") {
	    $task_id = shift;
	    $ret = $ref->task_hierarchical_query($task_id,"select mapper, actionmapper from task_v, child_tasks where task_v.task_id = child_tasks.task_id order by task_v.task_id");
	} elsif ($construct eq "buildExportData") {
	    $task_id = shift;
	    $ret = $ref->task_hierarchical_query($task_id, "select task_v.task_id, taskname, actionname from task_v , child_tasks where task_v.task_id = child_tasks.task_id order by task_v.task_id");
	}

    } else {
	confess "Huh!? ... shouldn't be here";
    }
    return $ret;
}


sub task_hierarchical_query
{
    my $ref = shift;

    my $task_id = shift;
    my $append = shift;

    return "WITH RECURSIVE child_tasks as ( select task.task_id, task.parent_task_id from task where task_id = $task_id UNION select task.task_id, task.parent_task_id from task, child_tasks where task.task_id = child_tasks.parent_task_id ) $append";
}

1;
