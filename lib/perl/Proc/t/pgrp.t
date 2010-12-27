#!/usr/bin/perl

use Proc::ProcWrapper;

my $pw = Proc::ProcWrapper->new();

print STDERR "... pg: " . $pw->getPgrp() . " $$ .......";
