# $m80path = [{command => "embedperl"}];

package ContextExporter;

use Time::HiRes qw( usleep ualarm gettimeofday tv_interval );                   # gettimeofday
use Carp;
use Data::Dumper;

use debug;
use task;
use autoUtil;

my $debug;

sub TV_INTERVAL {
    my ($t0,$t1) = @_;
    return tv_interval($t0,$t1) . " secs";
}

################################################################################################################################################################

################################################################################################################################################################

sub applyMapper {
    my %args = @_;
    my $mapper = $args{mapper};
    my $data = $args{data};
    my $task_id = $args{task_id};

    $debug->debug (3, "applyMapper($mapper,$data,$task_id)", $task_id);

    return $data unless $mapper;

    $_ = $args{data};
    eval eval "sprintf (\"" . autoUtil::removeSingleQuotes($mapper) . "\")";
    carp($@) if "$@";

    $debug->debug (3, "applyMapper: converted $data to $_", $task_id);
    
    $_;
}

################################################################################################################################################################
#
# Takes a context hash and a mapper as arguments.  Pushes the data in into the environment; applies the mappers;
#

sub _exportContext {
    my %args = @_;
    
    my $exportData = $args{exportData};
    my $compiledRegex = $args{compiledRegex};
    my $key = $args{key};
    my $mappedKey = $args{mappedKey};
    my $value = $args{value};
    my $task_id = $args{task_id};
    my $mappedVariables = $args{mappedVariables};

    $debug->debug (2, Dumper($mappedVariables), $task_id)
	if ($debug->{level} >= 1);

    $debug->debug (3, "_exportContext (exportData => $exportData, compiledRegex => $compiledRegex, key => $key, mappedKey => $mappedKey, value => $value)", $task_id);
    $debug->debug (3, "_exportContext (mappedVariables => (" . join(',',keys(%{$mappedVariables})) . "))", $task_id);

    if ($mappedKey ne $key) {                                                   # this means this value was "mapped", so we are marking this key "untouchable"
	$debug->debug (2, "_exportContext: adding $mappedKey to the list of mapped variables", $task_id);
	$mappedVariables->{$mappedKey} = $key;
	$debug->debug (2, "_exportContext (mappedVariables => (" . join(',',keys(%{$mappedVariables})) . "))", $task_id);
    } else {
	if ($mappedVariables->{$mappedKey}) {
	    $debug->debug (2, "suppressing assigment of variable $mappedKey to $value as a map of variable " . $mappedVariables->{$mappedKey} . " has precedence", $task_id);
	    return;
	}
    }

    if ($exportData) {                                                     # this config file include <export> statements
	if ($mappedKey ne $key ||                                          # you mapped it so your probably want to export it
	    $mappedKey =~ $compiledRegex) {                                # does this key match the exported statements?
	    $debug->debug (2, "_exportContext: exporting $mappedKey=$value ; matched \"$1\"", $task_id);
	    $ENV{$mappedKey} = $value ;                                    # yes ... <export> it
	    $debug->debug (3, "_exportContext: \$ENV{$mappedKey} = $value"  , $task_id);
	} else {
	    $debug->debug (2, "_exportContext: suppressing $mappedKey because this variable was not mapped and not in the export filter"  , $task_id);
	    delete $ENV{$mappedKey};                                       # nope .... supress it from the child environment
	}
    } else {
	$ENV{$mappedKey} = $value;                                         # export the mapped value
	$debug->debug (3, "_exportContext: \$ENV{$mappedKey} = $value"  , $task_id);
    }
}

################################################################################################################################################################

sub exportContext {
    my %args = @_;

    my $t0 = [gettimeofday];
    
    my $mapper = $args{mapper};
    my $unifiedContext = $args{unifiedContext};
    my $task_id = $args{task_id};
    my $exportData = $args{exportData};
    $debug = $args{debug};
    my $MapDebug => $args{MapDebug};

    $debug = debug::new (level => 1)
	unless ($debug);
    
    my $regex;                                                                  # regex string built from export data
    my $compiledRegex;                                                          # pre-compiled

    if ($exportData) {
	$regex = "(" . 
	    task::getExportFilter($exportData) . 
	    "|task_id|actionname|AUTOMATOR_STAGE_DIR)";                         # always export task_id/actionname magic variables.
	$debug->debug (1, "running with export filter $regex", $task_id);
	$compiledRegex = qr/$regex/;
    }

    $debug->debug (3, "exportContext($mapper,$unifiedContext,$task_id,$exportData)", $task_id);

    my @maps = split /;/, $mapper;                                              # split the mapper into chunks.
    push (@maps,'') if $#maps < 0;                                              # forces one iteration in the case of no mapper
    my %mappedVariables = ();                                                   # maintain list of mapped variables to keep them from being overwritten

    my $key;
    my $mappedKey;
    foreach $mapper (@maps) {
	$debug->debug (2, "analyzing mapper $mapper");
    }
    foreach $mapper (@maps) {
	map { 
	    my $_debugLevel = $debug->{level};                                  # keep later so as to reset.
	    $key = $_;                                                       # environment key for each context variable

	    $debug->{level} = 3
		if ($MapDebug && $key =~ /$MapDebug/);
	    $debug->debug (3, "export context for tag $key to $unifiedContext->{$key}", $task_id);

	    $mappedKey = applyMapper ( mapper => $mapper,
				       data => $key,
				       task_id => $task_id );
	    $debug->debug (3, "export mapped context for tag $mappedKey to $key", $task_id);

	    _exportContext(exportData => $exportData,
			   compiledRegex => $compiledRegex,
			   key => $key,
			   mappedKey => $mappedKey,
			   value => $unifiedContext->{$key},
			   task_id => $task_id,
			   mappedVariables => \%mappedVariables);
	    
	    if ($mappedKey ne $key) {
		$debug->debug (1, "$mapper applied: \$ENV{" . $mappedKey. "} => $unifiedContext->{$key} ; was $key", $task_id);

		_exportContext(exportData => $exportData,
			       compiledRegex => $compiledRegex,
			       key => $key,
			       mappedKey => $key,                               # note ... same as above
			       value => $unifiedContext->{$key},
			       task_id => $task_id,
			       mappedVariables => \%mappedVariables);

		$debug->debug (2, Dumper (%mappedVariables), $task_id);

	    }
	    $debug->{level} = $_debugLevel;

	} ( keys ( %{$unifiedContext} ) );
    }
    my $t1 = [gettimeofday];

    $debug->debug (1, "exportContext() in the child process ran in " . TV_INTERVAL ($t0,$t1), $task_id);
}

1;
