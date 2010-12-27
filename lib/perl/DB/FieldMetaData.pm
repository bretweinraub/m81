


=pod

=head1 NAME - DB::FieldMetaData


 DB independent represention of the metadata for a field.  In common usage 
 the constructor is never called.  Instead these objects are created when 
 creating a new object of class DB::Table. 


=head1 EXAMPLE


  my $FieldMetaData = $FieldMetaData->new();   # stub example .... expand

  # creating a field on the fly (and dcloning it to avoid polluting the initial object).

  my $sourceTable = { ... } # type of DB::Table;

  my %columns = %{$sourceTable->getColumns()};

  $columns{rid} = DB::FieldMetaData->new(name => "rid",
					 type => DB::FieldMetaData::getDataType(data => "NUMBER"),
					 precision => 10,
					 handle => $this->getSourceHandle(),
					 scale => 0));


  


=cut

# This file was automatically generated from FieldMetaData.pm.m80 by 
# bret on ubuntu (Linux ubuntu 2.6.31-19-generic-pae #56-Ubuntu SMP Thu Jan 28 02:29:51 UTC 2010 i686 GNU/Linux)
# DO NOT EDIT THIS FILE 


package DB::FieldMetaData;

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

use fields qw( type name scale dateFormat handle precision debug );

=pod

=head1 CONSTRUCTOR

=over 4

=item DB::FieldMetaData->new()

initializes on object of type DB::FieldMetaData

=back

=cut


# %_allSetters - an array of all setters for all members of the class
my %_allSetters = ();

my %_allMemberAttributes = ();

