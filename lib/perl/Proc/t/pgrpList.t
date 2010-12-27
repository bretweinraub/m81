#!/usr/bin/perl

use Proc::ProcWrapper;
use Data::Dumper;
use Utils::PerlTools;


my $pgrp = 23531;
#my $pgrp = $$;


my $pw = Proc::ProcWrapper->new();


my $arr = Proc::ProcWrapper::processGroupList(pgrp => $pgrp);

#my $pw = Proc::ProcWrapper->new();

print Dumper($arr);

print "ME:\n";
print Dumper($pw->getSelf());

$debug = 1;

$pw->killProcessGroup(pgrp => $pgrp, 
		      killSignals => ArrayRef(2,15,9),
		      nokill => 1);
