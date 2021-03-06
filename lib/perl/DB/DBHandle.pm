



=pod

=head1 NAME - DB::DBHandle

Base Class For DBIDatabase Handle Wrapper.

=head1 EXAMPLE


        my $dbhandle = DB::DBHandle->new(); 
	my %results = %{$dbhandle->getData(sql => "
                                                   select	*
                                                   from	(
                                                   		select 	datecreated, 
                                                   			max(timecreated) timecreated 
                                                   		from 	$localTableName 
                                                   		where 	datecreated = (select max(DATECREATED) from $localTableName) 
                                                   		group by datecreated
                                                   	),
                                                   	(
                                                   		select 	dateupdated, 
                                                   			max(timeupdated) timeupdated 
                                                   		from 	$localTableName 
                                                   		where 	dateupdated = (select max(DATEUPDATED) from $localTableName) 
                                                   		group by dateupdated
                                                   	)")};


=cut

# This file was automatically generated from DBHandle.pm.m80 by 
# bweinraub on li298-104 (Linux li298-104 2.6.38-linode31 #1 SMP Mon Mar 21 21:22:33 UTC 2011 i686 GNU/Linux)
# DO NOT EDIT THIS FILE 


package DB::DBHandle;

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

use DBI;
use DB::RowSet;
use DB::Table;
use DB::FieldMetaData;
use fields qw( user password namespace SID host dbh connectString debug );

=pod

=head1 CONSTRUCTOR

=over 4

=item DB::DBHandle->new()

initializes on object of type DB::DBHandle

=back

=cut


# %_allSetters - an array of all setters for all members of the class
my %_allSetters = ();

my %_allMemberAttributes = ();

BEGIN {
# $_allMembers{_TYPE} = 1; # - WHAT IS THIS FOR?
$_allMemberAttributes{user} = {
          'name' => 'user',
          'type' => 'string',
          'description' => 'username for the db instance to connect to'
        }
;
$_allSetters{user} = \&setUser;
$_allMemberAttributes{password} = {
          'name' => 'password',
          'description' => 'password for the db instance to connect to'
        }
;
$_allSetters{password} = \&setPassword;
$_allMemberAttributes{namespace} = {
          'name' => 'namespace',
          'description' => 'as an alternative to setting all of the individual connect parameters, a tag like "CONTROLLER" could be use to access a namespace'
        }
;
$_allSetters{namespace} = \&setNamespace;
$_allMemberAttributes{SID} = {
          'name' => 'SID',
          'description' => 'can be a SID, databasename, or ODBC descriptor'
        }
;
$_allSetters{SID} = \&setSID;
$_allMemberAttributes{host} = {
          'name' => 'host',
          'description' => 'host for the db instance to connect to'
        }
;
$_allSetters{host} = \&setHost;
$_allMemberAttributes{dbh} = {
          'ref' => 'DBI::db',
          'name' => 'dbh',
          'description' => 'DBI handle for this Db Connection'
        }
;
$_allSetters{dbh} = \&setDbh;
$_allMemberAttributes{connectString} = {
          'name' => 'connectString',
          'description' => 'DBI connect string for call to DBI->connect()'
        }
;
$_allSetters{connectString} = \&setConnectString;
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
    my DB::DBHandle $this = shift;

    print STDERR "in DB::DBHandle::new(" . join (",", @_) . ")\n" if $ENV{DEBUG};
    Confess "Missing the value for an argument (even nulls) on creation of DB::DBHandle" if scalar @_ % 2 != 0;

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
            Confess "Field named \"$key\" is not defined in object DB::DBHandle. typo ?\n";
        }
    }



    #### __new is the magic "pre-constructor".  You can intercept a call to the parent
    #### constructor by defining a __new() procedure in your class.

    eval {DB::DBHandle::__new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?DB::DBHandle::__new/;

    #### Now call the parent constructor, if any.

    eval {$this->SUPER::new(%args)};

    croak $@ if $@
	and $@ !~ /^Can\'t locate object method/;

    ####
    #### Typically this following contains your "real" constructor"
    #### so if you are debugging this next call my be a good candidate to step into.
    ####

    eval {DB::DBHandle::_new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?DB::DBHandle::_new/;

    $this;
}

###  END GENERATED CODE

=pod

=head1 MEMBERS AND MEMBER ACCESS METHODS

=cut



=pod

=head2 user => "any string"

username for the db instance to connect to

=cut

sub getUser {

=pod

=head3 $DBHandle->getUser ()


getter for member user

=cut

    my $this = shift;





    return $this->{user};
}
sub setUser {

=pod

=head3 $DBHandle->setUser (user => "any string")

 - user ("any string")		 : username for the db instance to connect to

setter for member user

=cut

    my $this = shift;


    my $user = shift;



    $this->{user} = $user;
    return $user;
}



=pod

=head2 password => "any string"

password for the db instance to connect to

=cut

sub getPassword {

=pod

=head3 $DBHandle->getPassword ()


getter for member password

=cut

    my $this = shift;





    return $this->{password};
}
sub setPassword {

=pod

=head3 $DBHandle->setPassword (password => "any string")

 - password ("any string")		 : password for the db instance to connect to

setter for member password

=cut

    my $this = shift;


    my $password = shift;



    $this->{password} = $password;
    return $password;
}



=pod

=head2 namespace => "any string"

as an alternative to setting all of the individual connect parameters, a tag like "CONTROLLER" could be use to access a namespace

=cut

sub getNamespace {

=pod

=head3 $DBHandle->getNamespace ()


getter for member namespace

=cut

    my $this = shift;





    return $this->{namespace};
}
sub setNamespace {

=pod

=head3 $DBHandle->setNamespace (namespace => "any string")

 - namespace ("any string")		 : as an alternative to setting all of the individual connect parameters, a tag like "CONTROLLER" could be use to access a namespace

setter for member namespace

=cut

    my $this = shift;


    my $namespace = shift;



    $this->{namespace} = $namespace;
    return $namespace;
}



=pod

=head2 SID => "any string"

can be a SID, databasename, or ODBC descriptor

=cut

sub getSID {

=pod

=head3 $DBHandle->getSID ()


getter for member SID

=cut

    my $this = shift;





    return $this->{SID};
}
sub setSID {

=pod

=head3 $DBHandle->setSID (SID => "any string")

 - SID ("any string")		 : can be a SID, databasename, or ODBC descriptor

setter for member SID

=cut

    my $this = shift;


    my $SID = shift;



    $this->{SID} = $SID;
    return $SID;
}



=pod

=head2 host => "any string"

host for the db instance to connect to

=cut

sub getHost {

=pod

=head3 $DBHandle->getHost ()


getter for member host

=cut

    my $this = shift;





    return $this->{host};
}
sub setHost {

=pod

=head3 $DBHandle->setHost (host => "any string")

 - host ("any string")		 : host for the db instance to connect to

setter for member host

=cut

    my $this = shift;


    my $host = shift;



    $this->{host} = $host;
    return $host;
}



=pod

=head2 dbh => DBI::db

DBI handle for this Db Connection

=cut

sub getDbh {

=pod

=head3 $DBHandle->getDbh ()


getter for member dbh

=cut

    my $this = shift;





    return $this->{dbh};
}
sub setDbh {

=pod

=head3 $DBHandle->setDbh (dbh => DBI::db)

 - dbh (DBI::db)		 : DBI handle for this Db Connection

setter for member dbh

=cut

    my $this = shift;


    my $dbh = shift;
    eval {my $dummy = $dbh->isa("DBI::db");};Confess "$@\n" . Dumper($dbh) if $@;
    if (defined $dbh) { Confess "argument 'dbh' of method DB::DBHandle->setDbh() is required to be of reference type DBI::db, but it looks to be of type " . ref ($dbh)  unless $dbh->isa("DBI::db");}



    $this->{dbh} = $dbh;
    return $dbh;
}



=pod

=head2 connectString => "any string"

DBI connect string for call to DBI->connect()

=cut

sub getConnectString {

=pod

=head3 $DBHandle->getConnectString ()


getter for member connectString

=cut

    my $this = shift;





    return $this->{connectString};
}
sub setConnectString {

=pod

=head3 $DBHandle->setConnectString (connectString => "any string")

 - connectString ("any string")		 : DBI connect string for call to DBI->connect()

setter for member connectString

=cut

    my $this = shift;


    my $connectString = shift;



    $this->{connectString} = $connectString;
    return $connectString;
}



=pod

=head2 debug => "any string"

debug allows an object to specify its debugPrint level

=cut

sub getDebug {

=pod

=head3 $DBHandle->getDebug ()


getter for member debug

=cut

    my $this = shift;





    return $this->{debug};
}
sub setDebug {

=pod

=head3 $DBHandle->setDebug (debug => "any string")

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

This file was automatically generated from DBHandle.pm.m80 by 
bweinraub on li298-104 (Linux li298-104 2.6.38-linode31 #1 SMP Mon Mar 21 21:22:33 UTC 2011 i686 GNU/Linux)


=head1 OBJECT METHODS

=cut



sub _new {

=pod

=head3 $DBHandle->_new ()


callback constructor, do not call directly use new() instead

=cut

    my $this = shift;

    Confess "DB::DBHandle->_new requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;




    if ($this->getNamespace()) {
	$this->setUser($ENV{$this->getNamespace() . "_USER"});
	$this->setPassword($ENV{$this->getNamespace() . "_PASSWD"});
	$this->setSID($ENV{$this->getNamespace() . "_SID"});
	$this->setHost($ENV{$this->getNamespace() . "_HOST"});
	$this->setPort($ENV{$this->getNamespace() . "_PORT"});
    } else {
	$this->_require('user', 'password', 'host', 'port');
    }

    $this->setPort(1521) unless $this->getPort();
}

sub connect {

=pod

=head3 $DBHandle->connect ()


initializes database connection

=cut

    my $this = shift;

    Confess "DB::DBHandle->connect requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;




    do {
	my $dbh;


	print $this->getConnectString();
	Confess "failed to connect to DBI"
	    unless ($dbh = DBI->connect($this->getConnectString(),, $this->getUser() , $this->getPassword(),
					{ RaiseError => 1 }));

	$this->setDbh($dbh);
    };
}

sub execute {
    
=pod

=head3 $DBHandle->execute (sql => "any string", verbose => "any string")

 - sql ("any string")		 : sql string for this statement
 - verbose ("any string")		 : echo the sql string to STDERR

execute a sql query 

=cut

    my $this = shift;

    Confess "DB::DBHandle->execute requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $sql = $args{sql};
    my $verbose = $args{verbose};



   do {
       $this->debugPrint (1, "$sql");
#       print STDERR $sql . "\n" if $verbose;
       eval {$this->getDbh()->prepare($sql)->execute();};
       Confess "$@" if $@;
   }
}


################################################################################

sub getData {
   
=pod

=head3 $DBHandle->getData (sql => "any string"*, verbose => "any string", lc => "any string")

 - sql ("any string")		 : returns a data object (row set results) based on a SQL string
 - verbose ("any string")		 : verbosity
 - lc ("any string")		 : force all field names to lower case

returns the results of a row set object based on a sql string

=cut

    my $this = shift;

    Confess "DB::DBHandle->getData requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $sql = $args{sql};
    Confess "argument 'sql' is required for DB::DBHandle->getData()" unless exists $args{sql};
    my $verbose = $args{verbose};
    my $lc = $args{lc};



    do {
	return (DB::RowSet->new(dbh => $this->getDbh(),sql => $sql, verbose=> $verbose, lc => $lc)->getResults());
    };
}



################################################################################

sub getDBType {
   
=pod

=head3 $DBHandle->getDBType ()


fetch the database type of this handle

=cut

    my $this = shift;

    Confess "DB::DBHandle->getDBType requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;



    do {
	my $dbType = ref($this);
	$dbType =~ s/DB::(.+?)Handle/$1/g;
	$this->debugPrint(2,"derived database type as $dbType");
	return $dbType;
    };
}


################################################################################

sub newRowSet {
   
=pod

=head3 $DBHandle->newRowSet (sql => "any string", verbose => "any string")

 - sql ("any string")		 : sql string for this statement
 - verbose ("any string")		 : echo the sql string to STDERR

returns a rowset based on the SQL argument

=cut

    my $this = shift;

    Confess "DB::DBHandle->newRowSet requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $sql = $args{sql};
    my $verbose = $args{verbose};



    do {
	return DB::RowSet->new(dbh => $this->getDbh(),
			       sql => $sql,
			       verbose => $verbose);
    };
}


################################################################################

sub tableMetaData {
   
=pod

=head3 $DBHandle->tableMetaData (table => "any string"*, column => "any string"*)

 - table ("any string")		 : data to process
 - column ("any string")		 : column name to evaluate

fetch the meta data for a table

=cut

    my $this = shift;

    Confess "DB::DBHandle->tableMetaData requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $table = $args{table};
    Confess "argument 'table' is required for DB::DBHandle->tableMetaData()" unless exists $args{table};
    my $column = $args{column};
    Confess "argument 'column' is required for DB::DBHandle->tableMetaData()" unless exists $args{column};



    do {
	my $dbh = $this->getDbh();

	my $stmt;
	eval {
	    $stmt = $dbh->prepare("select * from $table where 1 = 0");
	    $stmt->execute();
	};
	Confess "$@" if $@;
	for (my $i = 0 ; $i < $stmt->{NUM_OF_FIELDS} ; $i++) {
	    if (lc($stmt->{NAME}->[$i]) eq lc($column)) {
		$this->debugPrint(2, "found field $column");
		my $column = $stmt->{NAME}->[$i];
		my $ret = DB::FieldMetaData->new (name => $column,
						  type => $stmt->{TYPE}->[$i],
						  precision => $stmt->{PRECISION}->[$i],
						  scale => $stmt->{SCALE}->[$i]);
#		$this->debugPrint(2, "new object is " . Dumper($ret));
		return $ret;
	    }
	}
    };
}


################################################################################

sub newTable {
    
=pod

=head3 $DBHandle->newTable (name => "any string"*, primaryKeyName => "any string", requirePrimaryKey => "any string")

 - name ("any string")		 : table name - must already exists.
 - primaryKeyName ("any string")		 : name of this tables primary key name.  If not defined the name will be attempted to be derived from the DBHandle
 - requirePrimaryKey ("any string")		 : require a derived primary key

creates a new table record on this handle

=cut

    my $this = shift;

    Confess "DB::DBHandle->newTable requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $name = $args{name};
    Confess "argument 'name' is required for DB::DBHandle->newTable()" unless exists $args{name};
    my $primaryKeyName = $args{primaryKeyName};
    my $requirePrimaryKey = $args{requirePrimaryKey};



    do {
	my $_primaryKeyName;

	unless ($primaryKeyName) {
	    eval {
		$_primaryKeyName = $this->fetchPrimaryKeyName(name => $name,
							      required => $requirePrimaryKey);
	    };
	    Confess "$@" if $@;
	} else {
	    $_primaryKeyName = $primaryKeyName;
	}
	
	DB::Table->new(handle => $this,
		       name => $name,
		       primaryKeyName => $_primaryKeyName);
    };
}

################################################################################

sub tableExists {
   
=pod

=head3 $DBHandle->tableExists (name => "any string"*)

 - name ("any string")		 : name to query for

returns true if a table exists in this handle

=cut

    my $this = shift;

    Confess "DB::DBHandle->tableExists requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $name = $args{name};
    Confess "argument 'name' is required for DB::DBHandle->tableExists()" unless exists $args{name};



    do {
	my $dbh = $this->getDbh();

	Confess "invalid character $1 in table name $name"
	    if $name =~ /(-|\/)/;

	$this->debugPrint (0, "the next statement may throw an error (which is to be expected)");
	my $stmt;
	eval {
	    $stmt = $dbh->prepare("select * from $name where 1 = 0");
	};
	$this->debugPrint(1, "$@") if $@;
	$stmt;
    };
}


################################################################################

sub validColumnName {
   
=pod

=head3 $DBHandle->validColumnName (data => "any string"*)

 - data ("any string")		 : data to process

returns a column name that is truncated to fit this DBMS

=cut

    my $this = shift;

    Confess "DB::DBHandle->validColumnName requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $data = $args{data};
    Confess "argument 'data' is required for DB::DBHandle->validColumnName()" unless exists $args{data};



    do {
	$this->debugPrint (3, "validColumnName($data), length " . length($data));

	substr($data,0,$this->maxColumnLength());
    };
}


################################################################################

sub DBIPrecisionToGenericPrecision {
   
=pod

=head3 $DBHandle->DBIPrecisionToGenericPrecision (data => "any string"*)

 - data ("any string")		 : data to process

SQL Server "Length" doesn't conform to the standard used by Oracle or Mysql.  This is the actual storage size.  So we need to convert this to the bounding used by oracle (which is the number of digits to store).  Fun!  DBHandle contains a default method that just returns the passed in length

=cut

    my $this = shift;

    Confess "DB::DBHandle->DBIPrecisionToGenericPrecision requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $data = $args{data};
    Confess "argument 'data' is required for DB::DBHandle->DBIPrecisionToGenericPrecision()" unless exists $args{data};



    do {
	$data;
    };
}



################################################################################

sub setAutoCommit {
   
=pod

=head3 $DBHandle->setAutoCommit (value => "any string"*)

 - value ("any string")		 : value to assign

set the autocommit value for the underlying DBI handle

=cut

    my $this = shift;

    Confess "DB::DBHandle->setAutoCommit requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $value = $args{value};
    Confess "argument 'value' is required for DB::DBHandle->setAutoCommit()" unless exists $args{value};



    do {
	$this->getDbh()->{AutoCommit} = $value;
    };
}



sub clone {
   
=pod

=head3 $DBHandle->clone (sourceTable => DB::Table*, columnNameTranslators => "any string", name => "any string"*, prefixDateColumns => "any string", suppressM80 => "any string")

 - sourceTable (DB::Table)		 : table to clone
 - columnNameTranslators ("any string")		 : translation description for column names that need to be converted
 - name ("any string")		 : table to create
 - prefixDateColumns ("any string")		 : prefix for data columns  (default: "local_")
 - suppressM80 ("any string")		 : don't add in the m80 magic columns

clone a table based on a metadata description

=cut

    my $this = shift;

    Confess "DB::DBHandle->clone requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $sourceTable = $args{sourceTable};
    Confess "argument 'sourceTable' is required for DB::DBHandle->clone()" unless exists $args{sourceTable};
    eval {my $dummy = $sourceTable->isa("DB::Table");};Confess "$@\n" . Dumper($sourceTable) if $@;
    if (defined $sourceTable) { Confess "argument 'sourceTable' of method DB::DBHandle->clone() is required to be of reference type DB::Table, but it looks to be of type " . ref ($sourceTable)  unless $sourceTable->isa("DB::Table");}
    my $columnNameTranslators = $args{columnNameTranslators};
    my $name = $args{name};
    Confess "argument 'name' is required for DB::DBHandle->clone()" unless exists $args{name};
    my $prefixDateColumns = ($args{prefixDateColumns} ? $args{prefixDateColumns} : "local_");
    my $suppressM80 = $args{suppressM80};



    do {
	my $validName = $this->validTableName(data => $name);
	$this->createTable(name => $validName,
			   columns => $sourceTable->getColumns(),
			   columnNameTranslators => $columnNameTranslators,
			   prefixDateColumns => $prefixDateColumns,
			   suppressM80 => $suppressM80,
			   instantiationTable => 1);
	$validName;	
    };
}

################################################################################

sub validTableName {
   
=pod

=head3 $DBHandle->validTableName (data => "any string"*)

 - data ("any string")		 : data to process

returns a valid table name for this RDBMS

=cut

    my $this = shift;

    Confess "DB::DBHandle->validTableName requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $data = $args{data};
    Confess "argument 'data' is required for DB::DBHandle->validTableName()" unless exists $args{data};



    do {
	$data;
    };
}

################################################################################

################################################################################

sub bindParam {
   
=pod

=head3 $DBHandle->bindParam (data => DB::FieldMetaData*, sourceTable => DB::Table, dateFormat => "any string")

 - data (DB::FieldMetaData)		 : data to process
 - sourceTable (DB::Table)		 : truncate this table if set
 - dateFormat ("any string")		 : can be used to specify the date format used in the input (default: "YYYY-MM-DD HH24:MI:SS")

returns the appropriate bind param syntax for a type

=cut

    my $this = shift;

    Confess "DB::DBHandle->bindParam requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $data = $args{data};
    Confess "argument 'data' is required for DB::DBHandle->bindParam()" unless exists $args{data};
    eval {my $dummy = $data->isa("DB::FieldMetaData");};Confess "$@\n" . Dumper($data) if $@;
    if (defined $data) { Confess "argument 'data' of method DB::DBHandle->bindParam() is required to be of reference type DB::FieldMetaData, but it looks to be of type " . ref ($data)  unless $data->isa("DB::FieldMetaData");}
    my $sourceTable = $args{sourceTable};
    eval {my $dummy = $sourceTable->isa("DB::Table");};Confess "$@\n" . Dumper($sourceTable) if $@;
    if (defined $sourceTable) { Confess "argument 'sourceTable' of method DB::DBHandle->bindParam() is required to be of reference type DB::Table, but it looks to be of type " . ref ($sourceTable)  unless $sourceTable->isa("DB::Table");}
    my $dateFormat = ($args{dateFormat} ? $args{dateFormat} : "YYYY-MM-DD HH24:MI:SS");



    do {
	"?";
    };
}

################################################################################

sub truncateTable {
   
=pod

=head3 $DBHandle->truncateTable (name => "any string"*)

 - name ("any string")		 : table name to truncate

truncate a table in a DB specific way (oracle)

=cut

    my $this = shift;

    Confess "DB::DBHandle->truncateTable requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $name = $args{name};
    Confess "argument 'name' is required for DB::DBHandle->truncateTable()" unless exists $args{name};



    do {
	$this->execute (sql => "truncate table $name");
    };
}

################################################################################

sub scrubBindData {
   
=pod

=head3 $DBHandle->scrubBindData (data => "any string"*, field => "any string")

 - data ("any string")		 : data to process
 - field ("any string")		 : field metadata for the data

when binding data to an insert or update statement, this routine is called to pre-scrub the data.  Handles simple migration issues between RDBM(s)

=cut

    my $this = shift;

    Confess "DB::DBHandle->scrubBindData requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $data = $args{data};
    Confess "argument 'data' is required for DB::DBHandle->scrubBindData()" unless exists $args{data};
    my $field = $args{field};



    do {
	$data;
    };
}

################################################################################

sub selectParam {
   
=pod

=head3 $DBHandle->selectParam (data => DB::FieldMetaData*, dateFormat => "any string")

 - data (DB::FieldMetaData)		 : data to process
 - dateFormat ("any string")		 : can be used to specify the date format used in the input (default: "YYYY-MM-DD HH24:MI:SS")

returns the appropriate select param syntax for a type

=cut

    my $this = shift;

    Confess "DB::DBHandle->selectParam requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $data = $args{data};
    Confess "argument 'data' is required for DB::DBHandle->selectParam()" unless exists $args{data};
    eval {my $dummy = $data->isa("DB::FieldMetaData");};Confess "$@\n" . Dumper($data) if $@;
    if (defined $data) { Confess "argument 'data' of method DB::DBHandle->selectParam() is required to be of reference type DB::FieldMetaData, but it looks to be of type " . ref ($data)  unless $data->isa("DB::FieldMetaData");}
    my $dateFormat = ($args{dateFormat} ? $args{dateFormat} : "YYYY-MM-DD HH24:MI:SS");



    do {
	my $name=$data->getName();
	$this->debugPrint (3, "examining " . $name . " : " . $this->getTypeAsText(data => $data));
	$name;
    };
}

################################################################################

sub cloneColumn {
   
=pod

=head3 $DBHandle->cloneColumn (table => "any string"*, column => DB::FieldMetaData*)

 - table ("any string")		 : table to create table on
 - column (DB::FieldMetaData)		 : metadata for cloned column

creates a column in a table based on metadata from another table

=cut

    my $this = shift;

    Confess "DB::DBHandle->cloneColumn requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $table = $args{table};
    Confess "argument 'table' is required for DB::DBHandle->cloneColumn()" unless exists $args{table};
    my $column = $args{column};
    Confess "argument 'column' is required for DB::DBHandle->cloneColumn()" unless exists $args{column};
    eval {my $dummy = $column->isa("DB::FieldMetaData");};Confess "$@\n" . Dumper($column) if $@;
    if (defined $column) { Confess "argument 'column' of method DB::DBHandle->cloneColumn() is required to be of reference type DB::FieldMetaData, but it looks to be of type " . ref ($column)  unless $column->isa("DB::FieldMetaData");}




   do {
       my $cloneSQL = "alter table " . $table->getName();
       $cloneSQL .= " add " . $this->validColumnName(data => $column->getName());
       $cloneSQL .= " " . $this->getTypeAsText(data => $column,
					       full => 't');
       $this->execute(sql => $cloneSQL,
		      verbose => 1);
   };
}

################################################################################
