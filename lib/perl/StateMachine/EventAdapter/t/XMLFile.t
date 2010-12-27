#!/usr/bin/perl

use StateMachine::EventAdapter::XMLFile;
use Data::Dumper;

$main::debug = 3;

my $XMLFile = StateMachine::EventAdapter::XMLFile->new                          # 
    (filename =>                                                                
     "$ENV{M80_REPOSITORY}/projects/$ENV{PROJECT}/StateMachineInterfaces.pl");  # This gets built when the m80repository is built/deployed


my $Interface = $XMLFile->getInterfaceByName(interface => "ETL");               # Interface is of type StateMachine::EventAdapter::Interface

print Dumper($Interface);
