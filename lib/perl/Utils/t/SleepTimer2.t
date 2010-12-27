#!/usr/bin/perl 

use Utils::SleepTimer;

my $st = Utils::SleepTimer->new(sleepTimer => 20);

$debug=2;

for (my $i = 0 ; $i < 100 ; $i++) {
    $st->getSleepVal();
}
$st->reset();
for (my $i = 0 ; $i < 100 ; $i++) {
    $st->getSleepVal();
}

$st->reset();
$st->setSleepTimer(10);
for (my $i = 0 ; $i < 100 ; $i++) {
    $st->getSleepVal();
}


    
