#!/usr/bin/perl 

use Metadata::Object;
use Metadata::Object::RTETLManager;
use Metadata::Object::DBDescriptor;
use Metadata::Object::ETLDescriptor;
use Metadata::Object::ETLResource;

use strict;
use Carp;
use Data::Dumper;

push (our @allObjects, 
      Metadata::Object::RTETLManager->new
      (name => "RTETLManager",
       pollTableList => 'Tickets',
       insertDateField => 'Created',
       updateDateField => 'LastUpdated',
       sourceDB => Metadata::Object::DBDescriptor->new(name => "rt",
						       m80namespace => "RTDB"),
       targetDB => Metadata::Object::DBDescriptor->new(name => "TargetDB",
						       m80namespace => "CONTROLLER"),
       failureThreshold => 5,
       ETLs => 
       [
	Metadata::Object::ETLDescriptor->new(name => "rt_tickets",
					     sourceRD => Metadata::Object::ETLResource->new(name => "Tickets",
											    type => "table",
											    naturalKey => "id",
											    createdField => "Created",
											    updatedField => "LastUpdated",
											    tableName => "Tickets"),
					     targetRD =>  Metadata::Object::ETLResource->new(name => "trg_Tickets",
											     type => "table",
											     tableName => "rt_tickets",),
					     transformation => "replicate",
					     ),
	],
       ));

Metadata::Object::dumpObjects(@main::allObjects);

#print STDERR Dumper(@main::allObjects);

1;
