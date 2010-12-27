


=pod

=head1 NAME - RTG::ETLHelper

RTG::ETLHelper description; stub description please expand

=head1 EXAMPLE


  my $RTGHelper = RTG::ETLHelper->new();
  my $router_tableName = $RTGHelper->getRouterTableName();
  my $targetHandle = $RTGHelper->getTargetHandle();
  my $routerData = $targetHandle->newRowSet(sql => "select * from $router_tableName", lc => 't');


=cut

# This file was automatically generated from ETLHelper.pm.m80 by 
# bret on ubuntu (Linux ubuntu 2.6.31-19-generic-pae #56-Ubuntu SMP Thu Jan 28 02:29:51 UTC 2010 i686 GNU/Linux)
# DO NOT EDIT THIS FILE 


package RTG::ETLHelper;

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

use Storable qw(dclone);
use DB::Utils;
use DB::FieldMetaData;

use base qw(DB::ETLHelper);

=pod

=head1 INHERITANCE

RTG::ETLHelper extends class DB::ETLHelper ; refer to the documentation for that object for member variables and methods.

=cut

use fields qw( routerTableName debug );

=pod

=head1 CONSTRUCTOR

=over 4

=item RTG::ETLHelper->new()

initializes on object of type RTG::ETLHelper

=back

=cut


# %_allSetters - an array of all setters for all members of the class
my %_allSetters = ();

my %_allMemberAttributes = ();

