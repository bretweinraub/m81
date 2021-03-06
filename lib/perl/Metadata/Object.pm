


=pod

=head1 NAME - Metadata::Object

Base class for all metadata objects

=head1 EXAMPLE


    my $Object = $Object->new();   # stub example .... expand


=cut

# This file was automatically generated from Object.pm.m80 by 
# bweinraub on li264-192 (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux)
# DO NOT EDIT THIS FILE 


package Metadata::Object;

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

use Utils::ISAutil;
use Utils::FunctionalProgramming;
use fields qw( name aliases sortOrder requireName debug );

=pod

=head1 CONSTRUCTOR

=over 4

=item Metadata::Object->new()

initializes on object of type Metadata::Object

=back

=cut


# %_allSetters - an array of all setters for all members of the class
my %_allSetters = ();

my %_allMemberAttributes = ();

BEGIN {
# $_allMembers{_TYPE} = 1; # - WHAT IS THIS FOR?
$_allMemberAttributes{name} = {
          'name' => 'name',
          'type' => 'string',
          'description' => 'Name of this object'
        }
;
$_allSetters{name} = \&setName;
$_allMemberAttributes{aliases} = {
          'name' => 'aliases',
          'type' => 'string',
          'description' => 'aliases for this object'
        }
;
$_allSetters{aliases} = \&setAliases;
$_allMemberAttributes{sortOrder} = {
          'name' => 'sortOrder',
          'type' => 'string',
          'description' => 'can be set to force sort order for output functions'
        }
;
$_allSetters{sortOrder} = \&setSortOrder;
$_allMemberAttributes{requireName} = {
          'name' => 'requireName',
          'type' => 'string',
          'description' => 'deprecated; can be set to force a name be defined for this object'
        }
;
$_allSetters{requireName} = \&setRequireName;
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
    my Metadata::Object $this = shift;

    print STDERR "in Metadata::Object::new(" . join (",", @_) . ")\n" if $ENV{DEBUG};
    Confess "Missing the value for an argument (even nulls) on creation of Metadata::Object" if scalar @_ % 2 != 0;

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
            Confess "Field named \"$key\" is not defined in object Metadata::Object. typo ?\n";
        }
    }



    #### __new is the magic "pre-constructor".  You can intercept a call to the parent
    #### constructor by defining a __new() procedure in your class.

    eval {Metadata::Object::__new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?Metadata::Object::__new/;

    #### Now call the parent constructor, if any.

    eval {$this->SUPER::new(%args)};

    croak $@ if $@
	and $@ !~ /^Can\'t locate object method/;

    ####
    #### Typically this following contains your "real" constructor"
    #### so if you are debugging this next call my be a good candidate to step into.
    ####

    eval {Metadata::Object::_new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?Metadata::Object::_new/;

    $this;
}

###  END GENERATED CODE

=pod

=head1 MEMBERS AND MEMBER ACCESS METHODS

=cut



=pod

=head2 name => "any string"

Name of this object

=cut

sub getName {

=pod

=head3 $Object->getName ()


getter for member name

=cut

    my $this = shift;





    return $this->{name};
}
sub setName {

=pod

=head3 $Object->setName (name => "any string")

 - name ("any string")		 : Name of this object

setter for member name

=cut

    my $this = shift;


    my $name = shift;



    $this->{name} = $name;
    return $name;
}



=pod

=head2 aliases => "any string"

aliases for this object

=cut

sub getAliases {

=pod

=head3 $Object->getAliases ()


getter for member aliases

=cut

    my $this = shift;





    return $this->{aliases};
}
sub setAliases {

=pod

=head3 $Object->setAliases (aliases => "any string")

 - aliases ("any string")		 : aliases for this object

setter for member aliases

=cut

    my $this = shift;


    my $aliases = shift;



    $this->{aliases} = $aliases;
    return $aliases;
}



=pod

=head2 sortOrder => "any string"

can be set to force sort order for output functions

=cut

sub getSortOrder {

=pod

=head3 $Object->getSortOrder ()


getter for member sortOrder

=cut

    my $this = shift;





    return $this->{sortOrder};
}
sub setSortOrder {

=pod

=head3 $Object->setSortOrder (sortOrder => "any string")

 - sortOrder ("any string")		 : can be set to force sort order for output functions

setter for member sortOrder

=cut

    my $this = shift;


    my $sortOrder = shift;



    $this->{sortOrder} = $sortOrder;
    return $sortOrder;
}



=pod

=head2 requireName => "any string"

deprecated; can be set to force a name be defined for this object

=cut

sub getRequireName {

=pod

=head3 $Object->getRequireName ()


getter for member requireName

=cut

    my $this = shift;





    return $this->{requireName};
}
sub setRequireName {

=pod

=head3 $Object->setRequireName (requireName => "any string")

 - requireName ("any string")		 : deprecated; can be set to force a name be defined for this object

setter for member requireName

=cut

    my $this = shift;


    my $requireName = shift;



    $this->{requireName} = $requireName;
    return $requireName;
}



=pod

=head2 debug => "any string"

debug allows an object to specify its debugPrint level

=cut

sub getDebug {

=pod

=head3 $Object->getDebug ()


getter for member debug

=cut

    my $this = shift;





    return $this->{debug};
}
sub setDebug {

=pod

=head3 $Object->setDebug (debug => "any string")

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

This file was automatically generated from Object.pm.m80 by 
bweinraub on li264-192 (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux)


=head1 OBJECT METHODS

=cut



sub _new {

=pod

=head3 $Object->_new ()


callback constructor, do not call directly use new() instead

=cut

    my $this = shift;

    Confess "Metadata::Object->_new requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;



}

use Exporter;
use UNIVERSAL qw(can);
#use YAML::Active qw(assert_hashref hash_activate);

=pod

=head1 NAME

MetaDataObjects.pm - base class for Object Oriented Metadata system

=head1 DESCRIPTION

Put this class in the @ISA array of your class. It will give you a 
default dump() and dumpObjectTypes() functions (along with some other
helpers). See Below for the whole list.

Then create objects of your type and at the end, dump and parse them.

=head1 EXAMPLE

  push (@allObjects, new WLVersion (wls_major_version => "9",
				  wls_minor_version => "01"));
  dumpObjects(@allObjects);
  dumpObjectTypes(@allObjects);

=head1 EXPORTER

  @EXPORT = qw( ObjectDumper 
    dumpObjects 
    dumpObjectTypes 
    tag2shell 
    assertNotStatic 
    AssignUnlessSet 
    Require 
    SetDefaults );

=cut

# @Metadata::Object::ISA = qw( Exporter );
# @Metadata::Object::EXPORT = qw( ObjectDumper dumpObjects dumpObjectTypes tag2shell assertNotStatic AssignUnlessSet Require SetDefaults rmapcar get_hash );

our @ISA = qw( Exporter );
our @EXPORT = qw( ObjectDumper dumpObjects dumpObjectTypes tag2shell assertNotStatic AssignUnlessSet Require SetDefaults rmapcar get_hash );

our %allMDOs;                                                                   # all metadata objects

use vars qw( $VERSION );

$VERSION = '0.01';

=pod

=head1 BASE FUNCTIONS

=cut

#
# characterizations of parse syntax.
# We are starting to need a way for objects to control
# thier parsing mechanism. This is getting too complicated
# for this implementation. That said... 
#

my @_allowedParseCharacteristics = qw( InsertIntoGlobal );

sub setParseCharacteristic { 
    if (in_array($_[1], @_allowedParseCharacteristics)) { 
        $MetaDataObject::_parseCharacteristics->{$_[1]} = 1 ;
      } 
}

sub characteristicSet { return $MetaDataObject::_parseCharacteristics->{$_[1]} }


sub in_array { my ($t, @arr) = @_; return grep { /$t/ } @arr }

sub _new {
    my ($class, %args) = @_;
    my $name = ref($class) || $class;
    my $this = bless \%args, ref($class) || $class;
    map {$this->setProperty($_, $args{$_});} (keys (%args));
    
    $this->setRequireName(1);
#    $self->_init();
    if ($this->getRequireName()) {
        Confess "name is a required attribute of the $name object" unless $this->prop('name');
    }

    $this->debugPrint (1, "checking name duplication type: $name ; name : " . $this->getName());
    
    Confess "found duplicate object with type $name and name " . $this->getName()
	if $allMDOs{$name}{($this->getName() ? $this->getName() : "__anon__")};
    $allMDOs{$name}{($this->getName() ? $this->getName() : "__anon__")} = 1;
    $this;
}

# sub _init {
#     print STDERR "MetaDataObject::_init $_[0] : ", ref($_[0]), "\n";
#     Confess"Abstract method MetaDataObject::_init called!";
# }

#require 'ObjectDocumentation.pl';

#our %ObjectDocs;
our %defaults;

# $MetaDataObject::ObjectDocs{'MetaDataObject'} = {
#     name => "Unique identifier for the object by object type.  This means the real \"unique\" name of the object is \"type.name\"",
#     aliases => "aliases is used to create synonyms for the name of any object",
#     DEV => 'A general purpose flag that says that some development mode is requested for this test. Action code can use this field to decide NOT to do work for example.',
# };


=pod

=over 4

=item prop($tag [, $value])

$this->prop(tag);
$this->prop(tag,value);

If passed one argument, feeds its arguments to the "getProperty" method.
If passed two arguments, feeds its arguments to the "setProperty" method,

=back

=cut


sub AssignUnlessSet {
    map {
	$_[0]->setProperty ( ${$_}[0], ${$_}[1] ) 
	    unless $_[0]->{ ${$_}[0]} 
    } (@{$_[1]})
}

sub Require {
    my ($this) = @_;
    map {
	Confess "$_ is a required attribute of the " . $this->{name} . " object" 
	    unless ( exists $this->{$_} && defined $this->{$_} );               # exists is checked first since defined may have the side effect of creating the key
    } (@{$_[1]})
}


sub prop {
    my ($this, $prop, $val) = @_;

    if ( defined($val) ) {
	$this->setProperty( $prop, $val ) ;
    } elsif ( $prop ) {
	return $this->getProperty( $prop );
    }
}


=pod

=over 4

=item getProperty ($tag)

$this->getProperty(tag);

Returns the value of "tag" for the object.

=back

=cut


sub getProperty {
    my ($this, $prop) = @_;

    return $this->{$prop} if $this->{$prop};
}


=pod

=item setProperty ($tag, $value)

$this->setProperty('tag','value');

Basic "setter" method.  If the 'tag' portion of the call is not found with associated documentation in ObjectDocumentation.pl,
a fatal error is thrown.

=back

=cut


sub setProperty {
    my ($this, $prop, $val) = @_;
 
#     my $found;
#     foreach my $class (@{_isa(ref($this))}) {
# 	do {
# 	    $found=1;
# 	    last;
# 	} if $ObjectDocs{$class}{$prop} || $MetaDataObject::ObjectDocs{$class}{$prop};
#     }
    
#     Confess "property '$prop' (" . join (",", @{_isa(ref($this))}) . ") does not have a definition in %ObjectDocs" unless $found;
    $this->{$prop} = $val;
}



=pod

=item setProperties()

$obj->setProperties(tag1 => value1, tag2 => value2);

=back

=cut


sub setProperties {
    my ($self, %args) = @_;
    map {
	print STDERR "$_ => $args{$_}\n";
	$self->setProperty($_, $args{$_});
    } (keys (%args));
}



=pod

=item dumpObjectTypes()

This is a static function. 'use MetaDataObject' will load this
into the main namespace. Pass it a list of objects to dump type
on.

=back

=cut


sub recurseObjectHierarchy
{
    my (@objs) = @_;

    my @allobjects = @objs;

    # stubbed out for now.

    return \@allobjects;
}


my %_classes;

sub dumpObjectTypes {
    my (@objs) = @_;
    my ($o, $x);

    my $c = sub {
        my ($obj) = @_;
	foreach my $class (@{_isa(ref($obj))}) {
##            print STDERR "ALL _ $class\n";
            next if $class eq 'Exporter' || $class eq 'MetaDataObject';
            if ($obj->prop('name')) {
                push @{ $MetaDataObject::_classes{ $class } }, $obj->prop('name') ;
            }
	}
    };
    rmapcar( $c, @objs );

    my $x;
    for my $class (keys %MetaDataObject::_classes) {
        my %uniq;
        @uniq{ @{ $MetaDataObject::_classes{ $class } } } = 1;
        my $val = join ' ', keys %uniq;
#
# strip whitespace
#
        $val =~ s/^\s+//g; 
        $val =~ s/\s+$//g; 
        $class =~ s/\:+/_/g; 
        $x .= uc $class . " ";
        $o .= "export ALL_" . uc($class) . "S=\"" . $val . "\"\n";
    }
    print $o;
    $x =~ s/^\s+//; $x =~ s/\s+$//;
    print 'export ALL_OBJECTS="' . $x . '"' . "\n";
    
}


=pod

=item dumpObjects()

This is a static function. 'use MetaDataObject' will load this
into the main namespace. The object list will be checked for
collisions.

=back

=cut


sub dumpObjects {
    my (@objs) = @_;
    undef %MetaDataObject::_data;
    for my $obj (@objs) {
        $obj->parse();
    }
    export();
}


=pod

=item ObjectDumper()

This is a static function. 'use MetaDataObject' will load this
into the main namespace. The object list will be checked for
collisions, dumped and all object types will be dumped too.

=back

=cut


sub ObjectDumper {
    &MetaDataObject::dumpObjects(@_);
    &MetaDataObject::dumpObjects(@_);
}


sub assertNotStatic
{
    my ($this) = @_;

    Confess "assertNotStatic called outside of object context" unless $this;

    $_ = ref ($this);
  SWITCH: {
          /SCALAR/ && do {last SWITCH};
          /ARRAY/ && do {last SWITCH};
          /HASH/ && do {last SWITCH};
          /CODE/ && do {last SWITCH};
          /REF/ && do {last SWITCH};
          /GLOB/ && do {last SWITCH};
          /LVALUE/ && do {last SWITCH};
          /\w+/ && do {return};
      }
    Confess "assertNotStatic: object method appendProperty called in static context";
}

sub appendProperty {
    my ($self, $prop, $val) = @_;

    if ($self->{$prop}) {
	$self->setProperty($prop, $self->getProperty($prop) . " " . $val);
    } else {
	$self->setProperty($prop,$val);
    }
}

sub deleteProperty {
    my ($self, $prop) = @_;
    return delete( $self->{$prop} );
}

sub _assert {
    my ($self, $test) = @_;
    return 0 unless $self->{$test};
    return 1;
}

sub tag2shell {
    my ($self, $tag) = @_;
    
#
# the following line makes this function
#
    $tag = $self unless $tag;
    $tag =~ s/-/_/g;
    $tag =~ s/\./_/g;
    return $tag;
}

sub dump {
    my ($self, $namespace) = @_;
    undef %MetaDataObject::_data;
    $self->parse($namespace);
    $self->export();
}

sub export {
    my ($self) = @_;
    for my $k ( sort keys %MetaDataObject::_data) {
        my $v = $MetaDataObject::_data{$k};
        # strip leading and trailing whitespace
        $v =~ s/^\s+//; $v =~ s/\s+$//;
        print "export " . tag2shell($k) . "=\"$v\"\n";
    }
}

sub get_hash {
    my (@objs) = @_;

    undef %MetaDataObject::_data;
    for my $obj (@objs) {
        $obj->parse();
    }

    my %data = ();
    for my $k ( sort keys %MetaDataObject::_data) {
        my $v = $MetaDataObject::_data{$k};
        # strip leading and trailing whitespace
        $v =~ s/^\s+//; $v =~ s/\s+$//;
        $data{tag2shell($k)} = $v;
    }

    my %all_data = ();
    my $c = sub {
        my ($obj) = @_;
	foreach my $class (@{_isa(ref($obj))}) {
            if ($obj->prop('name')) {
                push @{ $all_data{ $class } }, $obj->prop('name') ;
            }
	}
    };
    rmapcar( $c, @objs );

    my $x;

    for my $class (keys %all_data) {
        my %uniq;
        @uniq{ @{ $all_data{ $class } } } = 1;
        my $val = join ' ', keys %uniq;
        $val =~ s/^\s+//g; $val =~ s/\s+$//g; 
        $class =~ s/\:+/_/g; 
        $x .= uc $class . " ";
        $data{"ALL_" . uc($class) . "S"} = $val;
    }
    # ALL_OBJECTS
    $x =~ s/^\s+//; $x =~ s/\s+$//;
    $data{ALL_OBJECTS} = $x;

    return %data;
}

our %suppress = (
		 '_parseCharacteristics' => "true",
		 'requireName' => "true",
		 '_show_warnings' => "true",
		 'sortOrder' => 't',
		 '_data' => 'true',
		 '_collisions' => 'true',
		 name => "true",
		 '__package__' => "true",
		 ALLINSTANCES => "true",
		 );

my (%recused_namespaces, %_data, %_collisions, $_ALIAS_RECURSION, %_anon_objects);

{
    my $_warnings = 1;
    sub no_warnings { $_warnings = 0 }
    sub warnings_on { return $_warnings }

    sub setSortOrder { $_[0]->{sortOrder} = $_[1] }
}

sub validate_data {
    my ($self, $key, $value, $append) = @_;
    
    return unless $key;

    # 
    # JIM: TODO - this means that x => [ $x, $x, $x ]
    # is not legitimate. The resultant value will be x => $x.
    # Change the parse algorithm to fix this. (It disallows append if the value
    # is already in the list.
    #
    if ($append) {
        unless ($MetaDataObject::_data{$key} =~ /(^|\s+)$value(\s+|$)/) {
            $MetaDataObject::_data{$key} .= " $value";
        }
        return;
    }

    #
    # Add validation blocks here. 
    #
    if ($MetaDataObject::_data{$key} && $MetaDataObject::_data{$key} ne $value) { #collision
#
# This statement is fairly expensive so I'm commented it out.
#

#        carp "MetaDataObject::validate_data: Collision on $key => $value against " . 
#            "\$MetaDataObject::_data. Existing data is '$MetaDataObject::_data{$key}'. Preserving the parent value.\n" 
#            if warnings_on();
        $MetaDataObject::_collisions{$key}++;
#        delete $MetaDataObject::_data{$key};
    }

    unless ($MetaDataObject::_collisions{$key}) {
        $MetaDataObject::_data{$key} = $value;
    }
}

sub parse
{
    my ($self, $namespace) = @_;

    $namespace = "" unless $namespace; # shut strict up.

    assertNotStatic($self);
#    $namespace = $self->prop('name') unless $namespace;
    if ($namespace) {
        $namespace =~ s/_$//;
        $namespace .= '_';
    }

#    if ($self->name_is_required()) {
    if ($self->{name}) {
        $self->validate_data( $self->prop('name') . "_NAME", $self->prop('name') );
        $self->validate_data( $self->prop('name') . "_TYPE", ref($self) );
        $self->validate_data( $self->prop('name') . "_TYPES", join ' ', (ref($self), grep { ! /(Exporter|MetaDataObject)/ } @ISA) );
        $self->validate_data( $self->prop('name') . "_THIS", tag2shell($self->prop('name')) );
    }

    #
    # If the object has an 'alias' field, then prioritize that
    # otherwise the children (if they have 'aliases') will
    # take precedence, which won't be right
    # 
    if ($self->getProperty('aliases')) {
        my $key = 'aliases';
        if ($namespace) {
            $self->validate_data( "$namespace$key", $self->prop($key) );
        } elsif ($self->getRequireName() || $self->prop('name')) {
            $self->validate_data( $self->prop('name') . "_$key", $self->prop($key) );
        } else {
            $self->validate_data( $key, $self->prop($key) );
        }
    }

    #
    # there might be a custom sort order here
    # 
    my @keys = ();
    if ($self->getSortOrder()) {
        my %sorted_keys = ();
        push @keys, split(/[\s+,]/, $self->getSortOrder());
        @sorted_keys{ @keys } = 1;
        for my $k (keys %{$self}) {
            push @keys, $k unless $sorted_keys{$k};
        }
    } else {
        @keys = keys %{$self};
    }
        
        
    
    foreach my $key ( @keys ) {
        next if $suppress{$key};
	$_ = ref( $self->{$key} );
#        print STDERR "MetaDataObject::parse $namespace looking at $key -> " . ref( $self->{$key} ) . "\n";
      SWITCH: {
          /SCALAR/ && do {
              Confess "Parse of SCALAR not implemented";
              last SWITCH;
          };
          /ARRAY/ && do {
#              Confess "Parse of ARRAY not implemented";
              for my $obj ( @{ $self->{$key} } ) {
                  if ($namespace && ($obj->getRequireName() || $obj->prop('name'))) {
                      $self->validate_data( "$namespace$key", $obj->prop('name'), 1);
                  } else {
                      if ($self->getRequireName() || $self->prop('name')) {
			  unless ($obj) {
			      print Dumper($self);
			      Confess "a null reference exists in the above object ($key)" unless $obj;
			  }
			  eval {
			      $self->validate_data( $self->prop('name') . "_$key", $obj->prop('name'), 1);
			  };
			  Confess "$@" if $@;
                      } elsif ($obj->getRequireName || $obj->prop('name')) {
			  eval {
			      $self->validate_data( $self->prop('name') . "_$key", $obj->prop('name'), 1);
			  };
			  Confess "$@" if $@;
                      }
                  }
                  $self->_recurse_object( $obj, $namespace );
              }
              last SWITCH;
          };
          /HASH/ && do {
              if (! scalar keys %{ $self->{$key} } ) { # ignore null hash
                  last SWITCH;
              }                  
              Confess "Parse of HASH not implemented";
              last SWITCH;
          };
          /CODE/ && do {
              Confess "Parse of CODE not implemented";
              last SWITCH;
          };
          /REF/ && do {
              Confess "Parse of REF not implemented";
              last SWITCH;
          };
          /GLOB/ && do {
              Confess "Parse of GLOB not implemented";
              last SWITCH;
          };
          /LVALUE/ && do {
              Confess "Parse of LVALUE not implemented";
              last SWITCH;
          };
          
          # An object
          /\w+/ && do {
	      no warnings; # shut off warnings if $namespace is not defined.
              my $object = $self->{$key};
              if ($namespace && ($object->getRequireName() || $object->prop('name'))) {
                   $self->validate_data( "$namespace$key", $object->prop('name') );
               }
              if ($self->getRequireName() || $self->prop('name')) {
                  $self->validate_data( $self->prop('name') . "_$key", $object->prop('name') );
              }
    
              $self->_recurse_object( $self->{$key}, $namespace );
              last SWITCH;
          };

          # default
          if ($namespace) {
              $self->validate_data( "$namespace$key", $self->prop($key) );
          } elsif ($self->getRequireName() || $self->prop('name')) {
              $self->validate_data( $self->prop('name') . "_$key", $self->prop($key) );
          } else {
              $self->validate_data( $key, $self->prop($key) );
          }

          # Parse Characterizations
          if ($self->characteristicSet('InsertIntoGlobal')) {
              $self->validate_data( $key, $self->prop($key) );
          }

      }
    }

    if ($self->getProperty('aliases') && ! $MetaDataObject::_ALIAS_RECURSION) {
        $MetaDataObject::_ALIAS_RECURSION = 1;
        for my $alias ( split(/\s+/, $self->getProperty("aliases")) ) {
#            print "# alias: $alias\n";
            $self->parse($alias);
            $self->validate_data($alias . "_isalias","true");
        }
        $MetaDataObject::_ALIAS_RECURSION = 0;
    }
}

sub _recurse_object {
    my ( $self, $object, $namespace ) = @_;
    no warnings;
#    print "# recursing on namespace ($namespace) - $_\n";
    my $key;
    
    $key = $namespace . $object->prop('name');
    unless ( $recused_namespaces{ $key } ) {
        $object->parse( $namespace ) ;
        $recused_namespaces{ $key }++;
    }

    $key = $self->prop('name') . $object->prop('name');
    unless ( $recused_namespaces{ $key } ) {
        $object->parse( $self->prop('name') );
        $recused_namespaces{ $key }++;
    }

    # special case - nested objects - neither define 'name'
    if ( ! $self->getRequireName() && ! $object->getRequireName()) {
        $object->parse();
    }
}

#
# Allow a "default" value to be set for an object.
#

sub SetDefaults {
    my ($class,$prop,$default) = @_;
    
    $defaults{$class}{$prop} = $default;
}

sub _DefaultAssigner {
    my ($ref,$prop,$value) = @_;
    return $value if exists $ref->{$prop};
    foreach my $class (@{_isa(ref($ref))}) {
	return $defaults{$class}{$prop} if exists $defaults{$class}{$prop};
    }
}

sub DefaultAssigner {
    my $ref = shift;
    foreach my $prop (@_) {
	my $tmp = _DefaultAssigner($ref,$prop,$ref->prop($prop));
	$ref->prop($prop,$tmp) if $tmp;
#	print ref($ref) . ": Called DefaultAssigner on $key ($tmp)\n";
    }
}


=pod

=over 4

=item getMapper

=back

=cut

sub getMapperForEventDispatch {
    my $this = shift;

    my %args = @_;

    my $Subscriber = $args{Subscriber};
    my $Provider = $args{Provider};
    my $Interface = $args{Interface};
    my $Event = $args{Event};
    my $mapperBase = $args{mapperBase};
    my $ret = "";

    $this->debugPrint(0, "fetching mapper for object of type " . ref($this));

#
# So the logic is a little weird .... but it works out like this.  The default order is
# hosttag first, aliases second, name last.  The mapperBase just bumps that up.
#

    if ($mapperBase =~ /name/) {
	$ret = $this->{name} if $this->{name};
    }
    
    if ($mapperBase =~ /alias/) {
	unless ($ret)  {
            if ($this->{aliases}) {
                # MDO hardcode - if the alias ends in an '_', then it is deleted.
                my $alias = $this->{aliases};
                $alias =~ s/_$//;
                $ret = $alias;
            }
	}
    }

    if ($mapperBase =~ /__NOMAPPER__/) {                                        # MAGIC - setting this in the XML dispatch file has
	return ;                                                                # the default behaviour of suppressing a mapper for this event
    }                                                                           # dispatch.
    eval {
	unless ($ret) {
	    $ret = $this->{host}->{hosttag} if $this->{host};
	    unless ($ret)  {
		if ($this->{aliases}) {
		    # MDO hardcode - if the alias ends in an '_', then it is deleted.
		    my $alias = $this->{aliases};
		    $alias =~ s/_$//;
		    $ret = $alias;
		}
	    }
	    unless ($ret) {
		$ret = $this->{name} if $this->{name};
	    }
	}
    };
    Confess "$@" if $@;
    return $ret;
}


#
# This makes MDO's usable from YAML definitions
# Par Example:
#
#  use Data::Dumper;
#  use YAML::Active qw(Load);
#  my ($xhost) = Load(<<'...');
#  --- !perl/host
#  name: 123
#  os: windows
#  ...
#  print Dumper($xhost);
#

sub yaml_activate {
    my ($r_obj) = @_;
    my $obj = undef;
    my $class = ref($r_obj);
    my $code = "\$obj = new $class(\%\$r_obj)";
    eval $code;
    if ($@) {
        Confess "failed to activate yaml defined objects! $@";
    }
    return $obj;
}

1;
