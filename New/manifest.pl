# -*-perl-*-

use Newable;

@Newables =
    (
#     new Newable (name => "PortalPerfBDF",
#		  description => "An BDF for the Portal Performance Framework",
#		  callSignature => 'docmd("m80 --execute expandTemplate.sh -m $module -t $TOP/templates/interfaceModule.tmpl.m80")',
#		  getopts => [{tag => 'module:s',
#			       variable => '$module',
#			       nomy => 1,
#			       description => 'Name of the new interface module'}]),

     new Newable (name => "M80RepositoryObject",
		  description => "A Special Perl Object just for usage as a m80 repository element",
		  callSignature => 
'
my $x=$object;
$x =~ s/.+?:://g;
docmd("object=$object members=$members runPath -file $ENV{NEW}/M80RepositoryObject/M80RepositoryObject.pm.m80.m80 -dest $x.pm.m80")',
		  getopts => [{tag => 'object:s',
			       variable => '$object',
			       required => 1,
			       nomy => 1,
			       description => 'The name of the new perl object'},
			      {tag => 'members:s',
			       variable => '$members',
			       required => '1',
			       nomy => 1,
			       description => 'comma separated list of members of the new object',
			   },]),

     new Newable (name => "InterfaceModule",
		  description => "An Interface State Machine Module",
		  callSignature => 'docmd("m80 --execute expandTemplate.sh -m $module -t $ENV{NEW}/InterfaceModule/interfaceModule.tmpl.m80")',
		  getopts => [{tag => 'module:s',
			       variable => '$module',
			       required => '1',
			       nomy => 1,
			       description => 'Name of the new interface module'}]),
     new Newable (name => "ProviderModule",
		  description => "An Provider State Machine Module",
		  callSignature => 'docmd("m80 --execute expandTemplate.sh -m $module -t $ENV{NEW}/ProviderModule/providerModule.tmpl.m80")',
		  getopts => [{tag => 'module:s',
			       variable => '$module',
			       required => '1',
			       nomy => 1,
			       description => 'Name of the new provider module'}]),
     new Newable (name => "PerlScript",
		  description => "A Perl Script",
		  callSignature => 'docmd("script=$script runPath -file $ENV{NEW}/PerlScript/PerlScript.tmpl.m80.m80 -dest $script.pl.m80")',
		  getopts => [{tag => 'script:s',
			       variable => '$script',
			       required => '1',
			       nomy => 1,
			       description => 'The name of the new perl script'}]),

     new Newable (name => "PerlDBScript",
		  description => "A Perl Script For Use With the Database",
		  callSignature => 'docmd("script=$script runPath -file $ENV{NEW}/PerlDBScript/PerlDBScript.tmpl.m80.m80 -dest $script.pl.m80")',
		  getopts => [{tag => 'script:s',
			       variable => '$script',
			       required => '1',
			       nomy => 1,
			       description => 'The name of the new database ready perl script'}]),

     new Newable (name => "PerlObject",
		  description => "A Perl Object",
		  callSignature => 
'
my $x=$object;
$x =~ s/.+?:://g;
docmd("object=$object runPath -file $ENV{NEW}/PerlObject/PerlObject.pm.m80.m80 -dest $x.pm.m80")',
		  getopts => [{tag => 'object:s',
			       variable => '$object',
			       required => 1,
			       nomy => 1,
			       description => 'The name of the new perl object'}]),

     new Newable (name => "MetadataObject",
		  description => "A Perl Object",
		  callSignature => 'docmd("object=$object runPath -file $ENV{NEW}/MetadataObject/MetadataObject.pm.m80.m80 -dest $object.pm.m80")',
		  getopts => [{tag => 'object:s',
			       variable => '$object',
			       required => '1',
			       nomy => 1,
			       description => 'The name of the new perl object'},
			      ]),

     new Newable (name => "Makefile",
		  description => "A Makefile that should work in either a node or leaf directory.",
		  callSignature => 'docmd("cp $ENV{NEW}/Makefile_/Makefile .") ; docmd ("chmod +w Makefile");'),


     new Newable (name => "ShellScript",
		  description => "A new ShellScript (using shellHelpers).",
		  callSignature => 'docmd("cp $ENV{NEW}/ShellScript/shellScript.tmpl $script.sh.m80") ; docmd ("chmod +w $script.sh.m80");',
		  getopts => [{tag => 'script:s',
			       variable => '$script',
			       required =>  1,
			       nomy => 1,
			       description => 'The name of the new script'}]),


     new Newable (name => "SshScript",
		  description => "A new SshScript - a script that executes remotely over an ssh connection (using sshHelpers).",
		  callSignature => 'docmd("cp $ENV{NEW}/SshScript/sshScript.tmpl $script.sh.m80") ; docmd ("chmod +w $script.sh.m80");',
		  getopts => [{tag => 'script:s',
			       variable => '$script',
			       nomy => 1,
			       required => '1',
			       description => 'The name of the new script'}]),


     new Newable (name => "ConverterFilter",
		  description => "A new Metadata::Filter::FieldConverter (the standard) for use with the metadata compiler (metac).",
		  callSignature => 'docmd("filter=$filter runPath -file $ENV{NEW}/ConverterFilter/ConverterFilter.pm.m80.m80 -dest $filter.pm.m80")',
		  getopts => [{tag => 'filter:s',
			       variable => '$filter',
			       required => '1',
			       nomy => 1,
			       description => 'The name of the new filter'}]),


     new Newable (name => "AppenderFilter",
		  description => "A new Metadata::Filter::AppenderConverter for use with the metadata compiler (metac).",
		  callSignature => 'docmd("filter=$filter runPath -file $ENV{NEW}/AppenderFilter/AppenderFilter.pm.m80.m80 -dest $filter.pm.m80")',
		  getopts => [{tag => 'filter:s',
			       variable => '$filter',
			       required => '1',
			       nomy => 1,
			       description => 'The name of the new filter'}]),

     new Newable (name => "AllObjectsAppenderFilter",
		  description => "A new Metadata::Filter::Internal::Parameterized Filter for use with the metadata compiler (metac).",
		  callSignature => 'docmd("filter=$filter runPath -file $ENV{NEW}/AllObjectsAppenderFilter/AllObjectsAppenderFilter.pm.m80.m80 -dest $filter.pm.m80")',
		  getopts => [{tag => 'filter:s',
			       variable => '$filter',
			       required => '1',
			       nomy => 1,
			       description => 'The name of the new filter'}]),

     new Newable (name => "RemoteValidationFilter",
		  description => "A new Metadata::Validation::Internal::RemoteValidation extension for use with the metadata compiler (metac).",
		  callSignature => 'docmd("filter=$filter runPath -file $ENV{NEW}/RemoteValidationFilter/RemoteValidationFilter.pm.m80.m80 -dest $filter.pm.m80")',
		  getopts => [{tag => 'filter:s',
			       variable => '$filter',
			       required => '1',
			       nomy => 1,
			       description => 'The name of the new filter'}]),

     new Newable (name => "SimpleValidationFilter",
		  description => "A new Metadata::Validation::Internal::SimpleValidation extension for use with the metadata compiler (metac).",
		  callSignature => 'docmd("filter=$filter runPath -file $ENV{NEW}/SimpleValidationFilter/SimpleValidationFilter.pm.m80.m80 -dest $filter.pm.m80")',
		  getopts => [{tag => 'filter:s',
			       variable => '$filter',
			       required => '1',
			       nomy => 1,
			       description => 'The name of the new filter'}]),

     new Newable (name => "PivotTableReport",
		  description => "A new Report:: for use with the metadata compiler (metac).",
		  callSignature => 'docmd("filter=$filter runPath -file $ENV{NEW}/PivotTableReport/PivotTableReport.pm.m80.m80 -dest $filter.pm.m80")',
		  getopts => [{tag => 'filter:s',
			       variable => '$filter',
			       required => '1',
			       nomy => 1,
			       description => 'The name of the new filter'}]),

     new Newable (name => "ProcessModule",
		  description => "A state machine module that will encapsulate a process.  Nothing fancy here",
		  callSignature => 'docmd("mkdir $module"); docmd("tar cvCf $ENV{NEW}/ProcessModule - . | tar xvCf $module - ; rm -rf $module/.svn*")',
		  getopts => [{tag => "module:s",
			       variable => '$module',
			       required => '1',
			       nomy =>1,
			       description => 'The name of the new module'}]),

     new Newable (name => "TermiteScript",
		  description => "A new TermiteScript (using shellHelpers).",
		  callSignature => 'docmd("cp $ENV{NEW}/TermiteScript/termite.sh.m80 $script.sh.m80") ; docmd ("chmod +w $script.sh.m80");',
		  getopts => [{tag => 'script:s',
			       variable => '$script',
			       required => '1',
			       nomy => 1,
			       description => 'The name of the new termite script'}]),

     new Newable (name => "BoxMonitor",
		  description => "A new BoxMonitory::IMonitor extension for use with the boxMonitor.pl engine.",
		  callSignature => 'docmd("name=$name runPath -file $ENV{NEW}/BoxMonitor/BoxMonitor.pm.m80.m80 -dest $name.pm.m80")',
		  getopts => [{tag => 'name:s',
			       variable => '$name',
			       required => '1',
			       nomy => 1,
			       description => 'The name of the new monitor'}]),

     new Newable (name => "SchemaPatch",
		  description => "a new schema patch src file with the required m80 macros",
		  callSignature => 'docmd("cp $ENV{NEW}/SchemaPatch/schema.sql $script.sql") ; docmd ("chmod +w $script.sql");',
		  getopts => [{tag => 'script:s',
			       variable => '$script',
			       required => '1',
			       nomy => 1,
			       description => 'The name of the new schema patch src script'}]),


     new Newable (name => "TaskCleanupScript",
		  description => "A new taskCleanupScript.pl for use with the StateMachine engine.",
		  callSignature => 'docmd("name=$name runPath -file $ENV{NEW}/TaskCleanupScript/TaskCleanupScript.pl.m80.m80 -dest $name.pl.m80")',
		  getopts => [{tag => 'name:s',
			       variable => '$name',
                               default => 'taskCleanupScript',
			       required => '1',
			       nomy => 1,
			       description => 'The name of the new script'}]),

     );


1;