BEGIN {
# $_allMembers{_TYPE} = 1; # - WHAT IS THIS FOR?
$_allMemberAttributes{routerTableName} = {
          'name' => 'routerTableName',
          'description' => 'name of the router table in the source RTG schema'
        }
;
$_allSetters{routerTableName} = \&setRouterTableName;
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
    my RTG::ETLHelper $this = shift;

    print STDERR "in RTG::ETLHelper::new(" . join (",", @_) . ")\n" if $ENV{DEBUG};
    Confess "Missing the value for an argument (even nulls) on creation of RTG::ETLHelper" if scalar @_ % 2 != 0;

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
            Confess "Field named \"$key\" is not defined in object RTG::ETLHelper. typo ?\n";
        }
    }



    #### __new is the magic "pre-constructor".  You can intercept a call to the parent
    #### constructor by defining a __new() procedure in your class.

    eval {RTG::ETLHelper::__new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?RTG::ETLHelper::__new/;

    #### Now call the parent constructor, if any.

    eval {$this->SUPER::new(%args)};

    croak $@ if $@
	and $@ !~ /^Can\'t locate object method/;

    ####
    #### Typically this following contains your "real" constructor"
    #### so if you are debugging this next call my be a good candidate to step into.
    ####

    eval {RTG::ETLHelper::_new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?RTG::ETLHelper::_new/;

    $this;
}

###  END GENERATED CODE

=pod

=head1 MEMBERS AND MEMBER ACCESS METHODS

=cut



=pod

=head2 routerTableName => "any string"

name of the router table in the source RTG schema

=cut

sub getRouterTableName {

=pod

=head3 $ETLHelper->getRouterTableName ()


getter for member routerTableName

=cut

    my $this = shift;





    return $this->{routerTableName};
}
sub setRouterTableName {

=pod

=head3 $ETLHelper->setRouterTableName (routerTableName => "any string")

 - routerTableName ("any string")		 : name of the router table in the source RTG schema

setter for member routerTableName

=cut

    my $this = shift;


    my $routerTableName = shift;



    $this->{routerTableName} = $routerTableName;
    return $routerTableName;
}



=pod

=head2 debug => "any string"

debug allows an object to specify its debugPrint level

=cut

sub getDebug {

=pod

=head3 $ETLHelper->getDebug ()


getter for member debug

=cut

    my $this = shift;





    return $this->{debug};
}
sub setDebug {

=pod

=head3 $ETLHelper->setDebug (debug => "any string")

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

This file was automatically generated from ETLHelper.pm.m80 by 
bret on ubuntu (Linux ubuntu 2.6.31-19-generic-pae #56-Ubuntu SMP Thu Jan 28 02:29:51 UTC 2010 i686 GNU/Linux)


=head1 OBJECT METHODS

=cut



sub _new {

=pod

=head3 $ETLHelper->_new ()


callback constructor, do not call directly use new() instead

=cut

    my $this = shift;

    Confess "RTG::ETLHelper->_new requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;



    do {
#
# Look for the router table name
#
	my $router_targetRD = $ENV{router_targetRD};
	Confess "cannot find rtg router target resource descriptor in metadata"
	    unless $router_targetRD;

	my $router_tableName = $ENV{$router_targetRD . "_tableName"};
	Confess "cannot find rtg router table name in metadata"
	    unless $router_targetRD;

	$this->setRouterTableName($router_tableName);
    };
}

################################################################################

sub createETLTables {
   
=pod

=head3 $ETLHelper->createETLTables ()


create a staging table for this data feed

=cut

    my $this = shift;

    Confess "RTG::ETLHelper->createETLTables requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;



    do {
	my $sourceTable = $this->getSourceTable();
	my %columns = %{$sourceTable->getColumns()};

	# add in a column for the router id
	$columns{rid} = DB::FieldMetaData->new(name => "rid",
					       type => DB::FieldMetaData::getDataType(data => "INTEGER"),
					       precision => 10,
					       handle => $this->getSourceHandle(),
					       scale => 0);
	$sourceTable->setColumns(\%columns);

	unless ($this->getNoCreate()) {
	    foreach my $tableName ($this->getTargetTableName(), $this->getStageTableName()) {
		# stage tables is not an m80 table
		createTables(dbhandle => $this->getTargetHandle(), 
			     sourceTable => $sourceTable, 
			     prefixDateColumns => "stage_",
			     suppressM80 => (($tableName eq $this->getStageTableName()) ? 1 : undef),
			     columnNameTranslators => $this->getColumnNameTranslators(),
			     targetTableNames => [$tableName]);
	    }
	}
   
    };
}

################################################################################

sub getMaxDate {
   
=pod

=head3 $ETLHelper->getMaxDate (rid => "any string"*)

 - rid ("any string")		 : router id


Returns the maximum date of the currently loaded data.  Used to filter the new rows brought over from the RTG database.

=cut

    my $this = shift;

    Confess "RTG::ETLHelper->getMaxDate requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $rid = $args{rid};
    Confess "argument 'rid' is required for RTG::ETLHelper->getMaxDate()" unless exists $args{rid};


    my $targetHandle = $this->getTargetHandle(); 

    do {
	my $rowSet = $targetHandle->newRowSet(sql => "select " . $targetHandle->dateSelector(data => "max(dtime)") . 
					      " maxDate from " . $this->getTargetTableName() . " where rid = $rid");

	$rowSet->next();
	my $maxDate = $rowSet->item("MAXDATE"); # XXX this is nasty oracle specific nonesense - the RowSet class should be dealing with this.

	$maxDate;
    };
}


################################################################################

sub generateDayQuery {
   
=pod

=head3 $ETLHelper->generateDayQuery (tableName => "any string"*, rid => "any string"*, numDays => "any string", sourceMax => "any string", sourceMin => "any string", targetMax => "any string")

 - tableName ("any string")		 : table name to be polling data from
 - rid ("any string")		 : router id for this query 
 - numDays ("any string")		 : number of days to extract from RTG at a time, defaults to 1 (default: "1")
 - sourceMax ("any string")		 : maximum date of data in the source table
 - sourceMin ("any string")		 : minimum date of data in the source table
 - targetMax ("any string")		 : maximum date of data in the target table

based on timestamps in both the source and destination tables, generates a SQL query to fetch an additional day of data

=cut

    my $this = shift;

    Confess "RTG::ETLHelper->generateDayQuery requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $tableName = $args{tableName};
    Confess "argument 'tableName' is required for RTG::ETLHelper->generateDayQuery()" unless exists $args{tableName};
    my $rid = $args{rid};
    Confess "argument 'rid' is required for RTG::ETLHelper->generateDayQuery()" unless exists $args{rid};
    my $numDays = ($args{numDays} ? $args{numDays} : "1");
    my $sourceMax = $args{sourceMax};
    my $sourceMin = $args{sourceMin};
    my $targetMax = $args{targetMax};



    do {
	$this->debugPrint(0, "dates for $rid: sourceMin: $sourceMin ; sourceMax : $sourceMax ; targetMax : $targetMax");

	my $sql = "select $tableName.*, $rid rid from $tableName where dtime";

	if ($targetMax) {
	    $sql .= "> '$targetMax' and dtime <= DATE_ADD('$targetMax', INTERVAL $numDays day)";
	} else {
	    $sourceMin =~ s/(\d\d\d\d-\d\d-\d\d).*/$1/;
	    
	    $sql .= " >= '$sourceMin 00:00:00' and dtime < '$sourceMin 23:59:59'";
	    $this->debugPrint (0, "$sql");
	    return $sql;
	}
    };
}

################################################################################

sub fetchMonths {
   
=pod

=head3 $ETLHelper->fetchMonths (tableName => "any string")

 - tableName ("any string")		 : tableName to fetch months from


Gets a list of each month in a data table.  Defaults to the stage table name
if not passed in in the method call.

Returns an object of type DB::RowSet



=cut

    my $this = shift;

    Confess "RTG::ETLHelper->fetchMonths requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $tableName = $args{tableName};



    do {
	$tableName = $this->getStageTableName()
	    unless $tableName;

	my $RowSet = $this->getTargetHandle()->newRowSet(sql => "select distinct to_char(dtime, 'YYYY-MM') month from $tableName order by month");
	my @months;
	while($RowSet->next()) {
	    push (@months, $RowSet->item("MONTH"));
	}
	\@months;
    };
}

################################################################################

sub createMonthlyTables {
   
=pod

=head3 $ETLHelper->createMonthlyTables (truncate => "any string")

 - truncate ("any string")		 : truncate the destination tables.  This is *EXTREMELY* dangerous should only used if you know what you are doing

looks at the data in the staging table.  Validates or Creates a monthly table for each month in the staged data

=cut

    my $this = shift;

    Confess "RTG::ETLHelper->createMonthlyTables requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;
    my $truncate = $args{truncate};


    my $columnNameTranslators = $this->getColumnNameTranslators(); 
    my $routerTableName = $this->getRouterTableName(); 
    my $stageTable = $this->getStageTable(); 
    my $targetHandle = $this->getTargetHandle(); 
    my $targetTableName = $this->getTargetTableName(); 
    my $targetTable = $this->getTargetTable(); 

    do {
	my @months;
	foreach my $month (@{$this->fetchMonths()}) {
	    $month =~ s/-/_/g;
	    push (@months, $targetTableName . "_" . $month);
	}

	createTables(dbhandle => $targetHandle,
		     truncate => $truncate,
		     sourceTable => $stageTable, 
		     prefixDateColumns => $routerTableName . "_",
		     columnNameTranslators => $columnNameTranslators,
		     targetTableNames => \@months);
    };
}