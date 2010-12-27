#!/usr/bin/perl

use  M80Repository::SQLServer;


print M80Repository::SQLServer->new(name => "SolarWinds",
				    interface => "SolarWindsDev",
				    user => "bweinraub",
				    password => "wbs123321")->dump;
