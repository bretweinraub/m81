#!/usr/bin/perl -w
#
#
# spawnChildTasks.pl - loops through an XML document using XPATH.
#                      spawns child tasks when a pattern is matched.
#

use Acme::JavaTrace;
use Data::Dumper;
use File::Basename;
use Getopt::Long;
use lib dirname($0);
use XML::XPath;
use dbutil;
use Carp;
use Env qw (task_id);
use MetaDataObject;

require "automatorBase.pl";

$algorithm = "XMLClassic";

GetOptions("algorithm:s" => \$algorithm,
	   "task_id:s" => \$task_id,
	   "list:s" => \$list,
	   "flag:s" => \$flag,
	   "setting:s" => \$setting,
	   "childTaskName:s" => \$childTaskName,
	   "xmlfile:s" => \$xmlfile,
	   "xpath:s" => \$xpath,
	   "debug" => \$debug,
	   "unique:s" => \$unique,
	   "requireChildren" => \$requireChildren,
	   "attributeName:s" => \$attributeName,
	   "dumpXML" => \$dumpxml);

_require('task_id','algorithm');

print STDERR "running algorithm $algorithm\n";

if ($algorithm =~ /^List$/) {
    _require ('list','childTaskName');

    my @matches = ();

    @list = split (/\s+/, $ENV{$list});
    foreach $item (@list) {
	my $syscmd = "createTask.pl -task $childTaskName -parent $task_id -mapper 's/" . tag2shell($item) . "_//;'";
	print "$syscmd\n" ;
	system($syscmd) unless $debug;
    }
} elsif ($algorithm =~ /^UniqueList$/) {
    _require('list','childTaskName','unique');

    my %matches = ();

    @list = split (/\s+/, $ENV{$list});
    foreach $item (@list) {
	$matches{$ENV{$item . "_" . $unique}} = 1;
    }
    print Dumper(%matches);
    foreach $match (keys (%matches)) {
	my $syscmd = "createTask.pl -task $childTaskName -parent $task_id -mapper 's/" . tag2shell($match) . "_//;'";
	print "$syscmd\n" ;
	system($syscmd) unless $debug;
    }
} elsif ($algorithm =~ /^ListFlagMatch$/) {
    _require ('list','flag','childTaskName','setting');

    my @matches = ();

    @list = split (/\s+/, $ENV{$list});
    foreach $item (@list) {
	push (@matches, $item) if $ENV{tag2shell($item . "_" . $flag)} =~ /$setting/i;
    }
    foreach $match (@matches) {
	my $syscmd = "createTask.pl -task $childTaskName -parent $task_id -mapper 's/" . tag2shell($match) . "_//;'";
	print "$syscmd\n" ;
	system($syscmd) unless $debug;
    }
} elsif ($algorithm =~ /^XMLClassic$/) {
    _require('task_id', 'xmlfile', 'childTaskName', 'xpath', 'attributeName');

    my $data;
    if ($xmlfile =~ m/\.m80$/) {
	$xml = `runPath.pl -file $xmlfile 2>/dev/null`;
    } else {
	$xml = `cat $xmlfile`;
    }

    if ($dumpxml) {
	print $xml;
	die "-dumpxml set";
    }

    die "XPath parse failed" unless my $xp = XML::XPath->new(xml => $xml);

    $\="\n";

    print STDERR "XPath is $xpath";

    my $nodeset = $xp->find($xpath);
    my @nodelist = $nodeset->get_nodelist;

    if ($xmlfile =~ /^\//) {
	1;
    } else {
	$pwd = `pwd`;
	chomp ($pwd);
	$xmlfile = $pwd . "/$xmlfile";
	$xmlfile =~ s/\/\.\//\//g;
    }

    my $children = 0;

    foreach $node (@nodelist) {
	$children++;
#    foreach $attribute ($node->getAttributes) {
#	print $attribute->getName . "=" . $attribute->getData;
#    }
	$attr = $node->getAttribute ($attributeName);
	my $_xpath = "$xpath\[\@$attributeName=\\\'\\\'$attr\\\'\\\'\]";
	$syscmd = dirname($0) . "/createTask.pl -task $childTaskName -parent $task_id -contextAssignment ~~~ -context xmlfile~~~$xmlfile,xpath~~~$_xpath,match~~~$attr";
	print $syscmd;
	system($syscmd);
    }

    print "Created $children children";
    if ($children == 0 && $requireChildren) { 
	print STDERR "failed to create any children; exiting with error code 1";
	exit 1;
    }

    exit 0;

    
} else {
    confess "algorithm $algorithm not implemented";
}






