


=pod

=head1 NAME - M80Repository::SQLServer

SQLServer description; stub description please expand

=head1 EXAMPLE


    my $SQLServer = $SQLServer->new();   # stub example .... expand


# or in a m80 repository file
use M80Repository::SQLServer;
M80Repository::SQLServer->new(name => "MetadataObjectName",
			      interface => "Interface", # see $SYBASE/etc/freetds.conf
			      user => "scott",
			      password => "tiger")->dump;


=cut

# This file was automatically generated from SQLServer.pm.m80 by 
# bweinraub on li264-192 (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux)
# DO NOT EDIT THIS FILE 


package M80Repository::SQLServer;

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


use base qw(M80Repository::Base);

=pod

=head1 INHERITANCE

M80Repository::SQLServer extends class M80Repository::Base ; refer to the documentation for that object for member variables and methods.

=cut

use fields qw( name interface user password database debug );

=pod

=head1 CONSTRUCTOR

=over 4

=item M80Repository::SQLServer->new()

initializes on object of type M80Repository::SQLServer

=back

=cut


# %_allSetters - an array of all setters for all members of the class
my %_allSetters = ();

my %_allMemberAttributes = ();

BEGIN {
# $_allMembers{_TYPE} = 1; # - WHAT IS THIS FOR?
$_allMemberAttributes{name} = {
          'name' => 'name',
          'description' => 'stub description of name'
        }
;
$_allSetters{name} = \&setName;
$_allMemberAttributes{interface} = {
          'name' => 'interface',
          'description' => 'stub description of interface'
        }
;
$_allSetters{interface} = \&setInterface;
$_allMemberAttributes{user} = {
          'name' => 'user',
          'description' => 'stub description of user'
        }
;
$_allSetters{user} = \&setUser;
$_allMemberAttributes{password} = {
          'name' => 'password',
          'description' => 'stub description of password'
        }
;
$_allSetters{password} = \&setPassword;
$_allMemberAttributes{database} = {
          'name' => 'database',
          'description' => 'SQL server database to connect to'
        }
;
$_allSetters{database} = \&setDatabase;
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
    my M80Repository::SQLServer $this = shift;

    print STDERR "in M80Repository::SQLServer::new(" . join (",", @_) . ")\n" if $ENV{DEBUG};
    Confess "Missing the value for an argument (even nulls) on creation of M80Repository::SQLServer" if scalar @_ % 2 != 0;

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
            Confess "Field named \"$key\" is not defined in object M80Repository::SQLServer. typo ?\n";
        }
    }



    #### __new is the magic "pre-constructor".  You can intercept a call to the parent
    #### constructor by defining a __new() procedure in your class.

    eval {M80Repository::SQLServer::__new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?M80Repository::SQLServer::__new/;

    #### Now call the parent constructor, if any.

    eval {$this->SUPER::new(%args)};

    croak $@ if $@
	and $@ !~ /^Can\'t locate object method/;

    ####
    #### Typically this following contains your "real" constructor"
    #### so if you are debugging this next call my be a good candidate to step into.
    ####

    eval {M80Repository::SQLServer::_new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?M80Repository::SQLServer::_new/;

    $this;
}

###  END GENERATED CODE

=pod

=head1 MEMBERS AND MEMBER ACCESS METHODS

=cut



=pod

=head2 name => "any string"

stub description of name

=cut

sub getName {

=pod

=head3 $SQLServer->getName ()


getter for member name

=cut

    my $this = shift;





    return $this->{name};
}
sub setName {

=pod

=head3 $SQLServer->setName (name => "any string")

 - name ("any string")		 : stub description of name

setter for member name

=cut

    my $this = shift;


    my $name = shift;



    $this->{name} = $name;
    return $name;
}



=pod

=head2 interface => "any string"

stub description of interface

=cut

sub getInterface {

=pod

=head3 $SQLServer->getInterface ()


getter for member interface

=cut

    my $this = shift;





    return $this->{interface};
}
sub setInterface {

=pod

=head3 $SQLServer->setInterface (interface => "any string")

 - interface ("any string")		 : stub description of interface

setter for member interface

=cut

    my $this = shift;


    my $interface = shift;



    $this->{interface} = $interface;
    return $interface;
}



=pod

=head2 user => "any string"

stub description of user

=cut

sub getUser {

=pod

=head3 $SQLServer->getUser ()


getter for member user

=cut

    my $this = shift;





    return $this->{user};
}
sub setUser {

=pod

=head3 $SQLServer->setUser (user => "any string")

 - user ("any string")		 : stub description of user

setter for member user

=cut

    my $this = shift;


    my $user = shift;



    $this->{user} = $user;
    return $user;
}



=pod

=head2 password => "any string"

stub description of password

=cut

sub getPassword {

=pod

=head3 $SQLServer->getPassword ()


getter for member password

=cut

    my $this = shift;





    return $this->{password};
}
sub setPassword {

=pod

=head3 $SQLServer->setPassword (password => "any string")

 - password ("any string")		 : stub description of password

setter for member password

=cut

    my $this = shift;


    my $password = shift;



    $this->{password} = $password;
    return $password;
}



=pod

=head2 database => "any string"

SQL server database to connect to

=cut

sub getDatabase {

=pod

=head3 $SQLServer->getDatabase ()


getter for member database

=cut

    my $this = shift;





    return $this->{database};
}
sub setDatabase {

=pod

=head3 $SQLServer->setDatabase (database => "any string")

 - database ("any string")		 : SQL server database to connect to

setter for member database

=cut

    my $this = shift;


    my $database = shift;



    $this->{database} = $database;
    return $database;
}



=pod

=head2 debug => "any string"

debug allows an object to specify its debugPrint level

=cut

sub getDebug {

=pod

=head3 $SQLServer->getDebug ()


getter for member debug

=cut

    my $this = shift;





    return $this->{debug};
}
sub setDebug {

=pod

=head3 $SQLServer->setDebug (debug => "any string")

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

This file was automatically generated from SQLServer.pm.m80 by 
bweinraub on li264-192 (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux)


=head1 OBJECT METHODS

=cut



sub _new {

=pod

=head3 $SQLServer->_new ()


callback constructor, do not call directly use new() instead

=cut

    my $this = shift;

    Confess "M80Repository::SQLServer->_new requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;



}


################################################################################

sub dump {
   
=pod

=head3 $SQLServer->dump ()


dump the output for the m80 repository

=cut

    my $this = shift;

    Confess "M80Repository::SQLServer->dump requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;



    do {
	my $ret = $this->SUPER::dump(@_) ; 

	$ret .= "\ndefine_variable([" . $this->getName . "_type],[sqlserver])\n";
	$ret;
# "m80NewCustomModule([" . $this->getName() . "],((deploy," . $this->getSrcPath() . ",deploy.sh)))\n";
    };
}
