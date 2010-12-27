#!/usr/bin/perl

use Acme::JavaTrace;
use File::Basename;
use lib dirname($0) . "/..";
use dbutil;
use Getopt::Long;
use Carp;
use Data::Dumper;
use autoUtil;
use ChainDB;
use task;

require "require.pl";

my $argMapper;

Getopt::Long::Configure( "pass_through" );
GetOptions("task_id:s" => \$task_id);

_require(task_id);

my $ChainDB = ChainDB::new;
my %context = %{$ChainDB->loadTaskContext($task_id)};

my $mapper = $argMapper ? $argMapper : task::_getMapper (task_id => $task_id, ChainDB => $ChainDB);

print "# mapper is $mapper\n";

map {
    my $data = $_;
    $mapped = task::applyMapper (mapper => $mapper, data => $data);

    $ENV{$mapped} = "$context{$data}";
    $ENV{$data} = "$context{$data}";
} (keys(%context));

$ENV{task_id} = $task_id;

exec (@ARGV);

#
# =pod
#
# =head1 NAME
#
# taskCommand.pl - execute a command in the "context" of a StateMachine task.
# 
# =head1 SYNOPSIS
# 
# taskCommand.pl [ -task_id <task_id> -mapper <mapper> command-to-execute]
# 
# =head1 OPTIONS AND ARGUMENTS
# 
# =over 4
# 
# =item task_id - $task_id
# 
# required. This is the $task_id of the task context to run inside of.
# 
# =item mapper - $mapper
# 
# optional identical in functionality to a mapper from the StateMachine module.xml.
# 
# =back
# 
# =head1 DESCRIPTION
# 
# In many ways taskCommand.pl is very simalar to a "m80 --execute".  It loads the context
# of a task (into the process environment) and then execs another command.
#
# It is useful when debugging a failed task.
#
# =head1 EXAMPLES
#
#  m80 --execute ./taskCommand.pl -task_id 496 -mapper 's/bld_//' env
#
# =head1 PREREQUISITES
#
# taskCommand.pl takes its databae connect info from the environment CONTROLLER_* variables,
# so typically it is required to run it inside of the StateMachine enviornment by setting
# the m80 environment.  
#
# IF YOU USE MAPPERS right now the only reliable way to run this from m80 is to do:
#
#  -> mexec bash
#
#  -> taskCommand.pl -task_id 515 -mapper "s/downloadServer_//;"
#
# This is because of quoting problems with m80 --execute.
#
# =cut 
# 
