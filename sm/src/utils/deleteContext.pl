#!/usr/bin/perl 

use Getopt::Long;
use Env;

GetOptions("task_id:s" => \$task_id, "tag:s" => \$tag);

require "smutil.pl";
requireScalar(task_id,tag);

require "dbConnect.pl";
dbutil::runSQL($main::dbh, "delete from task_context where task_id = $task_id and tag = '$tag'", "true");
