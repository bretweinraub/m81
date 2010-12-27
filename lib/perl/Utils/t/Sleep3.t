#!/usr/bin/perl 

use Utils::SleepTimer;

my $st = Utils::SleepTimer->new();

$debug=2;

for (my $i = 0 ; $i < 3 ; $i++) {
    $st->sleep();
}


    
