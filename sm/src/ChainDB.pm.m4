package ChainDB; # -*-perl-*-

use DBI;
use Carp;
use task;
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval );

m4_include(`./perloo.m4')m4_dnl `

sub slurp
{
    local ($DATA, $cursor, $verbose) = @_;
    my @row;

    $DATA->{rows} = 0;
    my $max = $cursor->{NUM_OF_FIELDS};
    my $rows = 0;

    for (my $i = 0; $i < $max; $i++) {
	push (@{$DATA->{_fields}},$cursor->{NAME}->[$i]);
	print $cursor->{NAME}->[$i] . "\t" if $verbose;
    }
    print "\n" if $verbose;
    while (@row = $cursor->fetchrow_array()) {
	$rows++;
	for (my $i = 0; $i < $max ; $i++) {
	    push (@{$DATA->{$cursor->{NAME}->[$i]}},$row[$i]);
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

    my $t0 = [gettimeofday];
    $ref->{debug}->debug (2, "$sql")
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
	$ref->setProperty('dbh', DBI->connect("dbi:Oracle:host=$host;sid=$sid;port=$port", "$username", "$password"));
    } else {
	local $dbh;
	require "dbConnect.pl";
	$ref->setProperty('dbh', $dbh);
    }

#
# Validate that we have the right DB patchlevel.
#

    $ref->loadSQL ("select max(patchlevel) pl from m80patchLog where module_name = 'ChainDB'",
		      \%PL);

    require "requiredPatchlevel.pl";
    
    confess 'failed to load $requiredPatchlevel from requiredPatchlevel.pl' unless $requiredPatchlevel;

    $ref->setProperty("ChainDBPatchLevel", $PL{PL}[0]);

    confess 'failed to derive database module ChainDB patchlevel' unless $ref->{ChainDBPatchLevel};

    confess "required ChainDB patchlevel of $ref->{ChainDBPatchLevel}, required $requiredPatchlevel"
	unless $requiredPatchlevel <= $ref->{ChainDBPatchLevel};
    
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
    
    my $sqlstring = "select * from task_v where status in ($dbStatus) and nvl(start_by, SYSDATE-1) < SYSDATE";
    $sqlstring .= " and task_group = '$group'" if $group;

    return $ref->loadSQL($sqlstring, \my %tasks);
}

sub loadTaskHistory
{
    my $ref = shift;
    my ($task_id) = @_;

    my $ret = {};

    $ref->loadSQL("select actionname, actionstatus from action where task_id in ( select task_id from task start with task_id = $task_id connect by prior parent_task_id = task_id )",
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

    $ref->loadSQL(
		  "select tag, value from task_context where task_id in (select task_id from task start with task_id = $task_id connect by prior parent_task_id = task_id) order by task_id",
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

    my $sql;                                                                    # builds out the SQL query.



    foreach my $task_id (keys (%taskList)) {
	next if ($taskList{$task_id}->getProperty("status") =~ /queued/ and
		 $taskList{$task_id}->getProperty("task_context"));
	unless ($sql) {
	    $sql .= "select root_id, task_id, tag, value from (";
	} else {
	    $sql .= " union all ";
	}

	$sql .= "select $task_id root_id, task_id , tag, value from  task_context where task_id in (select task_id from task start with task_id = $task_id connect by prior parent_task_id = task_id)";

    }

    $sql .= ") order by task_id" if $sql;

    $ref->loadSQL($sql,$returnHashRef) if $sql;
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

1;
