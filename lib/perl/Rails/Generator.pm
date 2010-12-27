


=pod

=head1 NAME - Rails::Generator

Will generate various rails artifacts based on inputs

=head1 EXAMPLE


    my $Generator = $Generator->new();   # stub example .... expand


=cut

# This file was automatically generated from Generator.pm.m80 by 
# bweinraub on li264-192 (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux)
# DO NOT EDIT THIS FILE 


package Rails::Generator;

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

use DB::DBHandle;
use DB::Table;
use DB::RowSet;
use fields qw( projectRoot debug );

=pod

=head1 CONSTRUCTOR

=over 4

=item Rails::Generator->new()

initializes on object of type Rails::Generator

=back

=cut


# %_allSetters - an array of all setters for all members of the class
my %_allSetters = ();

my %_allMemberAttributes = ();

BEGIN {
# $_allMembers{_TYPE} = 1; # - WHAT IS THIS FOR?
$_allMemberAttributes{projectRoot} = {
          'required' => 1,
          'name' => 'projectRoot',
          'type' => 'string',
          'description' => 'root of the rails project'
        }
;
$_allSetters{projectRoot} = \&setProjectRoot;
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
    my Rails::Generator $this = shift;

    print STDERR "in Rails::Generator::new(" . join (",", @_) . ")\n" if $ENV{DEBUG};
    Confess "Missing the value for an argument (even nulls) on creation of Rails::Generator" if scalar @_ % 2 != 0;

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
            Confess "Field named \"$key\" is not defined in object Rails::Generator. typo ?\n";
        }
    }


    Confess "cannot initialize object of type Rails::Generator without required member variable projectRoot"
        unless exists $this->{projectRoot};


    #### __new is the magic "pre-constructor".  You can intercept a call to the parent
    #### constructor by defining a __new() procedure in your class.

    eval {Rails::Generator::__new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?Rails::Generator::__new/;

    #### Now call the parent constructor, if any.

    eval {$this->SUPER::new(%args)};

    croak $@ if $@
	and $@ !~ /^Can\'t locate object method/;

    ####
    #### Typically this following contains your "real" constructor"
    #### so if you are debugging this next call my be a good candidate to step into.
    ####

    eval {Rails::Generator::_new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?Rails::Generator::_new/;

    $this;
}

###  END GENERATED CODE

=pod

=head1 MEMBERS AND MEMBER ACCESS METHODS

=cut



=pod

=head2 projectRoot => "any string"*

root of the rails project

=cut

sub getProjectRoot {

=pod

=head3 $Generator->getProjectRoot ()


getter for member projectRoot

=cut

    my $this = shift;





    return $this->{projectRoot};
}
sub setProjectRoot {

=pod

=head3 $Generator->setProjectRoot (projectRoot => "any string"*)

 - projectRoot ("any string")		 : root of the rails project

setter for member projectRoot

=cut

    my $this = shift;


    my $projectRoot = shift;
    Confess "argument 'projectRoot' is required for Rails::Generator->setProjectRoot()" unless defined $projectRoot;



    $this->{projectRoot} = $projectRoot;
    return $projectRoot;
}



=pod

=head2 debug => "any string"

debug allows an object to specify its debugPrint level

=cut

sub getDebug {

=pod

=head3 $Generator->getDebug ()


getter for member debug

=cut

    my $this = shift;





    return $this->{debug};
}
sub setDebug {

=pod

=head3 $Generator->setDebug (debug => "any string")

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

This file was automatically generated from Generator.pm.m80 by 
bweinraub on li264-192 (Linux li264-192 2.6.35.4-x86_64-linode16 #1 SMP Mon Sep 20 16:03:34 UTC 2010 x86_64 GNU/Linux)


=head1 OBJECT METHODS

=cut



sub _new {

=pod

=head3 $Generator->_new ()


callback constructor, do not call directly use new() instead

=cut

    my $this = shift;

    Confess "Rails::Generator->_new requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;




    do {
	my $projectRoot = $this->getProjectRoot();

	chdir($projectRoot) or
	    Confess "failed to change directory to $projectRoot";

	use File::Glob ':globally';
	my @railsfiles = <config/database.yml*>;

	Confess "directory $projectRoot does not appear to be a rails project"
	    unless $#railsfiles >= 0;
    };
}

################################################################################

sub generateModel {
   
=pod

=head3 $Generator->generateModel (name => "any string"*, dbhandle => DB::DBHandle, force => "any string")

 - name ("any string")		 : model name
 - dbhandle (DB::DBHandle)		 : database handle
 - force ("any string")		 : force overwrite if the model exists.

generate a rails model class from a database  table

=cut

    my $this = shift;

    Confess "Rails::Generator->generateModel requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $name = $args{name};
    Confess "argument 'name' is required for Rails::Generator->generateModel()" unless exists $args{name};
    my $dbhandle = $args{dbhandle};
    eval {my $dummy = $dbhandle->isa("DB::DBHandle");};Confess "$@\n" . Dumper($dbhandle) if $@;
    if (defined $dbhandle) { Confess "argument 'dbhandle' of method Rails::Generator->generateModel() is required to be of reference type DB::DBHandle, but it looks to be of type " . ref ($dbhandle)  unless $dbhandle->isa("DB::DBHandle");}
    my $force = $args{force};



    do {
	$this->debugPrint(0, "$name");
	my $railsName = railsName(data=>$name);
	my $objectName = objectName(data=>$railsName);


	if (-f "app/model/$railsName.rb" and not $force) {
	    $this->debugPrint (0, "skipping $railsName, set -force to override");
	    return;
	} else  {
	    $this->debugPrint(0, "generating $railsName.rb");
	}

	my $table = $dbhandle->newTable(name => $name);
	my $RowSet = $table->getReferers();
	my $referrals = $table->getReferrals();


	system("cp app/models/$railsName.rb app/models/$railsName.rb.save.$$");
	open (MODEL, "> app/models/$railsName.rb");
	print MODEL "
class $objectName < ActiveRecord::Base
  set_primary_key \"" . lc($name) . "_id\"
  set_table_name :" . lc($name) . "
  set_sequence_name \"" . lc($name) . "_s\"
";
	while($RowSet->next()) {
	    print MODEL "
  has_many :" . lc($RowSet->item("REFERRING_TABLE")) . "s, :foreign_key => \"" . lc ($RowSet->item("REFERRING_COLUMN")) .  "\"";
	}

	while($referrals->next()) {
	    print MODEL "
  belongs_to :" . lc($referrals->item("REFERRED_TABLE"));
	}

	my %columns = %{$table->getColumns()};

	if ($columns{resource_type} and $columns{resource_id}) {
	    print MODEL "
  belongs_to :resource, :polymorphic => true
";
	}

	if ($columns{$railsName . "_name"}) {
	    print MODEL "
  def to_label
    #{$railsName" . "_name}
  end
";
	}


	print MODEL "
end
";
	close(MODEL);
    };
}

################################################################################

sub railsName {
   
=pod

=head3 $Generator->railsName (data => "any string"*)

 - data ("any string")		 : data to process

turn a db table name  into a rails name

=cut

    Confess "Rails::Generator::railsName requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $data = $args{data};
    Confess "argument 'data' is required for Rails::Generator::railsName()" unless defined $data;



    do {
	debugPrint_s(1, "processing table $data");
	my $railsName = $data;
#	$railsName =~ s/(.+?)s$/$1/g;
	$railsName = lc ($railsName);
	debugPrint_s(1, "returning $railsName");
	$railsName;
    };
}

################################################################################

sub objectName {
   
=pod

=head3 $Generator->objectName (data => "any string"*)

 - data ("any string")		 : data to process

turn a db table name  into a object name

=cut

    Confess "Rails::Generator::objectName requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $data = $args{data};
    Confess "argument 'data' is required for Rails::Generator::objectName()" unless defined $data;



    do {
	debugPrint_s(1, "processing table $data");
	my $objectName = $data;
	$objectName =~ s/^([\w+])/\U$1/g;
	$objectName =~ s/_([\w])/uc($1)/ge;
	debugPrint_s(1, "returning $objectName");
	$objectName;
    };
}

################################################################################

sub activeScaffold {
   
=pod

=head3 $Generator->activeScaffold (tableName => "any string"*, layoutName => "any string"*)

 - tableName ("any string")		 : tableName to generate active scaffold for
 - layoutName ("any string")		 : layout name to generate active scaffold for

Generates active scaffolds artifacts based on input

=cut

    my $this = shift;

    Confess "Rails::Generator->activeScaffold requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $tableName = $args{tableName};
    Confess "argument 'tableName' is required for Rails::Generator->activeScaffold()" unless exists $args{tableName};
    my $layoutName = $args{layoutName};
    Confess "argument 'layoutName' is required for Rails::Generator->activeScaffold()" unless exists $args{layoutName};



    do {
	$this->debugPrint(1, "processing table $tableName");
	my $railsName = railsName(data => $tableName);
	my $objectName = objectName(data => $railsName);
	$this->debugPrint(2, "rails model name is $railsName");	
	docmd("ruby script/generate model $railsName -f");
	docmd("ruby script/generate controller $railsName -f");
	open (MODEL, "> app/models/$railsName.rb");
	print MODEL "
class $objectName < ActiveRecord::Base
  set_primary_key \"" . lc($objectName) . "_id\"
  set_table_name :" . lc($objectName) . "
  set_sequence_name \"" . lc($objectName) . "_s\"
  def self.inheritance_column ()
    nil
  end
end
";
	close(MODEL);

	open (CONTROLLER, "> app/controllers/" . $railsName. "_controller.rb");
	print CONTROLLER "
class " . $objectName . "Controller < ApplicationController
  before_filter :authenticate
  layout \"$layoutName\"
  active_scaffold :$railsName do |config|
  end
end
";
	close(CONTROLLER);
    };
}



