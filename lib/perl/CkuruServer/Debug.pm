


=pod

=head1 NAME - CkuruServer::Debug

CkuruServer::Debug description; stub description please expand

=head1 EXAMPLE


    my $CkuruServer::Debug = $CkuruServer::Debug->new();   # stub example .... expand


=cut

# This file was automatically generated from Debug.pm.m80 by 
# bret on ubuntu (Linux ubuntu 2.6.31-19-generic-pae #56-Ubuntu SMP Thu Jan 28 02:29:51 UTC 2010 i686 GNU/Linux)
# DO NOT EDIT THIS FILE 


package CkuruServer::Debug;

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

use FileHandle;

use base qw(CkuruServer::Base);

=pod

=head1 INHERITANCE

CkuruServer::Debug extends class CkuruServer::Base ; refer to the documentation for that object for member variables and methods.

=cut

use fields qw( echo logDir logName logFH level prefix debug );

=pod

=head1 CONSTRUCTOR

=over 4

=item CkuruServer::Debug->new()

initializes on object of type CkuruServer::Debug

=back

=cut


# %_allSetters - an array of all setters for all members of the class
my %_allSetters = ();

my %_allMemberAttributes = ();

BEGIN {
# $_allMembers{_TYPE} = 1; # - WHAT IS THIS FOR?
$_allMemberAttributes{echo} = {
          'name' => 'echo',
          'description' => 'when writing to a file, setting  this  variable also causes the debug message to go to stdout'
        }
;
$_allSetters{echo} = \&setEcho;
$_allMemberAttributes{logDir} = {
          'name' => 'logDir',
          'default' => '.',
          'description' => 'Directory to hold the CKURUSERVER log'
        }
;
$_allSetters{logDir} = \&setLogDir;
$_allMemberAttributes{logName} = {
          'required' => 1,
          'name' => 'logName',
          'description' => 'Log name'
        }
;
$_allSetters{logName} = \&setLogName;
$_allMemberAttributes{logFH} = {
          'ref' => 'FileHandle',
          'name' => 'logFH',
          'description' => 'Filehandle of the log file'
        }
;
$_allSetters{logFH} = \&setLogFH;
$_allMemberAttributes{level} = {
          'required' => 1,
          'name' => 'level',
          'description' => 'Assigned log level'
        }
;
$_allSetters{level} = \&setLevel;
$_allMemberAttributes{prefix} = {
          'name' => 'prefix',
          'description' => 'if set log messages are prefixed with this'
        }
;
$_allSetters{prefix} = \&setPrefix;
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
    my CkuruServer::Debug $this = shift;

    print STDERR "in CkuruServer::Debug::new(" . join (",", @_) . ")\n" if $ENV{DEBUG};
    Confess "Missing the value for an argument (even nulls) on creation of CkuruServer::Debug" if scalar @_ % 2 != 0;

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
            Confess "Field named \"$key\" is not defined in object CkuruServer::Debug. typo ?\n";
        }
    }


    $this->{logDir} = "." unless defined $this->{logDir};

    Confess "cannot initialize object of type CkuruServer::Debug without required member variable logName"
        unless exists $this->{logName};

    Confess "cannot initialize object of type CkuruServer::Debug without required member variable level"
        unless exists $this->{level};


    #### __new is the magic "pre-constructor".  You can intercept a call to the parent
    #### constructor by defining a __new() procedure in your class.

    eval {CkuruServer::Debug::__new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?CkuruServer::Debug::__new/;

    #### Now call the parent constructor, if any.

    eval {$this->SUPER::new(%args)};

    croak $@ if $@
	and $@ !~ /^Can\'t locate object method/;

    ####
    #### Typically this following contains your "real" constructor"
    #### so if you are debugging this next call my be a good candidate to step into.
    ####

    eval {CkuruServer::Debug::_new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?CkuruServer::Debug::_new/;

    $this;
}

###  END GENERATED CODE

=pod

=head1 MEMBERS AND MEMBER ACCESS METHODS

=cut



=pod

=head2 echo => "any string"

when writing to a file, setting  this  variable also causes the debug message to go to stdout

=cut

sub getEcho {

=pod

=head3 $Debug->getEcho ()


getter for member echo

=cut

    my $this = shift;





    return $this->{echo};
}
sub setEcho {

=pod

=head3 $Debug->setEcho (echo => "any string")

 - echo ("any string")		 : when writing to a file, setting  this  variable also causes the debug message to go to stdout

setter for member echo

=cut

    my $this = shift;


    my $echo = shift;



    $this->{echo} = $echo;
    return $echo;
}



=pod

=head2 logDir => "any string" (default: ".")

Directory to hold the CKURUSERVER log

=cut

sub getLogDir {

=pod

=head3 $Debug->getLogDir ()


getter for member logDir

=cut

    my $this = shift;





    return $this->{logDir};
}
sub setLogDir {

=pod

=head3 $Debug->setLogDir (logDir => "any string")

 - logDir ("any string")		 : Directory to hold the CKURUSERVER log

setter for member logDir

=cut

    my $this = shift;


    my $logDir = shift;



    $this->{logDir} = $logDir;
    return $logDir;
}



=pod

=head2 logName => "any string"*

Log name

=cut

sub getLogName {

=pod

=head3 $Debug->getLogName ()


getter for member logName

=cut

    my $this = shift;





    return $this->{logName};
}
sub setLogName {

=pod

=head3 $Debug->setLogName (logName => "any string"*)

 - logName ("any string")		 : Log name

setter for member logName

=cut

    my $this = shift;


    my $logName = shift;
    Confess "argument 'logName' is required for CkuruServer::Debug->setLogName()" unless defined $logName;



    $this->{logName} = $logName;
    return $logName;
}



=pod

=head2 logFH => FileHandle

Filehandle of the log file

=cut

sub getLogFH {

=pod

=head3 $Debug->getLogFH ()


getter for member logFH

=cut

    my $this = shift;





    return $this->{logFH};
}
sub setLogFH {

=pod

=head3 $Debug->setLogFH (logFH => FileHandle)

 - logFH (FileHandle)		 : Filehandle of the log file

setter for member logFH

=cut

    my $this = shift;


    my $logFH = shift;
    eval {my $dummy = $logFH->isa("FileHandle");};Confess "$@\n" . Dumper($logFH) if $@;
    if (defined $logFH) { Confess "argument 'logFH' of method CkuruServer::Debug->setLogFH() is required to be of reference type FileHandle, but it looks to be of type " . ref ($logFH)  unless $logFH->isa("FileHandle");}



    $this->{logFH} = $logFH;
    return $logFH;
}



=pod

=head2 level => "any string"*

Assigned log level

=cut

sub getLevel {

=pod

=head3 $Debug->getLevel ()


getter for member level

=cut

    my $this = shift;





    return $this->{level};
}
sub setLevel {

=pod

=head3 $Debug->setLevel (level => "any string"*)

 - level ("any string")		 : Assigned log level

setter for member level

=cut

    my $this = shift;


    my $level = shift;
    Confess "argument 'level' is required for CkuruServer::Debug->setLevel()" unless defined $level;



    $this->{level} = $level;
    return $level;
}



=pod

=head2 prefix => "any string"

if set log messages are prefixed with this

=cut

sub getPrefix {

=pod

=head3 $Debug->getPrefix ()


getter for member prefix

=cut

    my $this = shift;





    return $this->{prefix};
}
sub setPrefix {

=pod

=head3 $Debug->setPrefix (prefix => "any string")

 - prefix ("any string")		 : if set log messages are prefixed with this

setter for member prefix

=cut

    my $this = shift;


    my $prefix = shift;



    $this->{prefix} = $prefix;
    return $prefix;
}



=pod

=head2 debug => "any string"

debug allows an object to specify its debugPrint level

=cut

sub getDebug {

=pod

=head3 $Debug->getDebug ()


getter for member debug

=cut

    my $this = shift;





    return $this->{debug};
}
sub setDebug {

=pod

=head3 $Debug->setDebug (debug => "any string")

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

This file was automatically generated from Debug.pm.m80 by 
bret on ubuntu (Linux ubuntu 2.6.31-19-generic-pae #56-Ubuntu SMP Thu Jan 28 02:29:51 UTC 2010 i686 GNU/Linux)


=head1 OBJECT METHODS

=cut



sub _new {

=pod

=head3 $Debug->_new ()


callback constructor, do not call directly use new() instead

=cut

    my $this = shift;

    Confess "CkuruServer::Debug->_new requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;




    if ($this->{logDir}) {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my $thisMonth = sprintf ("%4.4d%2.2d",$year+1900,$mon+1);
	
	my $newFile = "$this->{logDir}/$this->{logName}.$thisMonth.log";
	system ("mkdir -p $this->{logDir}") && confess "failed to create $this->{logDir}, check your -logDir setting or system permissions.";

	chmod 0644, $newFile;
	$this->{logFH} = FileHandle->new();
	$this->{logFH}->autoflush(1);
	$this->{logFH}->open (">> $newFile") or 
	    die "cannot open log file $newFile";
    }
}

sub debugCmd {
    my ($this, $level, $cmd) = @_;
    eval ($cmd) 
	if ($level <= $this->getLevel());
}

sub debug {
    my $this = shift;
    
    my ($level, $data, $task_id) = @_;

    if ($level =~ m/$this->{level}/ || $level <= $this->{level}) {
        my ($caller) = (caller(1))[3];
        my ($line) = (caller(1))[2];
        $caller = "[$caller:$line]" if $caller;

	my $save = $\;
	$\ = "\n";
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my $now = sprintf ("%2.2d/%2.2d/%02d-%2.2d:%2.2d:%2.2d",$mon+1,$mday,$year+1900,$hour,$min,$sec);
	my $logMsg = "";
	$logMsg .= $this->{'prefix'} if defined $this->{'prefix'};
	$logMsg .= "$now($$) $caller: $data";
	if ($this->{logFH}) {
	    my $fh = $this->{logFH};
	    print $fh $logMsg;
	    print $logMsg if $this->{echo};
	} else {
	    print $logMsg;
	}
	if ($task_id) {
	    my $task = $task::allTasks{$task_id};
	    if ($task && $task->getProperty('taskLogFH')) {
		my $fh = $task->getProperty('taskLogFH');
		print $fh $logMsg;
	    }
	}
	$\ = $save;
    }
}

1;