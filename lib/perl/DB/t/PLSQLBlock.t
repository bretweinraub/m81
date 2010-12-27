#!/usr/bin/perl

use DB::DBHandleFactory;
use DB::OracleHandle;
use DB::FieldMetaData;
use Utils::PerlTools;

my $dbhandle = DB::DBHandleFactory::newDBHandle();


print STDERR $dbhandle->PLSQLBlock(sql => 'drop table PLSQLBlockTest',
				   ignore => ArrayRef(-942,-1000));


exit 0;






