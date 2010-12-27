#!/usr/bin/perl

use DB::DBHandleFactory;
use DB::OracleHandle;
use DB::FieldMetaData;

my $dbhandle = DB::DBHandleFactory::newDBHandle();

my %columns = (
    test => DB::FieldMetaData->new (name => "test",
				    type => 4,
				    precision => 10,
				    handle => $dbhandle,
				    scale => 0));

$debug = 2;

$dbhandle->createTable(name => "x_test_table",
		       columns => \%columns,
		       prefixDateColumns => "test_",
		       drop => 1,
		       instantiationTable => t);


$dbhandle->createTable(name => "y_test_table",
		       columns => \%columns,
		       prefixDateColumns => "test_",
#			  noexec =>1,
		       drop => 1,
		       suppressM80 => 1,
		       instantiationTable => t);

exit 0;
