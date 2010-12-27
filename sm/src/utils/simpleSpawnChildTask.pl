#!/usr/bin/perl
#
#
# simpleSpawnChildTasks.pl - loops through env and 
#                      spawns child tasks when a pattern is matched.
#

use Data::Dumper;
use File::Basename;
use Getopt::Long;
use lib dirname($0);
use dbutil;

require "automatorBase.pl";

my $requireChildren = 1;

GetOptions("task_id:s" => \$task_id,
	   "childTaskName:s" => \$childTaskName,
	   "debug" => \$debug,
	   "requireChildren!" => \$requireChildren,
	   "attribute:s" => \$attribute,
           "use-stdin"   => \$usestdin,
           "test" => \$test,
           );

_require(task_id, childTaskName);
die "cannot run without attribute definition!" unless $attribute;

$\="\n";
my $children = 0;
my @info = ();

if ($usestdin) {
    while(<>) {
        push @info, split /,|:|\s+/;
    }
} elsif ($ENV{$attribute}) {
    @info = split(/,|:|\s+/, $ENV{$attribute});
} else {
    die "No data on STDIN or in the ENV for $attribute!";
}

# unique @info
my %seen = ();
@info = grep { ! $seen{ $_ }++ } @info;
for my $context (@info) {
    $children++;
    $syscmd = dirname($0) . 
        "/createTask.pl -task $childTaskName -parent $task_id -contextAssignment ~~~ -context $attribute~~~$context";
    print $syscmd;
    system($syscmd) unless $test;
}

print "Created $children children";
if ($children == 0 && $requireChildren) { 
    print STDERR "failed to create any children; exiting with error code 1";
    exit 1;
}

exit 0;
