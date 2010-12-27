#!/usr/bin/perl 

use Metadata::Object;
use Metadata::Object::SugarETLManager;
use Metadata::Object::DBDescriptor;
use Metadata::Object::ETLDescriptor;
use Metadata::Object::ETLResource;

use strict;
use Carp;
use Data::Dumper;

eval {
    my $ETLManager = Metadata::Object::ETLManager->new();
};

$main::debug = $ENV{debug};

confess "name check did not run correctly" unless "$@";

push (our @allObjects, 
      Metadata::Object::SugarETLManager->new
      (name => "SugarETLManager",
       pollTableList => 'accounts_v leads_v contacts cases_v notes',
       sourceDB => Metadata::Object::DBDescriptor->new(name => "Sugar",
						       m80namespace => "SUGARDB"),
       targetDB => Metadata::Object::DBDescriptor->new(name => "TargetDB",
						       m80namespace => "CONTROLLER"),
       failureThreshold => 2,
       ETLs => 
       [
	Metadata::Object::ETLDescriptor->new(name => "sugar_accounts",
					     sourceRD => Metadata::Object::ETLResource->new(name => "src_account_data",
											    type => "table",
											    naturalKey => "id",
											    createdField => "date_entered",
											    updatedField => "date_modified",
											    tableName => "accounts_v"),
					     targetRD =>  Metadata::Object::ETLResource->new(name => "trg_account_data",
											     type => "table",
											     tableName => "sugar_accounts"),
					     transformation => "replicate",
					     ),

	Metadata::Object::ETLDescriptor->new(name => "sugar_leads",
					     sourceRD => Metadata::Object::ETLResource->new(name => "src_lead_data",
											    type => "table",
											    createdField => "date_entered",
											    updatedField => "date_modified",
											    naturalKey => "id",
											    tableName => "leads_v"),
					     targetRD =>  Metadata::Object::ETLResource->new(name => "trg_leads_data",
											     type => "table",
											     tableName => "sugar_leads"),
					     transformation => "replicate",
					     ),
	
	Metadata::Object::ETLDescriptor->new(name => "sugar_contacts",
					     sourceRD => Metadata::Object::ETLResource->new(name => "src_contact_data",
											    type => "table",
											    createdField => "date_entered",
											    updatedField => "date_modified",
											    naturalKey => "id",
											    tableName => "contacts"),
					     targetRD =>  Metadata::Object::ETLResource->new(name => "trg_contacts_data",
											     type => "table",
											     tableName => "sugar_contacts"),
					     transformation => "replicate",
					     ),

	Metadata::Object::ETLDescriptor->new(name => "sugar_cases",
					     sourceRD => Metadata::Object::ETLResource->new(name => "src_case_data",
											    type => "table",
											    createdField => "date_entered",
											    updatedField => "date_modified",
											    naturalKey => "id",
											    tableName => "cases_v"),
					     targetRD =>  Metadata::Object::ETLResource->new(name => "trg_cases_data",
											     type => "table",
											     tableName => "sugar_circuits"),
					     transformation => "replicate",
					     ),
	Metadata::Object::ETLDescriptor->new(name => "sugar_notes",
					     sourceRD => Metadata::Object::ETLResource->new(name => "src_notes_data",
											    type => "table",
											    createdField => "date_entered",
											    updatedField => "date_modified",
											    naturalKey => "id",
											    tableName => "notes"),
					     targetRD =>  Metadata::Object::ETLResource->new(name => "trg_notes_data",
											     type => "table",
											     tableName => "sugar_notes"),
					     transformation => "replicate",
					     ),
	
	
	],
       ));

Metadata::Object::dumpObjects(@main::allObjects);

#print STDERR Dumper(@main::allObjects);

1;
