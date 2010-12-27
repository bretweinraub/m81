#!/usr/bin/perl -w
#
#
# runInParallel.pl - loops through an XML document using XPATH.
#                      spawns child tasks when a pattern is matched.
#

use Data::Dumper;
use Getopt::Long;
use Carp;
use Env;
use MetaDataObject;
use ReAssemble;

#
# Builds a list of one WLS object per box to run the install on.
#

require "automatorBase.pl";

GetOptions("task_id:s" => \$task_id,
	   "childTaskName:s" => \$childTaskName,
           "objectTypes:s" => \@objTypes,
           'mapperKeyField:s' => \$mapperKeyField,
	   "debug" => \$debug);

my %matches = ();
my @list = ();
$mapperKeyField ||= 'host';
$mapperKeyField = uc $mapperKeyField if $mapperKeyField =~ /^name$/i;

for $l (@objTypes) {
    push @list, grep { ! /^\s*$/ } split /(\s+|,)/, $ENV{'ALL_' . uc $l . 'S'};
}

# dedupe the list
my %dedupe; @dedupe{ @list } = 1; @list = keys %dedupe;

print Dumper(\@list);

# see what the mapper should be based on:
foreach $item (@list) {
    $item =~ s/^\s+//; $item =~ s/\s+$//;
    next if $item =~ /^\s*$/; # ignore empties that snuck in
    $item = tag2shell($item);
    # if an env var is found that is named per the list and the special item, then capture it.
    $matches{$ENV{$item . '_' . $mapperKeyField}} = $item if $ENV{$item . '_' . $mapperKeyField};
}

print Dumper(\%matches);


# generate new tasks for each match
foreach $match (keys (%matches)) {
    my $syscmd = "createTask.pl -task $childTaskName  -parent $task_id -mapper 's/" . 
        tag2shell($match) . "_//;'";
    print "$syscmd\n" ;
    system($syscmd) unless $debug;
}

