#!/usr/bin/perl

#
# =pod
#
# =head1 NAME
#
# importChildContext.pl
# 
# =head1 SYNOPSIS
# 
# 
# 
# =head1 OPTIONS AND ARGUMENTS
# 
# =over 4
# 
# =item 
# 
# 
# 
# =item 
# 
# 
# 
# =back
# 
# =head1 DESCRIPTION
# 
# 
#
# =head1 EXAMPLES
#
# 
#
# =head1 PREREQUISITES
#
# 
#
# =cut 
# 

use Getopt::Long;
use File::Basename;
use lib dirname($0);
use dbutil;

require "automatorBase.pl";

GetOptions("task_id:i", \$task_id,
	   "name|taskname:s", \$name);

_require(task_id,name);

dbutil::loadSQL ($dbh, "select 	tag, 
			value
		from	task_context
		where	task_id in
			(
				select	task_id	
				from	task
				where	parent_task_id = $task_id
				and	taskname = '$name'
			)", \%context, "true");

for ($i = 0 ; $i < $context{rows} ; $i++) {
    dbutil::runSQL($main::dbh, "delete from task_context where task_id = $task_id and tag = '$context{TAG}[$i]'", "true");
    dbutil::runSQL($main::dbh, "insert into task_context (task_id, tag, value) values ($task_id, '" . $context{TAG}[$i] . "', '" . $context{VALUE}[$i] . "')","true");
}
