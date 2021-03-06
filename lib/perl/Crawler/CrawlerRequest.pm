


=pod

=head1 NAME - Crawler::CrawlerRequest

Crawler::CrawlerRequest description; stub description please expand

=head1 EXAMPLE


    my $Crawler::CrawlerRequest = $Crawler::CrawlerRequest->new();   # stub example .... expand


=cut

# This file was automatically generated from CrawlerRequest.pm.m80 by 
# bweinraub on li264-192 (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux)
# DO NOT EDIT THIS FILE 


package Crawler::CrawlerRequest;

use Carp;
use Data::Dumper;
use Term::ANSIColor qw(:constants);
use strict;
sub Confess (@) {confess BOLD, RED, @_, RESET}
sub Warn (@) { warn YELLOW, BOLD, ON_BLACK, @_, RESET }

use File::Basename;

sub printmsg (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$): @_.\n" ;
}

sub printmsgn (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$): @_\n" ;
}

use fields qw( URL file status dataSet dataSetIndex recordIdentifier debug );

=pod

=head1 CONSTRUCTOR

=over 4

=item Crawler::CrawlerRequest->new()

initializes on object of type Crawler::CrawlerRequest

=back

=cut


# %_allSetters - an array of all setters for all members of the class
my %_allSetters = ();

my %_allMemberAttributes = ();

BEGIN {
# $_allMembers{_TYPE} = 1; # - WHAT IS THIS FOR?
$_allMemberAttributes{URL} = {
          'required' => 1,
          'name' => 'URL',
          'description' => 'URL to crawl'
        }
;
$_allSetters{URL} = \&setURL;
$_allMemberAttributes{file} = {
          'required' => 1,
          'name' => 'file',
          'description' => 'filename to crawl to'
        }
;
$_allSetters{file} = \&setFile;
$_allMemberAttributes{status} = {
          'name' => 'status',
          'default' => 'new',
          'description' => 'stauts of crawl request'
        }
;
$_allSetters{status} = \&setStatus;
$_allMemberAttributes{dataSet} = {
          'name' => 'dataSet',
          'description' => 'database results set that this crawl request was derived from'
        }
;
$_allSetters{dataSet} = \&setDataSet;
$_allMemberAttributes{dataSetIndex} = {
          'name' => 'dataSetIndex',
          'description' => 'index into database results set that this crawl request was derived from'
        }
;
$_allSetters{dataSetIndex} = \&setDataSetIndex;
$_allMemberAttributes{recordIdentifier} = {
          'name' => 'recordIdentifier',
          'description' => 'unique text that corresponds to a human readable identifier for this record (like the "name" of something)'
        }
;
$_allSetters{recordIdentifier} = \&setRecordIdentifier;
$_allMemberAttributes{debug} = {
          'name' => 'debug',
          'description' => 'debug allows an object to specify its debugPrint level'
        }
;
$_allSetters{debug} = \&setDebug;


}

#
# TODO ... needs to merge in the parents attributes; the commented out block is close.
#
sub getReflectionAPI { 
#     my $this = shift; 
#     my %unified = (%{$this->SUPER::getReflectionAPI()}, %_allMemberAttributes);
#     \%unified;
    \%_allMemberAttributes;
}

#
# For some (currently) mysterious reason on perl 5.8.8 on the Linux kernel 2.6.18-8.1.14.el5 there
# is no data in the %_allMemberAttributes.  Therefore here is another way to get a list of member data
# out of the class.
#

sub getMembers {
    my $this = shift;
    my @ret = keys(%{$this});
    \@ret;
}
    