BEGIN {
# $_allMembers{_TYPE} = 1; # - WHAT IS THIS FOR?
$_allMemberAttributes{type} = {
          'required' => 1,
          'name' => 'type',
          'description' => 'Name of the document to generate'
        }
;
$_allSetters{type} = \&setType;
$_allMemberAttributes{name} = {
          'required' => 1,
          'name' => 'name',
          'description' => 'name of this column'
        }
;
$_allSetters{name} = \&setName;
$_allMemberAttributes{scale} = {
          'required' => 1,
          'name' => 'scale',
          'description' => 'Name of the document to generate'
        }
;
$_allSetters{scale} = \&setScale;
$_allMemberAttributes{dateFormat} = {
          'name' => 'dateFormat',
          'description' => 'certain data types (like MySQL date) need special date format management'
        }
;
$_allSetters{dateFormat} = \&setDateFormat;
$_allMemberAttributes{handle} = {
          'required' => 1,
          'ref' => 'DB::DBHandle',
          'name' => 'handle',
          'description' => 'Handle that was used to derive this metadata'
        }
;
$_allSetters{handle} = \&setHandle;
$_allMemberAttributes{precision} = {
          'required' => 1,
          'name' => 'precision',
          'description' => 'Name of the document to generate'
        }
;
$_allSetters{precision} = \&setPrecision;
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
    my DB::FieldMetaData $this = shift;

    print STDERR "in DB::FieldMetaData::new(" . join (",", @_) . ")\n" if $ENV{DEBUG};
    Confess "Missing the value for an argument (even nulls) on creation of DB::FieldMetaData" if scalar @_ % 2 != 0;

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
            Confess "Field named \"$key\" is not defined in object DB::FieldMetaData. typo ?\n";
        }
    }


    Confess "cannot initialize object of type DB::FieldMetaData without required member variable type"
        unless exists $this->{type};

    Confess "cannot initialize object of type DB::FieldMetaData without required member variable name"
        unless exists $this->{name};

    Confess "cannot initialize object of type DB::FieldMetaData without required member variable scale"
        unless exists $this->{scale};

    Confess "cannot initialize object of type DB::FieldMetaData without required member variable handle"
        unless exists $this->{handle};

    Confess "cannot initialize object of type DB::FieldMetaData without required member variable precision"
        unless exists $this->{precision};


    #### __new is the magic "pre-constructor".  You can intercept a call to the parent
    #### constructor by defining a __new() procedure in your class.

    eval {DB::FieldMetaData::__new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?DB::FieldMetaData::__new/;

    #### Now call the parent constructor, if any.

    eval {$this->SUPER::new(%args)};

    croak $@ if $@
	and $@ !~ /^Can\'t locate object method/;

    ####
    #### Typically this following contains your "real" constructor"
    #### so if you are debugging this next call my be a good candidate to step into.
    ####

    eval {DB::FieldMetaData::_new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?DB::FieldMetaData::_new/;

    $this;
}

###  END GENERATED CODE

=pod

=head1 MEMBERS AND MEMBER ACCESS METHODS

=cut



=pod

=head2 type => "any string"*

Name of the document to generate

=cut

sub getType {

=pod

=head3 $FieldMetaData->getType ()


getter for member type

=cut

    my $this = shift;





    return $this->{type};
}
sub setType {

=pod

=head3 $FieldMetaData->setType (type => "any string"*)

 - type ("any string")		 : Name of the document to generate

setter for member type

=cut

    my $this = shift;


    my $type = shift;
    Confess "argument 'type' is required for DB::FieldMetaData->setType()" unless defined $type;



    $this->{type} = $type;
    return $type;
}



=pod

=head2 name => "any string"*

name of this column

=cut

sub getName {

=pod

=head3 $FieldMetaData->getName ()


getter for member name

=cut

    my $this = shift;





    return $this->{name};
}
sub setName {

=pod

=head3 $FieldMetaData->setName (name => "any string"*)

 - name ("any string")		 : name of this column

setter for member name

=cut

    my $this = shift;


    my $name = shift;
    Confess "argument 'name' is required for DB::FieldMetaData->setName()" unless defined $name;



    $this->{name} = $name;
    return $name;
}



=pod

=head2 scale => "any string"*

Name of the document to generate

=cut

sub getScale {

=pod

=head3 $FieldMetaData->getScale ()


getter for member scale

=cut

    my $this = shift;





    return $this->{scale};
}
sub setScale {

=pod

=head3 $FieldMetaData->setScale (scale => "any string"*)

 - scale ("any string")		 : Name of the document to generate

setter for member scale

=cut

    my $this = shift;


    my $scale = shift;
    Confess "argument 'scale' is required for DB::FieldMetaData->setScale()" unless defined $scale;



    $this->{scale} = $scale;
    return $scale;
}



=pod

=head2 dateFormat => "any string"

certain data types (like MySQL date) need special date format management

=cut

sub getDateFormat {

=pod

=head3 $FieldMetaData->getDateFormat ()


getter for member dateFormat

=cut

    my $this = shift;





    return $this->{dateFormat};
}
sub setDateFormat {

=pod

=head3 $FieldMetaData->setDateFormat (dateFormat => "any string")

 - dateFormat ("any string")		 : certain data types (like MySQL date) need special date format management

setter for member dateFormat

=cut

    my $this = shift;


    my $dateFormat = shift;



    $this->{dateFormat} = $dateFormat;
    return $dateFormat;
}



=pod

=head2 handle => DB::DBHandle*

Handle that was used to derive this metadata

=cut

sub getHandle {

=pod

=head3 $FieldMetaData->getHandle ()


getter for member handle

=cut

    my $this = shift;





    return $this->{handle};
}
sub setHandle {

=pod

=head3 $FieldMetaData->setHandle (handle => DB::DBHandle*)

 - handle (DB::DBHandle)		 : Handle that was used to derive this metadata

setter for member handle

=cut

    my $this = shift;


    my $handle = shift;
    Confess "argument 'handle' is required for DB::FieldMetaData->setHandle()" unless defined $handle;
    eval {my $dummy = $handle->isa("DB::DBHandle");};Confess "$@\n" . Dumper($handle) if $@;
    if (defined $handle) { Confess "argument 'handle' of method DB::FieldMetaData->setHandle() is required to be of reference type DB::DBHandle, but it looks to be of type " . ref ($handle)  unless $handle->isa("DB::DBHandle");}



    $this->{handle} = $handle;
    return $handle;
}



=pod

=head2 precision => "any string"*

Name of the document to generate

=cut

sub getPrecision {

=pod

=head3 $FieldMetaData->getPrecision ()


getter for member precision

=cut

    my $this = shift;





    return $this->{precision};
}
sub setPrecision {

=pod

=head3 $FieldMetaData->setPrecision (precision => "any string"*)

 - precision ("any string")		 : Name of the document to generate

setter for member precision

=cut

    my $this = shift;


    my $precision = shift;
    Confess "argument 'precision' is required for DB::FieldMetaData->setPrecision()" unless defined $precision;



    $this->{precision} = $precision;
    return $precision;
}



=pod

=head2 debug => "any string"

debug allows an object to specify its debugPrint level

=cut

sub getDebug {

=pod

=head3 $FieldMetaData->getDebug ()


getter for member debug

=cut

    my $this = shift;





    return $this->{debug};
}
sub setDebug {

=pod

=head3 $FieldMetaData->setDebug (debug => "any string")

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

This file was automatically generated from FieldMetaData.pm.m80 by 
bret on ubuntu (Linux ubuntu 2.6.31-19-generic-pae #56-Ubuntu SMP Thu Jan 28 02:29:51 UTC 2010 i686 GNU/Linux)


=head1 OBJECT METHODS

=cut



sub _new { 
    
=pod

=head3 $FieldMetaData->_new ()


callback constructor, do not call directly use new() instead

=cut

    my $this = shift;

    Confess "DB::FieldMetaData->_new requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;


 

    do {
	my $handle = $this->getHandle();

	if ($this->getType() == 9) {

	    $this->setDateFormat($handle ? $handle->getSmallDateFormat(date => $this->getType())
				 : 'YYYY-MM-DD');

	    $this->debugPrint (1, " setting date format for column " . $this->getName() . " of type DATE (no time) to " .
			       $this->getDateFormat());
	}

	$this->setName(lc($this->getName()));
    };
}


################################################################################

sub getDataType {
   
=pod

=head3 $FieldMetaData->getDataType (data => "any string"*)

 - data ("any string")		 : data to process


Takes a string type and returns a DBI datatype.  For more information on DBI types see the DBI Documentation

 SQL_CHAR             1
 SQL_NUMERIC          2
 SQL_DECIMAL          3
 SQL_INTEGER          4
 SQL_SMALLINT         5
 SQL_FLOAT            6
 SQL_REAL             7
 SQL_DOUBLE           8
 SQL_DATE             9
 SQL_TIME            10
 SQL_TIMESTAMP       11
 SQL_VARCHAR         12
 SQL_LONGVARCHAR     -1
 SQL_BINARY          -2
 SQL_VARBINARY       -3
 SQL_LONGVARBINARY   -4
 SQL_BIGINT          -5
 SQL_TINYINT         -6
 SQL_BIT             -7
 SQL_WCHAR           -8
 SQL_WVARCHAR        -9
 SQL_WLONGVARCHAR   -10



=cut

    Confess "DB::FieldMetaData::getDataType requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $data = $args{data};
    Confess "argument 'data' is required for DB::FieldMetaData::getDataType()" unless defined $data;



    do {
      SWITCH: {
	  $data =~ /WLONGVARCHAR/ && do {
	      return -10;
	      last SWITCH;
	  };
	  $data =~ /WVARCHAR/ && do {
	      return -9;
	      last SWITCH;
	  };
	  $data =~ /WCHAR/ && do {
	      return -8;
	      last SWITCH;
	  };
	  $data =~ /LONGVARCHAR/ && do {
	      return -1;
	      last SWITCH;
	  };
	  $data =~ /VARCHAR/ && do {
	      return 12;
	      last SWITCH;
	  };
	  $data =~ /CHAR/ && do {
	      return 1;
	      last SWITCH;
	  };
	  $data =~ /NUMERIC/ && do {
	      return 2;
	      last SWITCH;
	  };
	  $data =~ /DECIMAL/ && do {
	      return 3;
	      last SWITCH;
	  };
	  $data =~ /INTEGER/ && do {
	      return 4;
	      last SWITCH;
	  };
	  $data =~ /SMALLINT/ && do {
	      return 5;
	      last SWITCH;
	  };
	  $data =~ /FLOAT/ && do {
	      return 6;
	      last SWITCH;
	  };
	  $data =~ /REAL/ && do {
	      return 7;
	      last SWITCH;
	  };
	  $data =~ /DOUBLE/ && do {
	      return 8;
	      last SWITCH;
	  };
	  $data =~ /DATE/ && do {
	      return 9;
	      last SWITCH;
	  };
	  $data =~ /TIMESTAMP/ && do {
	      return 11;
	      last SWITCH;
	  };
	  $data =~ /TIME/ && do {
	      return 10;
	      last SWITCH;
	  };
	  $data =~ /LONGVARBINARY/ && do {
	      return -4;
	      last SWITCH;
	  };
	  $data =~ /VARBINARY/ && do {
	      return -3;
	      last SWITCH;
	  };
	  $data =~ /BINARY/ && do {
	      return -2;
	      last SWITCH;
	  };
	  $data =~ /BIGINT/ && do {
	      return -5;
	      last SWITCH;
	  };
	  $data =~ /TINYINT/ && do {
	      return -6;
	      last SWITCH;
	  };
	  $data =~ /BIT/ && do {
	      return -7;
	      last SWITCH;
	  };
      }
	Confess "could not find a matching type for $data";
    };
}