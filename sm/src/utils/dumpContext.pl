#!/usr/bin/perl

use Carp;
use Getopt::Long;
use Data::Dumper;
use Pod::Usage;
use File::Basename;

sub print_usage {
    if (scalar @_ > 0) {
        print STDERR "@_\n";
        exit(1);
    } else {
        pod2usage({ -exitval => 1, 
                    -verbose => ($debug ? $debug : 1),
                    -output  => \*STDERR});
    }
}

use ChainDB;
use task;
use debug;
use ContextExporter;
use File::Basename;

sub printmsg (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$): @_.\n" ;
}

sub printmsgn (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$): @_\n" ;
}

sub docmdi {    
    printmsg "@_";
    system(@_);

    my $rc;
    if ($? == -1) {
        $rc = -1; printmsg "failed to execute: $!";
    }
    elsif ($? & 127) {
        $rc = $? & 127;
        printmsg "child process died with signal $rc, ", ($? & 128) ? 'with' : 'without', " coredump";
    }
    else {
        $rc = $? >> 8;
        if ($rc) {
            printmsg "child process exited with value $rc - ignoring\n";
        }
    }
    $rc;
}
use Carp;

sub docmdq (@) {    
    system(@_);

    my $rc;
    if ($? == -1) {
        $rc = -1; printmsg "failed to execute: $!";
	exit -1;
    }
    elsif ($? & 127) {
        $rc = $? & 127;
        printmsg "child process died with signal $rc, ", ($? & 128) ? 'with' : 'without', " coredump";
	exit $rc;
    }
    else {
        $rc = $? >> 8;
        if ($rc) {
            printmsg "child process exited with value $rc - Exiting!";
            exit $rc;
        }
    }
}

sub docmd (@) {    
    printmsg "@_" ;
    docmdq(@_);
}
sub cleanup ($@) { 
    my $exit_code = shift;
    printmsg @_ if scalar @_;
    printmsg "exiting with exit code = $exit_code";
    exit $exit_code;
}
sub debugPrint ($@) { 
    my $level = shift;
    if ($debug >= $level) {
        my ($caller) = (caller(1))[3];
        $caller = "[$caller]:" if $caller;
        my $date = localtime;
        print STDERR $caller . $date . ":" . basename($0) . ":($$): @_.\n" ;
    }
}
use Term::ANSIColor qw(:constants);
sub Confess (@) {confess BOLD, RED, @_, RESET}
sub Warn (@) { warn YELLOW, BOLD, ON_BLACK, "@_", RESET }
my $task_id;
$task_id = $ENV{task_id} if $ENV{task_id};
my $action_id;
$action_id = $ENV{action_id} if $ENV{action_id};
my $mapper;
$mapper = $ENV{mapper} if $ENV{mapper};
my $filter;
$filter = $ENV{filter} if $ENV{filter};
my $nocontext;
$nocontext = $ENV{nocontext} if $ENV{nocontext};
$trace = "0";
$trace = $ENV{trace} if $ENV{trace};
$debug = "0";
$debug = $ENV{debug} if $ENV{debug};
my $help = "0";
$help = $ENV{help} if $ENV{help};

GetOptions( 	'task_id:i'	=> \$task_id,
	'action_id:i'	=> \$action_id,
	'mapper:s'	=> \$mapper,
	'filter:s'	=> \$filter,
	'nocontext'	=> \$nocontext,
	'trace'	=> \$trace,
	'debug+'	=> \$debug,
	'help'	=> \$help,
 );

print_usage() if $help;

=pod

=head1 NAME

dumpContext.pl    

=head1 SYNOPSIS

Small tool to output the actual context of a task (after all parent/child inheritence and mapper applications).

=head1 SAMPLE OUTPUT


=head1 EXAMPLES

dumpContext.pl -task_id 851

Sometimes when developing it can be very useful to load the context into your current shell:

eval $(dumpContext.pl -task 881)

=head1 PREREQUISITES

If you use m80 to set your environment for connection to the ChainDB database, then m80 --execute is probably
required.



=head1 ARGUMENTS

=over 4


=item 'task_id:i'

Starting in v3.0 -task_id is deprecated.  Use -action-id instead.  -task_id is not export filtered and never will be.  If you think something isn't working correctly with this option, that's probably because its not.  Use -action_id.


=item 'action_id:i'

Starting in v3.0 this is the preferred method.  Specifying the action-id will get you the correct context for an action.  It includes the m80 environment and is correctly mapped and filtered.  USE IT.


=item 'mapper:s'

mapper to apply to dumped context.  This option is not supported when specifying the action id


