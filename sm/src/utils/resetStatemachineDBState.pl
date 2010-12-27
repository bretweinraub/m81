#!/usr/bin/perl

use File::Basename;
use lib dirname($0);
use Data::Dumper;
use dbutil;
use Getopt::Long;
use Term::ANSIColor qw(:constants);
use Env;
use Carp;
require "dbConnect.pl";
require "require.pl";

GetOptions("debug" => \$debug);
$sql = "update task set status = 'failed' where status not in ('succeeded', 'failed')";
dbutil::runSQL ($dbh, $sql, $debug);
exit 0;