sub new {
    my Crawler::CrawlerRequest $this = shift;

    print STDERR "in Crawler::CrawlerRequest::new(" . join (",", @_) . ")\n" if $ENV{DEBUG};
    Confess "Missing the value for an argument (even nulls) on creation of Crawler::CrawlerRequest" if scalar @_ % 2 != 0;

    my %args = @_;

    unless (ref $this) {
	$this = fields::new($this);
    }

    #
    # This next block tries to set any of the values that you passed into this
    # constructor. You might have said new X( arg1 => 123, arg2 => 456); It is going
    # to take that and try to call setArg1(123), setArg2(123). I.e. it is going
    # to derive the setter for your named argument (by upper casing the first letter
    # of your argument name) and then if it finds that the object can call the
    # setter (i.e. it is defined in this class or any parent class) it will call it.
    #
    # If the setter cannot be found - then assume that this is a bad argument
    # that was passed to the function and die with that information.
    #
    foreach my $key (keys(%args)) {

        my $setterName = $key;                              # workspace for determining the name of the setter
        $setterName =~ s/^(\w)/uc($1)/e;                    # uc the first char of the argument name. I.e. arg1 => Arg1.
        $setterName = "set" . $setterName;                  # prepend "set" to the uppercased argument name.

        if (my $fn = $this->UNIVERSAL::can($setterName)) {  # test that the object can call this function
            $fn->($this,$args{$key});                       # and call it
        } else {                                            # else fail with an error. 
            Confess "Field named \"$key\" is not defined in object Crawler::CrawlerRequest. typo ?\n";
        }
    }


    Confess "cannot initialize object of type Crawler::CrawlerRequest without required member variable URL"
        unless exists $this->{URL};

    Confess "cannot initialize object of type Crawler::CrawlerRequest without required member variable file"
        unless exists $this->{file};

    $this->{status} = "new" unless defined $this->{status};


    #### __new is the magic "pre-constructor".  You can intercept a call to the parent
    #### constructor by defining a __new() procedure in your class.

    eval {Crawler::CrawlerRequest::__new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?Crawler::CrawlerRequest::__new/;

    #### Now call the parent constructor, if any.

    eval {$this->SUPER::new(%args)};

    croak $@ if $@
	and $@ !~ /^Can\'t locate object method/;

    ####
    #### Typically this following contains your "real" constructor"
    #### so if you are debugging this next call my be a good candidate to step into.
    ####

    eval {Crawler::CrawlerRequest::_new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?Crawler::CrawlerRequest::_new/;

    $this;
}

###  END GENERATED CODE

=pod

=head1 MEMBERS AND MEMBER ACCESS METHODS

=cut



=pod

=head2 URL => "any string"*

URL to crawl

=cut

sub getURL {

=pod

=head3 $CrawlerRequest->getURL ()


getter for member URL

=cut

    my $this = shift;





    return $this->{URL};
}
sub setURL {

=pod

=head3 $CrawlerRequest->setURL (URL => "any string"*)

 - URL ("any string")		 : URL to crawl

setter for member URL

=cut

    my $this = shift;


    my $URL = shift;
    Confess "argument 'URL' is required for Crawler::CrawlerRequest->setURL()" unless defined $URL;



    $this->{URL} = $URL;
    return $URL;
}



=pod

=head2 file => "any string"*

filename to crawl to

=cut

sub getFile {

=pod

=head3 $CrawlerRequest->getFile ()


getter for member file

=cut

    my $this = shift;





    return $this->{file};
}
sub setFile {

=pod

=head3 $CrawlerRequest->setFile (file => "any string"*)

 - file ("any string")		 : filename to crawl to

setter for member file

=cut

    my $this = shift;


    my $file = shift;
    Confess "argument 'file' is required for Crawler::CrawlerRequest->setFile()" unless defined $file;



    $this->{file} = $file;
    return $file;
}



=pod

=head2 status => "any string" (default: "new")

stauts of crawl request

=cut

sub getStatus {

=pod

=head3 $CrawlerRequest->getStatus ()


getter for member status

=cut

    my $this = shift;





    return $this->{status};
}
sub setStatus {

=pod

=head3 $CrawlerRequest->setStatus (status => "any string")

 - status ("any string")		 : stauts of crawl request

setter for member status

=cut

    my $this = shift;


    my $status = shift;



    $this->{status} = $status;
    return $status;
}



=pod

=head2 dataSet => "any string"

database results set that this crawl request was derived from

=cut

sub getDataSet {

=pod

=head3 $CrawlerRequest->getDataSet ()


getter for member dataSet

=cut

    my $this = shift;





    return $this->{dataSet};
}
sub setDataSet {

=pod

=head3 $CrawlerRequest->setDataSet (dataSet => "any string")

 - dataSet ("any string")		 : database results set that this crawl request was derived from

setter for member dataSet

=cut

    my $this = shift;


    my $dataSet = shift;



    $this->{dataSet} = $dataSet;
    return $dataSet;
}



=pod

=head2 dataSetIndex => "any string"

index into database results set that this crawl request was derived from

=cut

sub getDataSetIndex {

=pod

=head3 $CrawlerRequest->getDataSetIndex ()


getter for member dataSetIndex

=cut

    my $this = shift;





    return $this->{dataSetIndex};
}
sub setDataSetIndex {

=pod

=head3 $CrawlerRequest->setDataSetIndex (dataSetIndex => "any string")

 - dataSetIndex ("any string")		 : index into database results set that this crawl request was derived from

setter for member dataSetIndex

=cut

    my $this = shift;


    my $dataSetIndex = shift;



    $this->{dataSetIndex} = $dataSetIndex;
    return $dataSetIndex;
}



=pod

=head2 recordIdentifier => "any string"

unique text that corresponds to a human readable identifier for this record (like the "name" of something)

=cut

sub getRecordIdentifier {

=pod

=head3 $CrawlerRequest->getRecordIdentifier ()


getter for member recordIdentifier

=cut

    my $this = shift;





    return $this->{recordIdentifier};
}
sub setRecordIdentifier {

=pod

=head3 $CrawlerRequest->setRecordIdentifier (recordIdentifier => "any string")

 - recordIdentifier ("any string")		 : unique text that corresponds to a human readable identifier for this record (like the "name" of something)

setter for member recordIdentifier

=cut

    my $this = shift;


    my $recordIdentifier = shift;



    $this->{recordIdentifier} = $recordIdentifier;
    return $recordIdentifier;
}



=pod

=head2 debug => "any string"

debug allows an object to specify its debugPrint level

=cut

sub getDebug {

=pod

=head3 $CrawlerRequest->getDebug ()


getter for member debug

=cut

    my $this = shift;





    return $this->{debug};
}
sub setDebug {

=pod

=head3 $CrawlerRequest->setDebug (debug => "any string")

 - debug ("any string")		 : debug allows an object to specify its debugPrint level

setter for member debug

=cut

    my $this = shift;


    my $debug = shift;



    $this->{debug} = $debug;
    return $debug;
}



=pod

=head1 GENERALIZED OBJECT METHODS 

=cut



=pod

=over 4

=item _require (member1,member2,...,memberN)

will iterate over arguments and validate there is a non null value for each of the listed object members

=back

=cut


sub _require
{
    my $this = shift;
    map { 
	Confess "required member variable $_ not set" unless $this->getProperty($_);
    } (@_);
}

sub debugPrint { 
    my $this = shift;
    my $level = shift;
    Confess 'you\'ve called debugPrint - convert this call to $this->debugPrint()'
	unless ref($this);
    if ($this->{debug} >= $level || $main::debug >= $level) {
        my ($caller) = (caller(1))[3];
        $caller = "[$caller]:" if $caller;
        my $date = localtime;
        print STDERR $caller . $date . ":" . basename($0) . ":($$): @_.\n" ;
    }
}

sub debugPrint_s {   # static version of debug print
    my $level = shift;
    if ($main::debug >= $level) {
        my ($caller) = (caller(1))[3];
        $caller = "[$caller]:" if $caller;
        my $date = localtime;
        print STDERR $caller . $date . ":" . basename($0) . ":($$): @_.\n" ;
    }
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

1;

=pod

=head1 NOTES ON THIS DOCUMENTATION

In method signatures a * denotes a required option.

This file was automatically generated from CrawlerRequest.pm.m80 by 
bweinraub on li264-192 (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux)


=head1 OBJECT METHODS

=cut



sub _new {

=pod

=head3 $CrawlerRequest->_new ()


callback constructor, do not call directly use new() instead

=cut

    my $this = shift;

    Confess "Crawler::CrawlerRequest->_new requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;



}