=item 'filter:s'

filter the dumped context


=item 'nocontext'

specifies that mappers will be applied, but no context will be applied.  Useful for applying a context map to things other context data, like maybe the output of loadCollections.  Only implemented for -action_id


=item 'trace'

The $trace command line flag turns on trace functionality


=item 'debug+'

The $debug command line flag is additive and can be used with the &debugPrint subroutine


=item 'help'

The help command line flag will print the help message



=back



=head1 PERLSCRIPT GENERATED SCRIPTS

This script was generated with the Helpers::PerlScript pre-compiler.

This file was automatically generated from the file: dumpContext.pl.m80 by
bret on localhost.localdomain (Linux localhost.localdomain 2.6.9-78.0.1.EL #1 Tue Aug 5 10:49:42 EDT 2008 i686 i686 i386 GNU/Linux
) on Fri Aug 14 10:15:40 2009.

The following functions are included by default. The functions all have 
prototypes that make the parens optional.

=over 4

=item printmsg (@)

Will print a formatted message to STDERR.

=item docmdi (@)

Will run a system command and ignore the return code

=item docmd (@)

Will run a system command and exit with the return code of the child process, if it is non-zero

=item debugPrint ($@)

Use it like C<debugPrint 1, 'Some info message'> or C<debugPrint 2, 'Some trace message'> and
it will print out a little more information than the printmsg command.

=back

=cut

# ## This is autogenerated documentation


Confess "set only one of -task_id and -action_id"
    if $task_id and $action_id;

Confess "nocontext not implemented for -task_id"
    if ($nocontext and not $action_id);

use lib dirname($0);

$debug = debug::new ('level' => ($debugLevel) ? $debugLevel : 0,
		     prefix => '# ');

my $ChainDB = ChainDB::new (verbose => $verbose);

if ($task_id) {                                                                 # ye olde dumpc() from before context filters.
    my %context = %{$ChainDB->loadTaskContext($task_id)};
    
    my $parent_task_id = $ChainDB->fetchParentTaskId($task_id);
    
    my $mapper = $mapper ? $mapper : task::_getMapper (task_id => $task_id, ChainDB => $ChainDB);
    
    my $splitText=";";		# assigning to a variable will hopefully fix emacs colorization
    
    if ($mapper) {
	for $lmapper (split /$splitText/, $mapper) { 
	    print "# mapper is $lmapper\n";
	    map {
		my $data = $_;
		my $matchref;
		{
		    $mapped = task::applyMapper (mapper => $lmapper, data => $data, matchref => \$matchref);
		    print "export $mapped=\'$context{$data}\'\n" unless ($filter and not $matchref);
		    print "export $data=\'$context{$data}\' # also exporting unmapped version\n" if ($mapped ne $data) ;
		    }
	    } (keys(%context));
	}
    } else {
	map {
	    my $data = $_;
	    print "export $data=\'$context{$data}\'\n";

	} (keys(%context));
    }

    print "export parent_task_id=\'$parent_task_id\'\n" if $parent_task_id;
} elsif ($action_id) { #########################################################################################################################################
    $ChainDB->loadSQL ("select task_id, export_filter from action where action_id = $action_id", \my %action, $verbose);

    my $task_id = $action{TASK_ID}[0];
    my $export_filter = $action{EXPORT_FILTER}[0];
    my $parent_task_id = $ChainDB->fetchParentTaskId($task_id);

    Confess "No task_id could be derived from the action_id $action_id.  Are you sure that is a valid action_id?"
	unless defined $task_id;

    my %unifiedContext = ($nocontext ? %ENV
			  : (%ENV, %{$ChainDB->loadTaskContext($task_id)}));

    my $mapper = task::_getMapper (task_id => $task_id, ChainDB => $ChainDB);

    print "# task mapper derived as $mapper\n";

    my @exportData = split(/\|/,$export_filter);                                # convert back the format exportContext() expects ... sort of a hack

    ContextExporter::exportContext ( mapper => $mapper, 
				     debug => $debug,
				     unifiedContext => \%unifiedContext,
				     task_id => $task_id,
				     exportData => \@exportData);

    my $env_size = 0;
    foreach $key (keys(%ENV)) {
	print "export $key=\'$ENV{$key}\'\n";                                   # dump the mapped filter environment to STDOUT
	$env_size += length($key) + length($ENV{$key});
    }
    print "export parent_task_id=\'$parent_task_id\'\n" if $parent_task_id;

    print "# subshell environment size is: $env_size \n";
} else { ######################################################################################################################################################
    Confess "please use -task_id or -action_id";
}

cleanup 0; 
