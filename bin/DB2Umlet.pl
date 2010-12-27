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
use DB::Table;
use UMLet::UXFElement;
use UMLet::UXFDocument;
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
$trace = "0";
$trace = $ENV{trace} if $ENV{trace};
$debug = "0";
$debug = $ENV{debug} if $ENV{debug};
my $help = "0";
$help = $ENV{help} if $ENV{help};

GetOptions( 	'module:s'	=> \$module,
	'trace'	=> \$trace,
	'debug+'	=> \$debug,
	'help'	=> \$help,
 );

print_usage() if $help;
unless ($module) { Warn "module is required" ; print_usage() ; } 

=pod

=head1 NAME

DB2Umlet.pl    

=head1 SYNOPSIS



=head1 ARGUMENTS

=over 4


=item [REQUIRED] 'module:s'

module name to generate


=item 'trace'

The $trace command line flag turns on trace functionality


=item 'debug+'

The $debug command line flag is additive and can be used with the &debugPrint subroutine


=item 'help'

The help command line flag will print the help message



=back



=head1 PERLSCRIPT GENERATED SCRIPTS

This script was generated with the Helpers::PerlScript pre-compiler.

This file was automatically generated from the file: DB2Umlet.pl.m80 by
bret on  (Linux ubuntu 2.6.31-19-generic-pae #56-Ubuntu SMP Thu Jan 28 02:29:51 UTC 2010 i686 GNU/Linux
) on Wed Feb 17 01:07:36 2010.

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


use strict;
my $dbhandle = DB::DBHandleFactory::newDBHandle();

my $rowset = $dbhandle->newRowSet(sql => "select distinct object_name from $module" . "_objects where object_type = 'TABLE'", lc => 't'); #use lower case columns

my $x=0;
my @uxfs;

while ($rowset->next) {
    $x++;
    my $object_name = $rowset->item('OBJECT_NAME');
    my $table = $dbhandle->newTable(name => $object_name);
    my $txt;
    $txt = lc($object_name) . "\n--\n";

    my (%cols) = (%{$table->getColumns()});

    my @keys = keys(%cols);

    map { 
	my $column = $cols{$_};
	
	$txt .= $_ . " " .  $dbhandle->getTypeAsText(data => $column, full => 't') . "\n"
	    if (ref ($column ) =~ /DB::FieldMetaData/);
    } (keys(%cols));

    push(@uxfs, UMLet::UXFElement->new(type => 'com.umlet.element.base.Class',
				       x => $x * 20,
				       y => $x * 20,
				       h => $#keys * 15,
				       w => 100,
				       text => $txt,
				       ));
}    

print Dumper(@uxfs);


my $UXFDocument = UMLet::UXFDocument->new( filename => "test.uxf",
					   );

$UXFDocument->setElements(\@uxfs);

print Dumper($UXFDocument);

$UXFDocument->dump();


# }


#for (my $ndx = 0; $ndx  < $results{rows}; $ndx++) {
#    map {
#	eval '$main::' . $_ . ' = $results{' . $_ . '}[$ndx]';
#    } (keys (%results));
#}
 
cleanup 0; 
