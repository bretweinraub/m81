


=pod

=head1 NAME - M80Repository::DeployableBits

M80Repository::DeployableBits description; stub description please expand

=head1 EXAMPLE


    my $M80Repository::DeployableBits = $M80Repository::DeployableBits->new();   # stub example .... expand


=cut

# This file was automatically generated from DeployableBits.pm.m80 by 
# bweinraub on li264-192 (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux)
# DO NOT EDIT THIS FILE 


package M80Repository::DeployableBits;

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

use Utils::PerlTools;

use base qw(M80Repository::Base);

=pod

=head1 INHERITANCE

M80Repository::DeployableBits extends class M80Repository::Base ; refer to the documentation for that object for member variables and methods.

=cut

use fields qw( name srcPath srcHost srcUser destPath destHost destUser destGroup preDepCmd postDepCmd mosDescriptor debug );

=pod

=head1 CONSTRUCTOR

=over 4

=item M80Repository::DeployableBits->new()

initializes on object of type M80Repository::DeployableBits

=back

=cut


# %_allSetters - an array of all setters for all members of the class
my %_allSetters = ();

my %_allMemberAttributes = ();

BEGIN {
# $_allMembers{_TYPE} = 1; # - WHAT IS THIS FOR?
$_allMemberAttributes{name} = {
          'required' => 1,
          'name' => 'name',
          'description' => 'Name of the deployable bits module'
        }
;
$_allSetters{name} = \&setName;
$_allMemberAttributes{srcPath} = {
          'required' => 1,
          'name' => 'srcPath',
          'description' => 'Path to the source bits'
        }
;
$_allSetters{srcPath} = \&setSrcPath;
$_allMemberAttributes{srcHost} = {
          'name' => 'srcHost',
          'description' => 'Host for the source bits ; if not set will default localhost'
        }
;
$_allSetters{srcHost} = \&setSrcHost;
$_allMemberAttributes{srcUser} = {
          'name' => 'srcUser',
          'description' => 'Username on the srcHost; if not set the current user is assumed '
        }
;
$_allSetters{srcUser} = \&setSrcUser;
$_allMemberAttributes{destPath} = {
          'required' => 1,
          'name' => 'destPath',
          'description' => 'Path to the destination bits'
        }
;
$_allSetters{destPath} = \&setDestPath;
$_allMemberAttributes{destHost} = {
          'name' => 'destHost',
          'description' => 'Host for the destination bits ; if not set will default localhost'
        }
;
$_allSetters{destHost} = \&setDestHost;
$_allMemberAttributes{destUser} = {
          'name' => 'destUser',
          'description' => 'Username on the destHost; if not set the current user is assumed'
        }
;
$_allSetters{destUser} = \&setDestUser;
$_allMemberAttributes{destGroup} = {
          'name' => 'destGroup',
          'description' => 'Groupname on the destHost; if not set no manipulation is performed'
        }
;
$_allSetters{destGroup} = \&setDestGroup;
$_allMemberAttributes{preDepCmd} = {
          'name' => 'preDepCmd',
          'description' => 'Run in the bundle srcDir before deployment ... defaults to "make clean all"'
        }
;
$_allSetters{preDepCmd} = \&setPreDepCmd;
$_allMemberAttributes{postDepCmd} = {
          'name' => 'postDepCmd',
          'description' => 'Run in the bundle destPath after deployment'
        }
;
$_allSetters{postDepCmd} = \&setPostDepCmd;
$_allMemberAttributes{mosDescriptor} = {
          'name' => 'mosDescriptor',
          'description' => 'description of configurable mos commands to generate'
        }
;
$_allSetters{mosDescriptor} = \&setMosDescriptor;
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
    my M80Repository::DeployableBits $this = shift;

    print STDERR "in M80Repository::DeployableBits::new(" . join (",", @_) . ")\n" if $ENV{DEBUG};
    Confess "Missing the value for an argument (even nulls) on creation of M80Repository::DeployableBits" if scalar @_ % 2 != 0;

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
            Confess "Field named \"$key\" is not defined in object M80Repository::DeployableBits. typo ?\n";
        }
    }


    Confess "cannot initialize object of type M80Repository::DeployableBits without required member variable name"
        unless exists $this->{name};

    Confess "cannot initialize object of type M80Repository::DeployableBits without required member variable srcPath"
        unless exists $this->{srcPath};

    Confess "cannot initialize object of type M80Repository::DeployableBits without required member variable destPath"
        unless exists $this->{destPath};


    #### __new is the magic "pre-constructor".  You can intercept a call to the parent
    #### constructor by defining a __new() procedure in your class.

    eval {M80Repository::DeployableBits::__new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?M80Repository::DeployableBits::__new/;

    #### Now call the parent constructor, if any.

    eval {$this->SUPER::new(%args)};

    croak $@ if $@
	and $@ !~ /^Can\'t locate object method/;

    ####
    #### Typically this following contains your "real" constructor"
    #### so if you are debugging this next call my be a good candidate to step into.
    ####

    eval {M80Repository::DeployableBits::_new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?M80Repository::DeployableBits::_new/;

    $this;
}

###  END GENERATED CODE

=pod

=head1 MEMBERS AND MEMBER ACCESS METHODS

=cut



=pod

=head2 name => "any string"*

Name of the deployable bits module

=cut

sub getName {

=pod

=head3 $DeployableBits->getName ()


getter for member name

=cut

    my $this = shift;





    return $this->{name};
}
sub setName {

=pod

=head3 $DeployableBits->setName (name => "any string"*)

 - name ("any string")		 : Name of the deployable bits module

setter for member name

=cut

    my $this = shift;


    my $name = shift;
    Confess "argument 'name' is required for M80Repository::DeployableBits->setName()" unless defined $name;



    $this->{name} = $name;
    return $name;
}



=pod

=head2 srcPath => "any string"*

Path to the source bits

=cut

sub getSrcPath {

=pod

=head3 $DeployableBits->getSrcPath ()


getter for member srcPath

=cut

    my $this = shift;





    return $this->{srcPath};
}
sub setSrcPath {

=pod

=head3 $DeployableBits->setSrcPath (srcPath => "any string"*)

 - srcPath ("any string")		 : Path to the source bits

setter for member srcPath

=cut

    my $this = shift;


    my $srcPath = shift;
    Confess "argument 'srcPath' is required for M80Repository::DeployableBits->setSrcPath()" unless defined $srcPath;



    $this->{srcPath} = $srcPath;
    return $srcPath;
}



=pod

=head2 srcHost => "any string"

Host for the source bits ; if not set will default localhost

=cut

sub getSrcHost {

=pod

=head3 $DeployableBits->getSrcHost ()


getter for member srcHost

=cut

    my $this = shift;





    return $this->{srcHost};
}
sub setSrcHost {

=pod

=head3 $DeployableBits->setSrcHost (srcHost => "any string")

 - srcHost ("any string")		 : Host for the source bits ; if not set will default localhost

setter for member srcHost

=cut

    my $this = shift;


    my $srcHost = shift;



    $this->{srcHost} = $srcHost;
    return $srcHost;
}



=pod

=head2 srcUser => "any string"

Username on the srcHost; if not set the current user is assumed 

=cut

sub getSrcUser {

=pod

=head3 $DeployableBits->getSrcUser ()


getter for member srcUser

=cut

    my $this = shift;





    return $this->{srcUser};
}
sub setSrcUser {

=pod

=head3 $DeployableBits->setSrcUser (srcUser => "any string")

 - srcUser ("any string")		 : Username on the srcHost; if not set the current user is assumed 

setter for member srcUser

=cut

    my $this = shift;


    my $srcUser = shift;



    $this->{srcUser} = $srcUser;
    return $srcUser;
}



=pod

=head2 destPath => "any string"*

Path to the destination bits

=cut

sub getDestPath {

=pod

=head3 $DeployableBits->getDestPath ()


getter for member destPath

=cut

    my $this = shift;





    return $this->{destPath};
}
sub setDestPath {

=pod

=head3 $DeployableBits->setDestPath (destPath => "any string"*)

 - destPath ("any string")		 : Path to the destination bits

setter for member destPath

=cut

    my $this = shift;


    my $destPath = shift;
    Confess "argument 'destPath' is required for M80Repository::DeployableBits->setDestPath()" unless defined $destPath;



    $this->{destPath} = $destPath;
    return $destPath;
}



=pod

=head2 destHost => "any string"

Host for the destination bits ; if not set will default localhost

=cut

sub getDestHost {

=pod

=head3 $DeployableBits->getDestHost ()


getter for member destHost

=cut

    my $this = shift;





    return $this->{destHost};
}
sub setDestHost {

=pod

=head3 $DeployableBits->setDestHost (destHost => "any string")

 - destHost ("any string")		 : Host for the destination bits ; if not set will default localhost

setter for member destHost

=cut

    my $this = shift;


    my $destHost = shift;



    $this->{destHost} = $destHost;
    return $destHost;
}



=pod

=head2 destUser => "any string"

Username on the destHost; if not set the current user is assumed

=cut

sub getDestUser {

=pod

=head3 $DeployableBits->getDestUser ()


getter for member destUser

=cut

    my $this = shift;





    return $this->{destUser};
}
sub setDestUser {

=pod

=head3 $DeployableBits->setDestUser (destUser => "any string")

 - destUser ("any string")		 : Username on the destHost; if not set the current user is assumed

setter for member destUser

=cut

    my $this = shift;


    my $destUser = shift;



    $this->{destUser} = $destUser;
    return $destUser;
}



=pod

=head2 destGroup => "any string"

Groupname on the destHost; if not set no manipulation is performed

=cut

sub getDestGroup {

=pod

=head3 $DeployableBits->getDestGroup ()


getter for member destGroup

=cut

    my $this = shift;





    return $this->{destGroup};
}
sub setDestGroup {

=pod

=head3 $DeployableBits->setDestGroup (destGroup => "any string")

 - destGroup ("any string")		 : Groupname on the destHost; if not set no manipulation is performed

setter for member destGroup

=cut

    my $this = shift;


    my $destGroup = shift;



    $this->{destGroup} = $destGroup;
    return $destGroup;
}



=pod

=head2 preDepCmd => "any string"

Run in the bundle srcDir before deployment ... defaults to "make clean all"

=cut

sub getPreDepCmd {

=pod

=head3 $DeployableBits->getPreDepCmd ()


getter for member preDepCmd

=cut

    my $this = shift;





    return $this->{preDepCmd};
}
sub setPreDepCmd {

=pod

=head3 $DeployableBits->setPreDepCmd (preDepCmd => "any string")

 - preDepCmd ("any string")		 : Run in the bundle srcDir before deployment ... defaults to "make clean all"

setter for member preDepCmd

=cut

    my $this = shift;


    my $preDepCmd = shift;



    $this->{preDepCmd} = $preDepCmd;
    return $preDepCmd;
}



=pod

=head2 postDepCmd => "any string"

Run in the bundle destPath after deployment

=cut

sub getPostDepCmd {

=pod

=head3 $DeployableBits->getPostDepCmd ()


getter for member postDepCmd

=cut

    my $this = shift;





    return $this->{postDepCmd};
}
sub setPostDepCmd {

=pod

=head3 $DeployableBits->setPostDepCmd (postDepCmd => "any string")

 - postDepCmd ("any string")		 : Run in the bundle destPath after deployment

setter for member postDepCmd

=cut

    my $this = shift;


    my $postDepCmd = shift;



    $this->{postDepCmd} = $postDepCmd;
    return $postDepCmd;
}



=pod

=head2 mosDescriptor => "any string"

description of configurable mos commands to generate

=cut

sub getMosDescriptor {

=pod

=head3 $DeployableBits->getMosDescriptor ()


getter for member mosDescriptor

=cut

    my $this = shift;





    return $this->{mosDescriptor};
}
sub setMosDescriptor {

=pod

=head3 $DeployableBits->setMosDescriptor (mosDescriptor => "any string")

 - mosDescriptor ("any string")		 : description of configurable mos commands to generate

setter for member mosDescriptor

=cut

    my $this = shift;


    my $mosDescriptor = shift;



    $this->{mosDescriptor} = $mosDescriptor;
    return $mosDescriptor;
}



=pod

=head2 debug => "any string"

debug allows an object to specify its debugPrint level

=cut

sub getDebug {

=pod

=head3 $DeployableBits->getDebug ()


getter for member debug

=cut

    my $this = shift;





    return $this->{debug};
}
sub setDebug {

=pod

=head3 $DeployableBits->setDebug (debug => "any string")

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

This file was automatically generated from DeployableBits.pm.m80 by 
bweinraub on li264-192 (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux)


=head1 OBJECT METHODS

=cut



sub _new {

=pod

=head3 $DeployableBits->_new ()


callback constructor, do not call directly use new() instead

=cut

    my $this = shift;

    Confess "M80Repository::DeployableBits->_new requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;



}


################################################################################

sub dump {
   
=pod

=head3 $DeployableBits->dump ()


dump the output for the m80 repository

=cut

    my $this = shift;

    Confess "M80Repository::DeployableBits->dump requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;



    do {
	$this->SUPER::dump(@_) . "m80NewCustomModule([" . $this->getName() . "],((deploy," . $this->getSrcPath() . ",deploy.sh)))\n";
    };
}



