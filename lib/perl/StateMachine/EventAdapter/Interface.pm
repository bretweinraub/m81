


=pod

=head1 NAME - StateMachine::EventAdapter::Interface

A State Machine Interface Module

=head1 EXAMPLE


    my $Interface = $Interface->new();   # stub example .... expand


=cut

# This file was automatically generated from Interface.pm.m80 by 
# bret on ubuntu (Linux ubuntu 2.6.31-19-generic-pae #56-Ubuntu SMP Thu Jan 28 02:29:51 UTC 2010 i686 GNU/Linux)
# DO NOT EDIT THIS FILE 


package StateMachine::EventAdapter::Interface;

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

use StateMachine::EventAdapter::Provider;
use StateMachine::EventAdapter::Event;
use fields qw( xmlhash providers events debug );

=pod

=head1 CONSTRUCTOR

=over 4

=item StateMachine::EventAdapter::Interface->new()

initializes on object of type StateMachine::EventAdapter::Interface

=back

=cut


# %_allSetters - an array of all setters for all members of the class
my %_allSetters = ();

my %_allMemberAttributes = ();

BEGIN {
# $_allMembers{_TYPE} = 1; # - WHAT IS THIS FOR?
$_allMemberAttributes{xmlhash} = {
          'required' => 1,
          'ref' => 'HASH',
          'name' => 'xmlhash',
          'description' => 'The parsed interface block from the XML config file.'
        }
;
$_allSetters{xmlhash} = \&setXmlhash;
$_allMemberAttributes{providers} = {
          'ref' => 'HASH',
          'name' => 'providers',
          'description' => 'Table of Provider objects keyed by module name'
        }
;
$_allSetters{providers} = \&setProviders;
$_allMemberAttributes{events} = {
          'ref' => 'HASH',
          'name' => 'events',
          'description' => 'hash table of all StateMachine::EventAdapter::Event objects for this interface'
        }
;
$_allSetters{events} = \&setEvents;
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
    my StateMachine::EventAdapter::Interface $this = shift;

    print STDERR "in StateMachine::EventAdapter::Interface::new(" . join (",", @_) . ")\n" if $ENV{DEBUG};
    Confess "Missing the value for an argument (even nulls) on creation of StateMachine::EventAdapter::Interface" if scalar @_ % 2 != 0;

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
            Confess "Field named \"$key\" is not defined in object StateMachine::EventAdapter::Interface. typo ?\n";
        }
    }


    Confess "cannot initialize object of type StateMachine::EventAdapter::Interface without required member variable xmlhash"
        unless exists $this->{xmlhash};


    #### __new is the magic "pre-constructor".  You can intercept a call to the parent
    #### constructor by defining a __new() procedure in your class.

    eval {StateMachine::EventAdapter::Interface::__new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?StateMachine::EventAdapter::Interface::__new/;

    #### Now call the parent constructor, if any.

    eval {$this->SUPER::new(%args)};

    croak $@ if $@
	and $@ !~ /^Can\'t locate object method/;

    ####
    #### Typically this following contains your "real" constructor"
    #### so if you are debugging this next call my be a good candidate to step into.
    ####

    eval {StateMachine::EventAdapter::Interface::_new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?StateMachine::EventAdapter::Interface::_new/;

    $this;
}

###  END GENERATED CODE

=pod

=head1 MEMBERS AND MEMBER ACCESS METHODS

=cut



=pod

=head2 xmlhash => HASH*

The parsed interface block from the XML config file.

=cut

sub getXmlhash {

=pod

=head3 $EventAdapter::Interface->getXmlhash ()


getter for member xmlhash

=cut

    my $this = shift;





    return $this->{xmlhash};
}
sub setXmlhash {

=pod

=head3 $EventAdapter::Interface->setXmlhash (xmlhash => HASH*)

 - xmlhash (HASH)		 : The parsed interface block from the XML config file.

setter for member xmlhash

=cut

    my $this = shift;


    my $xmlhash = shift;
    Confess "argument 'xmlhash' is required for StateMachine::EventAdapter::Interface->setXmlhash()" unless defined $xmlhash;
        if (defined $xmlhash) { Confess "argument 'xmlhash' of method StateMachine::EventAdapter::Interface->setXmlhash() is required to be of reference type HASH " unless ref($xmlhash) =~ /^HASH/;}



    $this->{xmlhash} = $xmlhash;
    return $xmlhash;
}



=pod

=head2 providers => HASH

Table of Provider objects keyed by module name

=cut

sub getProviders {

=pod

=head3 $EventAdapter::Interface->getProviders ()


getter for member providers

=cut

    my $this = shift;





    return $this->{providers};
}
sub setProviders {

=pod

=head3 $EventAdapter::Interface->setProviders (providers => HASH)

 - providers (HASH)		 : Table of Provider objects keyed by module name

setter for member providers

=cut

    my $this = shift;


    my $providers = shift;
        if (defined $providers) { Confess "argument 'providers' of method StateMachine::EventAdapter::Interface->setProviders() is required to be of reference type HASH " unless ref($providers) =~ /^HASH/;}



    $this->{providers} = $providers;
    return $providers;
}



=pod

=head2 events => HASH

hash table of all StateMachine::EventAdapter::Event objects for this interface

=cut

sub getEvents {

=pod

=head3 $EventAdapter::Interface->getEvents ()


getter for member events

=cut

    my $this = shift;





    return $this->{events};
}
sub setEvents {

=pod

=head3 $EventAdapter::Interface->setEvents (events => HASH)

 - events (HASH)		 : hash table of all StateMachine::EventAdapter::Event objects for this interface

setter for member events

=cut

    my $this = shift;


    my $events = shift;
        if (defined $events) { Confess "argument 'events' of method StateMachine::EventAdapter::Interface->setEvents() is required to be of reference type HASH " unless ref($events) =~ /^HASH/;}



    $this->{events} = $events;
    return $events;
}



=pod

=head2 debug => "any string"

debug allows an object to specify its debugPrint level

=cut

sub getDebug {

=pod

=head3 $EventAdapter::Interface->getDebug ()


getter for member debug

=cut

    my $this = shift;





    return $this->{debug};
}
sub setDebug {

=pod

=head3 $EventAdapter::Interface->setDebug (debug => "any string")

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

This file was automatically generated from Interface.pm.m80 by 
bret on ubuntu (Linux ubuntu 2.6.31-19-generic-pae #56-Ubuntu SMP Thu Jan 28 02:29:51 UTC 2010 i686 GNU/Linux)


=head1 OBJECT METHODS

=cut



sub _new {

=pod

=head3 $EventAdapter::Interface->_new ()


callback constructor, do not call directly use new() instead

=cut

    my $this = shift;

    Confess "StateMachine::EventAdapter::Interface->_new requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;




    my $xml = $this->getXmlhash();

    my @providers = @{$xml->{providers}[0]->{provider}};

    my $providersHash = {};

    foreach my $provider (@providers) {
	my $Provider = StateMachine::EventAdapter::Provider->new(xmlhash => $provider);
	$providersHash->{$provider->{module}} = $Provider;
    }

    $this->setProviders($providersHash);


    my $eventHash = {};

    my @events = @{$xml->{events}[0]->{event}};

    foreach my $event (@events) {
        my $Event = StateMachine::EventAdapter::Event->new (xmlhash => $event,
							    name => $event->{name},
							    mapperBase => $event->{mapperBase});
	$eventHash->{$event->{name}} = $Event;
    }

    $this->setEvents($eventHash);
}

sub getEventByName {
    
=pod

=head3 $EventAdapter::Interface->getEventByName (event => "any string"*)

 - event ("any string")		 : the name of the event to fetch

the event to fetch by name

=cut

    my $this = shift;

    Confess "StateMachine::EventAdapter::Interface->getEventByName requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $event = $args{event};
    Confess "argument 'event' is required for StateMachine::EventAdapter::Interface->getEventByName()" unless exists $args{event};




    printmsg "looking for event $event";

    my $ret = $this->getEvents()->{$event};

    $this->debugPrint (1, "cannot find event $event in XMLFile->getEventByName()") unless 
        defined $ret;
    
    return $ret;

}