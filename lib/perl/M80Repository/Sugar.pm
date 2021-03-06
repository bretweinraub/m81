


=pod

=head1 NAME - M80Repository::Sugar

M80 build macros around Sugar CRM

=head1 EXAMPLE


    my $Sugar = $Sugar->new();   # stub example .... expand


=cut

# This file was automatically generated from Sugar.pm.m80 by 
# bweinraub on li264-192 (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux)
# DO NOT EDIT THIS FILE 


package M80Repository::Sugar;

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


use base qw(M80Repository::M80RepositoryObject);

=pod

=head1 INHERITANCE

M80Repository::Sugar extends class M80Repository::M80RepositoryObject ; refer to the documentation for that object for member variables and methods.

=cut

use fields qw( debug );

=pod

=head1 CONSTRUCTOR

=over 4

=item M80Repository::Sugar->new()

initializes on object of type M80Repository::Sugar

=back

=cut


# %_allSetters - an array of all setters for all members of the class
my %_allSetters = ();

my %_allMemberAttributes = ();

BEGIN {
# $_allMembers{_TYPE} = 1; # - WHAT IS THIS FOR?
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
    my M80Repository::Sugar $this = shift;

    print STDERR "in M80Repository::Sugar::new(" . join (",", @_) . ")\n" if $ENV{DEBUG};
    Confess "Missing the value for an argument (even nulls) on creation of M80Repository::Sugar" if scalar @_ % 2 != 0;

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
            Confess "Field named \"$key\" is not defined in object M80Repository::Sugar. typo ?\n";
        }
    }



    #### __new is the magic "pre-constructor".  You can intercept a call to the parent
    #### constructor by defining a __new() procedure in your class.

    eval {M80Repository::Sugar::__new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?M80Repository::Sugar::__new/;

    #### Now call the parent constructor, if any.

    eval {$this->SUPER::new(%args)};

    croak $@ if $@
	and $@ !~ /^Can\'t locate object method/;

    ####
    #### Typically this following contains your "real" constructor"
    #### so if you are debugging this next call my be a good candidate to step into.
    ####

    eval {M80Repository::Sugar::_new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?M80Repository::Sugar::_new/;

    $this;
}

###  END GENERATED CODE

=pod

=head1 MEMBERS AND MEMBER ACCESS METHODS

=cut



=pod

=head2 debug => "any string"

debug allows an object to specify its debugPrint level

=cut

sub getDebug {

=pod

=head3 $Sugar->getDebug ()


getter for member debug

=cut

    my $this = shift;





    return $this->{debug};
}
sub setDebug {

=pod

=head3 $Sugar->setDebug (debug => "any string")

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

This file was automatically generated from Sugar.pm.m80 by 
bweinraub on li264-192 (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux)


=head1 OBJECT METHODS

=cut



    use Exporter;


no strict ;
@ISA = qw(Exporter);
@EXPORT = qw(SugarDeployment);
use strict ;


sub _new {

=pod

=head3 $Sugar->_new ()


callback constructor, do not call directly use new() instead

=cut

    my $this = shift;

    Confess "M80Repository::Sugar->_new requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;



}


################################################################################

sub SugarDeployment {
   
=pod

=head3 $Sugar->SugarDeployment (name => "any string"*, host => "any string"*, user => "any string"*, deploy_path => "any string"*, dev_path => "any string"*, apache_path => "any string"*)

 - name ("any string")		 : object_name
 - host ("any string")		 : host name of server
 - user ("any string")		 : user name on server
 - deploy_path ("any string")		 : deploy_path to installation
 - dev_path ("any string")		 : devpath to src
 - apache_path ("any string")		 : devpath to src

Generate the m80 repository entry for a sugar repository

=cut

    Confess "M80Repository::Sugar::SugarDeployment requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $name = $args{name};
    Confess "argument 'name' is required for M80Repository::Sugar::SugarDeployment()" unless defined $name;
    my $host = $args{host};
    Confess "argument 'host' is required for M80Repository::Sugar::SugarDeployment()" unless defined $host;
    my $user = $args{user};
    Confess "argument 'user' is required for M80Repository::Sugar::SugarDeployment()" unless defined $user;
    my $deploy_path = $args{deploy_path};
    Confess "argument 'deploy_path' is required for M80Repository::Sugar::SugarDeployment()" unless defined $deploy_path;
    my $dev_path = $args{dev_path};
    Confess "argument 'dev_path' is required for M80Repository::Sugar::SugarDeployment()" unless defined $dev_path;
    my $apache_path = $args{apache_path};
    Confess "argument 'apache_path' is required for M80Repository::Sugar::SugarDeployment()" unless defined $apache_path;



    do {
	my $ret = "append_variable_space([SugarDeployments],[$name])\n";
	$ret .= "define_variable([" . $name . "_host],[$host])\n";
	$ret .= "define_variable([" . $name . "_user],[$user])\n";
	$ret .= "define_variable([" . $name . "_deploy_path],[$deploy_path])\n";
	$ret .= "define_variable([" . $name . "_dev_path],[$dev_path])\n";
	$ret .= "define_variable([" . $name . "_apache_path],[$apache_path])\n";
	$ret .= "define_variable([" . $name . "_THIS],[$name])\n";
#	$ret .= "m80NewCustomModule([$name],((deploy,$dev_path,make),(build,$dev_path,make)))\n";
	$ret;
    };
}


	    

