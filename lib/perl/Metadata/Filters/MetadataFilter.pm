


=pod

=head1 NAME - MetadataFilter

Base class for all Metadata Filters.

=head1 EXAMPLE


    my $MetadataFilter = $MetadataFilter->new();   # stub example .... expand


=cut

# This file was automatically generated from MetadataFilter.pm.m80 by 
# bret on ubuntu (Linux ubuntu 2.6.31-19-generic-pae #56-Ubuntu SMP Thu Jan 28 02:29:51 UTC 2010 i686 GNU/Linux)
# DO NOT EDIT THIS FILE 


package MetadataFilter;

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


use base qw(ProceduralPropertyGroup);

=pod

=head1 INHERITANCE

MetadataFilter extends class ProceduralPropertyGroup ; refer to the documentation for that object for member variables and methods.

=cut

use fields qw( description name debug );

=pod

=head1 CONSTRUCTOR

=over 4

=item MetadataFilter->new()

initializes on object of type MetadataFilter

=back

=cut


# %_allSetters - an array of all setters for all members of the class
my %_allSetters = ();

my %_allMemberAttributes = ();

BEGIN {
# $_allMembers{_TYPE} = 1; # - WHAT IS THIS FOR?
$_allMemberAttributes{description} = {
          'name' => 'description',
          'type' => 'string',
          'description' => 'Description of this MetadataFilter ... should hopefully be somewhat informative'
        }
;
$_allSetters{description} = \&setDescription;
$_allMemberAttributes{name} = {
          'name' => 'name',
          'type' => 'string',
          'description' => 'Name of this Property Group'
        }
;
$_allSetters{name} = \&setName;
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
    my MetadataFilter $this = shift;

    print STDERR "in MetadataFilter::new(" . join (",", @_) . ")\n" if $ENV{DEBUG};
    Confess "Missing the value for an argument (even nulls) on creation of MetadataFilter" if scalar @_ % 2 != 0;

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
            Confess "Field named \"$key\" is not defined in object MetadataFilter. typo ?\n";
        }
    }



    #### __new is the magic "pre-constructor".  You can intercept a call to the parent
    #### constructor by defining a __new() procedure in your class.

    eval {MetadataFilter::__new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?MetadataFilter::__new/;

    #### Now call the parent constructor, if any.

    eval {$this->SUPER::new(%args)};

    croak $@ if $@
	and $@ !~ /^Can\'t locate object method/;

    ####
    #### Typically this following contains your "real" constructor"
    #### so if you are debugging this next call my be a good candidate to step into.
    ####

    eval {MetadataFilter::_new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?MetadataFilter::_new/;

    $this;
}

###  END GENERATED CODE

=pod

=head1 MEMBERS AND MEMBER ACCESS METHODS

=cut



=pod

=head2 description => "any string"

Description of this MetadataFilter ... should hopefully be somewhat informative

=cut

sub getDescription {

=pod

=head3 $MetadataFilter->getDescription ()


getter for member description

=cut

    my $this = shift;





    return $this->{description};
}
sub setDescription {

=pod

=head3 $MetadataFilter->setDescription (description => "any string")

 - description ("any string")		 : Description of this MetadataFilter ... should hopefully be somewhat informative

setter for member description

=cut

    my $this = shift;


    my $description = shift;



    $this->{description} = $description;
    return $description;
}



=pod

=head2 name => "any string"

Name of this Property Group

=cut

sub getName {

=pod

=head3 $MetadataFilter->getName ()


getter for member name

=cut

    my $this = shift;





    return $this->{name};
}
sub setName {

=pod

=head3 $MetadataFilter->setName (name => "any string")

 - name ("any string")		 : Name of this Property Group

setter for member name

=cut

    my $this = shift;


    my $name = shift;



    $this->{name} = $name;
    return $name;
}



=pod

=head2 debug => "any string"

debug allows an object to specify its debugPrint level

=cut

sub getDebug {

=pod

=head3 $MetadataFilter->getDebug ()


getter for member debug

=cut

    my $this = shift;





    return $this->{debug};
}
sub setDebug {

=pod

=head3 $MetadataFilter->setDebug (debug => "any string")

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

This file was automatically generated from MetadataFilter.pm.m80 by 
bret on ubuntu (Linux ubuntu 2.6.31-19-generic-pae #56-Ubuntu SMP Thu Jan 28 02:29:51 UTC 2010 i686 GNU/Linux)


=head1 OBJECT METHODS

=cut



sub _new {

=pod

=head3 $MetadataFilter->_new ()


callback constructor, do not call directly use new() instead

=cut

    my $this = shift;

    Confess "MetadataFilter->_new requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;




}

sub buildPath {
# remove the spaces from the tag below
    
=pod

=head3 $MetadataFilter->buildPath (object => MetaDataObject*, root => "any string"*, tag => "any string"*, value => "any string"*, osflavor => "any string")

 - object (MetaDataObject)		 : The object to be modified
 - root ("any string")		 : The root of the path to be updated
 - tag ("any string")		 : The tag to be set on the object
 - value ("any string")		 : The value to be set for the tag
 - osflavor ("any string")		 : Operating system for the host in question.  If the machine is not a windows machine, we do not have to generate windows paths for it

Builds out a filesystem path and updates a metadata object accordingly.  This will manage creating os specific paths.

=cut

    my $this = shift;

    Confess "MetadataFilter->buildPath requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $object = $args{object};
    Confess "argument 'object' is required for MetadataFilter->buildPath()" unless exists $args{object};
    eval {my $dummy = $object->isa("MetaDataObject");};Confess "$@\n" . Dumper($object) if $@;
    if (defined $object) { Confess "argument 'object' of method MetadataFilter->buildPath() is required to be of reference type MetaDataObject, but it looks to be of type " . ref ($object)  unless $object->isa("MetaDataObject");}
    my $root = $args{root};
    Confess "argument 'root' is required for MetadataFilter->buildPath()" unless exists $args{root};
    my $tag = $args{tag};
    Confess "argument 'tag' is required for MetadataFilter->buildPath()" unless exists $args{tag};
    my $value = $args{value};
    Confess "argument 'value' is required for MetadataFilter->buildPath()" unless exists $args{value};
    my $osflavor = $args{osflavor};




   $object->{$tag} = $root . "/" . $value;						       
   $object->{$tag . "_unix"} = $root . "/" . $value;						       
    $object->{$tag . "_windows"} = __unix2cygwin($root . "/" . $value) if ($osflavor =~ /win/);
}

sub __unix2cygwin {
    my ($path) = @_;
    $path =~ s/\~/$ENV{HOME}/g;
    $path =~ s!/cygdrive/\w!!;
    return "C:/cygwin$path";
}

	    

