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

use DB::DBHandleFactory;
use Rails::Generator;
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
my $module;
$module = $ENV{module} if $ENV{module};
my $tableName;
$tableName = $ENV{tableName} if $ENV{tableName};
my $match;
$match = $ENV{match} if $ENV{match};
my $directory = ".";
$directory = $ENV{directory} if $ENV{directory};
$trace = "0";
$trace = $ENV{trace} if $ENV{trace};
$debug = "0";
$debug = $ENV{debug} if $ENV{debug};
my $help = "0";
$help = $ENV{help} if $ENV{help};

GetOptions( 	'module:s'	=> \$module,
	'tableName:s'	=> \$tableName,
	'match:s'	=> \$match,
	'directory:s'	=> \$directory,
	'trace'	=> \$trace,
	'debug+'	=> \$debug,
	'help'	=> \$help,
 );

print_usage() if $help;
unless ($directory) { Warn "directory is required" ; print_usage() ; } 

=pod

=head1 NAME

m80toActiveScaffold.pl    

=head1 SYNOPSIS

generate a Rails Ruby on Rails scaffold from an m80 table

=head1 ARGUMENTS

=over 4


=item 'module:s'

m80 module to convert


=item 'tableName:s'

generate for a single table name


=item 'match:s'

only generate for tables that match this text


=item [REQUIRED] 'directory:s'

rails project home directory


=item 'trace'

The $trace command line flag turns on trace functionality


=item 'debug+'

The $debug command line flag is additive and can be used with the &debugPrint subroutine


=item 'help'

The help command line flag will print the help message



=back



=head1 PERLSCRIPT GENERATED SCRIPTS

This script was generated with the Helpers::PerlScript pre-compiler.

This file was automatically generated from the file: m80toActiveScaffold.pl.m80 by
bweinraub on  (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux
) on Mon Dec 27 18:27:49 2010.

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


Confess "set -module or -tableName"
    unless $module or $tableName;

my $generator = new Rails::Generator (projectRoot => $directory);

if ($tableName) {
    $generator->activeScaffold(tableName => $tableName,layoutName => "default");
} else {
    my $dbhandle = DB::DBHandleFactory::newDBHandle();
    my %results = %{$dbhandle->getData(sql => "select object_name from $module" . "_OBJECTS")};

    debugPrint(2, "Table list is " . Dumper($results{OBJECT_NAME}));

    foreach my $table (@{$results{OBJECT_NAME}}) {
	next if ($match and not $table =~ /$match/i);
	$generator->activeScaffold(tableName => $table,layoutName => "default");
    }
}

cleanup 0; 
