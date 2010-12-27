


=pod

=head1 NAME - Sugar::CustomField

Custom Field to generate for sugar

=head1 EXAMPLE


    my $CustomField = $CustomField->new();   # stub example .... expand


=cut

# This file was automatically generated from CustomField.pm.m80 by 
# bweinraub on li264-192 (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux)
# DO NOT EDIT THIS FILE 


package Sugar::CustomField;

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

use fields qw( sourceKey targetTable mapDescriptor type sugarKey alterTableName alterColumnName targetHandle metaData dataType dataTypeFull targetKey precision genSeparator fixedLength debug );

=pod

=head1 CONSTRUCTOR

=over 4

=item Sugar::CustomField->new()

initializes on object of type Sugar::CustomField

=back

=cut


# %_allSetters - an array of all setters for all members of the class
my %_allSetters = ();

my %_allMemberAttributes = ();

BEGIN {
# $_allMembers{_TYPE} = 1; # - WHAT IS THIS FOR?
$_allMemberAttributes{sourceKey} = {
          'required' => 1,
          'name' => 'sourceKey',
          'description' => 'sourceKey for this custom field'
        }
;
$_allSetters{sourceKey} = \&setSourceKey;
$_allMemberAttributes{targetTable} = {
          'required' => 1,
          'name' => 'targetTable',
          'description' => 'targetTable for this custom field'
        }
;
$_allSetters{targetTable} = \&setTargetTable;
$_allMemberAttributes{mapDescriptor} = {
          'required' => 1,
          'name' => 'mapDescriptor',
          'description' => 'mapDescriptor for this custom field'
        }
;
$_allSetters{mapDescriptor} = \&setMapDescriptor;
$_allMemberAttributes{type} = {
          'required' => 1,
          'name' => 'type',
          'description' => 'type for this custom field'
        }
;
$_allSetters{type} = \&setType;
$_allMemberAttributes{sugarKey} = {
          'required' => 1,
          'name' => 'sugarKey',
          'description' => 'sugarKey for this custom field'
        }
;
$_allSetters{sugarKey} = \&setSugarKey;
$_allMemberAttributes{alterTableName} = {
          'required' => 1,
          'name' => 'alterTableName',
          'description' => 'alterTableName for this custom field'
        }
;
$_allSetters{alterTableName} = \&setAlterTableName;
$_allMemberAttributes{alterColumnName} = {
          'required' => 1,
          'name' => 'alterColumnName',
          'description' => 'alterColumnName for this custom field'
        }
;
$_allSetters{alterColumnName} = \&setAlterColumnName;
$_allMemberAttributes{targetHandle} = {
          'required' => 1,
          'name' => 'targetHandle',
          'description' => 'targetHandle for this custom field'
        }
;
$_allSetters{targetHandle} = \&setTargetHandle;
$_allMemberAttributes{metaData} = {
          'required' => 1,
          'name' => 'metaData',
          'description' => 'metaData for this custom field'
        }
;
$_allSetters{metaData} = \&setMetaData;
$_allMemberAttributes{dataType} = {
          'required' => 1,
          'name' => 'dataType',
          'description' => 'dataType for this custom field'
        }
;
$_allSetters{dataType} = \&setDataType;
$_allMemberAttributes{dataTypeFull} = {
          'required' => 1,
          'name' => 'dataTypeFull',
          'description' => 'dataTypeFull for this custom field'
        }
;
$_allSetters{dataTypeFull} = \&setDataTypeFull;
$_allMemberAttributes{targetKey} = {
          'required' => 1,
          'name' => 'targetKey',
          'description' => 'targetKey for this custom field'
        }
;
$_allSetters{targetKey} = \&setTargetKey;
$_allMemberAttributes{precision} = {
          'required' => 1,
          'name' => 'precision',
          'description' => 'precision for this custom field'
        }
;
$_allSetters{precision} = \&setPrecision;
$_allMemberAttributes{genSeparator} = {
          'name' => 'genSeparator',
          'description' => 'generate a separator after this field'
        }
;
$_allSetters{genSeparator} = \&setGenSeparator;
$_allMemberAttributes{fixedLength} = {
          'name' => 'fixedLength',
          'description' => 'hard coded text field length - overrides derived value'
        }
;
$_allSetters{fixedLength} = \&setFixedLength;
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
    my Sugar::CustomField $this = shift;

    print STDERR "in Sugar::CustomField::new(" . join (",", @_) . ")\n" if $ENV{DEBUG};
    Confess "Missing the value for an argument (even nulls) on creation of Sugar::CustomField" if scalar @_ % 2 != 0;

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
            Confess "Field named \"$key\" is not defined in object Sugar::CustomField. typo ?\n";
        }
    }


    Confess "cannot initialize object of type Sugar::CustomField without required member variable sourceKey"
        unless exists $this->{sourceKey};

    Confess "cannot initialize object of type Sugar::CustomField without required member variable targetTable"
        unless exists $this->{targetTable};

    Confess "cannot initialize object of type Sugar::CustomField without required member variable mapDescriptor"
        unless exists $this->{mapDescriptor};

    Confess "cannot initialize object of type Sugar::CustomField without required member variable type"
        unless exists $this->{type};

    Confess "cannot initialize object of type Sugar::CustomField without required member variable sugarKey"
        unless exists $this->{sugarKey};

    Confess "cannot initialize object of type Sugar::CustomField without required member variable alterTableName"
        unless exists $this->{alterTableName};

    Confess "cannot initialize object of type Sugar::CustomField without required member variable alterColumnName"
        unless exists $this->{alterColumnName};

    Confess "cannot initialize object of type Sugar::CustomField without required member variable targetHandle"
        unless exists $this->{targetHandle};

    Confess "cannot initialize object of type Sugar::CustomField without required member variable metaData"
        unless exists $this->{metaData};

    Confess "cannot initialize object of type Sugar::CustomField without required member variable dataType"
        unless exists $this->{dataType};

    Confess "cannot initialize object of type Sugar::CustomField without required member variable dataTypeFull"
        unless exists $this->{dataTypeFull};

    Confess "cannot initialize object of type Sugar::CustomField without required member variable targetKey"
        unless exists $this->{targetKey};

    Confess "cannot initialize object of type Sugar::CustomField without required member variable precision"
        unless exists $this->{precision};


    #### __new is the magic "pre-constructor".  You can intercept a call to the parent
    #### constructor by defining a __new() procedure in your class.

    eval {Sugar::CustomField::__new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?Sugar::CustomField::__new/;

    #### Now call the parent constructor, if any.

    eval {$this->SUPER::new(%args)};

    croak $@ if $@
	and $@ !~ /^Can\'t locate object method/;

    ####
    #### Typically this following contains your "real" constructor"
    #### so if you are debugging this next call my be a good candidate to step into.
    ####

    eval {Sugar::CustomField::_new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?Sugar::CustomField::_new/;

    $this;
}

###  END GENERATED CODE

=pod

=head1 MEMBERS AND MEMBER ACCESS METHODS

=cut



=pod

=head2 sourceKey => "any string"*

sourceKey for this custom field

=cut

sub getSourceKey {

=pod

=head3 $CustomField->getSourceKey ()


getter for member sourceKey

=cut

    my $this = shift;





    return $this->{sourceKey};
}
sub setSourceKey {

=pod

=head3 $CustomField->setSourceKey (sourceKey => "any string"*)

 - sourceKey ("any string")		 : sourceKey for this custom field

setter for member sourceKey

=cut

    my $this = shift;


    my $sourceKey = shift;
    Confess "argument 'sourceKey' is required for Sugar::CustomField->setSourceKey()" unless defined $sourceKey;



    $this->{sourceKey} = $sourceKey;
    return $sourceKey;
}



=pod

=head2 targetTable => "any string"*

targetTable for this custom field

=cut

sub getTargetTable {

=pod

=head3 $CustomField->getTargetTable ()


getter for member targetTable

=cut

    my $this = shift;





    return $this->{targetTable};
}
sub setTargetTable {

=pod

=head3 $CustomField->setTargetTable (targetTable => "any string"*)

 - targetTable ("any string")		 : targetTable for this custom field

setter for member targetTable

=cut

    my $this = shift;


    my $targetTable = shift;
    Confess "argument 'targetTable' is required for Sugar::CustomField->setTargetTable()" unless defined $targetTable;



    $this->{targetTable} = $targetTable;
    return $targetTable;
}



=pod

=head2 mapDescriptor => "any string"*

mapDescriptor for this custom field

=cut

sub getMapDescriptor {

=pod

=head3 $CustomField->getMapDescriptor ()


getter for member mapDescriptor

=cut

    my $this = shift;





    return $this->{mapDescriptor};
}
sub setMapDescriptor {

=pod

=head3 $CustomField->setMapDescriptor (mapDescriptor => "any string"*)

 - mapDescriptor ("any string")		 : mapDescriptor for this custom field

setter for member mapDescriptor

=cut

    my $this = shift;


    my $mapDescriptor = shift;
    Confess "argument 'mapDescriptor' is required for Sugar::CustomField->setMapDescriptor()" unless defined $mapDescriptor;



    $this->{mapDescriptor} = $mapDescriptor;
    return $mapDescriptor;
}



=pod

=head2 type => "any string"*

type for this custom field

=cut

sub getType {

=pod

=head3 $CustomField->getType ()


getter for member type

=cut

    my $this = shift;





    return $this->{type};
}
sub setType {

=pod

=head3 $CustomField->setType (type => "any string"*)

 - type ("any string")		 : type for this custom field

setter for member type

=cut

    my $this = shift;


    my $type = shift;
    Confess "argument 'type' is required for Sugar::CustomField->setType()" unless defined $type;



    $this->{type} = $type;
    return $type;
}



=pod

=head2 sugarKey => "any string"*

sugarKey for this custom field

=cut

sub getSugarKey {

=pod

=head3 $CustomField->getSugarKey ()


getter for member sugarKey

=cut

    my $this = shift;





    return $this->{sugarKey};
}
sub setSugarKey {

=pod

=head3 $CustomField->setSugarKey (sugarKey => "any string"*)

 - sugarKey ("any string")		 : sugarKey for this custom field

setter for member sugarKey

=cut

    my $this = shift;


    my $sugarKey = shift;
    Confess "argument 'sugarKey' is required for Sugar::CustomField->setSugarKey()" unless defined $sugarKey;



    $this->{sugarKey} = $sugarKey;
    return $sugarKey;
}



=pod

=head2 alterTableName => "any string"*

alterTableName for this custom field

=cut

sub getAlterTableName {

=pod

=head3 $CustomField->getAlterTableName ()


getter for member alterTableName

=cut

    my $this = shift;





    return $this->{alterTableName};
}
sub setAlterTableName {

=pod

=head3 $CustomField->setAlterTableName (alterTableName => "any string"*)

 - alterTableName ("any string")		 : alterTableName for this custom field

setter for member alterTableName

=cut

    my $this = shift;


    my $alterTableName = shift;
    Confess "argument 'alterTableName' is required for Sugar::CustomField->setAlterTableName()" unless defined $alterTableName;



    $this->{alterTableName} = $alterTableName;
    return $alterTableName;
}



=pod

=head2 alterColumnName => "any string"*

alterColumnName for this custom field

=cut

sub getAlterColumnName {

=pod

=head3 $CustomField->getAlterColumnName ()


getter for member alterColumnName

=cut

    my $this = shift;





    return $this->{alterColumnName};
}
sub setAlterColumnName {

=pod

=head3 $CustomField->setAlterColumnName (alterColumnName => "any string"*)

 - alterColumnName ("any string")		 : alterColumnName for this custom field

setter for member alterColumnName

=cut

    my $this = shift;


    my $alterColumnName = shift;
    Confess "argument 'alterColumnName' is required for Sugar::CustomField->setAlterColumnName()" unless defined $alterColumnName;



    $this->{alterColumnName} = $alterColumnName;
    return $alterColumnName;
}



=pod

=head2 targetHandle => "any string"*

targetHandle for this custom field

=cut

sub getTargetHandle {

=pod

=head3 $CustomField->getTargetHandle ()


getter for member targetHandle

=cut

    my $this = shift;





    return $this->{targetHandle};
}
sub setTargetHandle {

=pod

=head3 $CustomField->setTargetHandle (targetHandle => "any string"*)

 - targetHandle ("any string")		 : targetHandle for this custom field

setter for member targetHandle

=cut

    my $this = shift;


    my $targetHandle = shift;
    Confess "argument 'targetHandle' is required for Sugar::CustomField->setTargetHandle()" unless defined $targetHandle;



    $this->{targetHandle} = $targetHandle;
    return $targetHandle;
}



=pod

=head2 metaData => "any string"*

metaData for this custom field

=cut

sub getMetaData {

=pod

=head3 $CustomField->getMetaData ()


getter for member metaData

=cut

    my $this = shift;





    return $this->{metaData};
}
sub setMetaData {

=pod

=head3 $CustomField->setMetaData (metaData => "any string"*)

 - metaData ("any string")		 : metaData for this custom field

setter for member metaData

=cut

    my $this = shift;


    my $metaData = shift;
    Confess "argument 'metaData' is required for Sugar::CustomField->setMetaData()" unless defined $metaData;



    $this->{metaData} = $metaData;
    return $metaData;
}



=pod

=head2 dataType => "any string"*

dataType for this custom field

=cut

sub getDataType {

=pod

=head3 $CustomField->getDataType ()


getter for member dataType

=cut

    my $this = shift;





    return $this->{dataType};
}
sub setDataType {

=pod

=head3 $CustomField->setDataType (dataType => "any string"*)

 - dataType ("any string")		 : dataType for this custom field

setter for member dataType

=cut

    my $this = shift;


    my $dataType = shift;
    Confess "argument 'dataType' is required for Sugar::CustomField->setDataType()" unless defined $dataType;



    $this->{dataType} = $dataType;
    return $dataType;
}



=pod

=head2 dataTypeFull => "any string"*

dataTypeFull for this custom field

=cut

sub getDataTypeFull {

=pod

=head3 $CustomField->getDataTypeFull ()


getter for member dataTypeFull

=cut

    my $this = shift;





    return $this->{dataTypeFull};
}
sub setDataTypeFull {

=pod

=head3 $CustomField->setDataTypeFull (dataTypeFull => "any string"*)

 - dataTypeFull ("any string")		 : dataTypeFull for this custom field

setter for member dataTypeFull

=cut

    my $this = shift;


    my $dataTypeFull = shift;
    Confess "argument 'dataTypeFull' is required for Sugar::CustomField->setDataTypeFull()" unless defined $dataTypeFull;



    $this->{dataTypeFull} = $dataTypeFull;
    return $dataTypeFull;
}



=pod

=head2 targetKey => "any string"*

targetKey for this custom field

=cut

sub getTargetKey {

=pod

=head3 $CustomField->getTargetKey ()


getter for member targetKey

=cut

    my $this = shift;





    return $this->{targetKey};
}
sub setTargetKey {

=pod

=head3 $CustomField->setTargetKey (targetKey => "any string"*)

 - targetKey ("any string")		 : targetKey for this custom field

setter for member targetKey

=cut

    my $this = shift;


    my $targetKey = shift;
    Confess "argument 'targetKey' is required for Sugar::CustomField->setTargetKey()" unless defined $targetKey;



    $this->{targetKey} = $targetKey;
    return $targetKey;
}



=pod

=head2 precision => "any string"*

precision for this custom field

=cut

sub getPrecision {

=pod

=head3 $CustomField->getPrecision ()


getter for member precision

=cut

    my $this = shift;





    return $this->{precision};
}
sub setPrecision {

=pod

=head3 $CustomField->setPrecision (precision => "any string"*)

 - precision ("any string")		 : precision for this custom field

setter for member precision

=cut

    my $this = shift;


    my $precision = shift;
    Confess "argument 'precision' is required for Sugar::CustomField->setPrecision()" unless defined $precision;



    $this->{precision} = $precision;
    return $precision;
}



=pod

=head2 genSeparator => "any string"

generate a separator after this field

=cut

sub getGenSeparator {

=pod

=head3 $CustomField->getGenSeparator ()


getter for member genSeparator

=cut

    my $this = shift;





    return $this->{genSeparator};
}
sub setGenSeparator {

=pod

=head3 $CustomField->setGenSeparator (genSeparator => "any string")

 - genSeparator ("any string")		 : generate a separator after this field

setter for member genSeparator

=cut

    my $this = shift;


    my $genSeparator = shift;



    $this->{genSeparator} = $genSeparator;
    return $genSeparator;
}



=pod

=head2 fixedLength => "any string"

hard coded text field length - overrides derived value

=cut

sub getFixedLength {

=pod

=head3 $CustomField->getFixedLength ()


getter for member fixedLength

=cut

    my $this = shift;





    return $this->{fixedLength};
}
sub setFixedLength {

=pod

=head3 $CustomField->setFixedLength (fixedLength => "any string")

 - fixedLength ("any string")		 : hard coded text field length - overrides derived value

setter for member fixedLength

=cut

    my $this = shift;


    my $fixedLength = shift;



    $this->{fixedLength} = $fixedLength;
    return $fixedLength;
}



=pod

=head2 debug => "any string"

debug allows an object to specify its debugPrint level

=cut

sub getDebug {

=pod

=head3 $CustomField->getDebug ()


getter for member debug

=cut

    my $this = shift;





    return $this->{debug};
}
sub setDebug {

=pod

=head3 $CustomField->setDebug (debug => "any string")

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

This file was automatically generated from CustomField.pm.m80 by 
bweinraub on li264-192 (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux)


=head1 OBJECT METHODS

=cut



sub _new {

=pod

=head3 $CustomField->_new ()


callback constructor, do not call directly use new() instead

=cut

    my $this = shift;

    Confess "Sugar::CustomField->_new requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;



}
