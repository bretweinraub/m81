#!/usr/bin/perl 

use Getopt::Long;
use Env;

GetOptions("task_id:s" => \$task_id, "tag:s" => \$tag, "value:s" => \$value);

require "smutil.pl";
requireScalar(task_id,tag,value);

require "dbConnect.pl";
dbutil::runSQL($main::dbh, "delete from task_context where task_id = $task_id and tag = '$tag'", "true");
dbutil::runSQL($main::dbh, "insert into task_context (task_id, tag, value) values ($task_id, '$tag', '$value')","true");
