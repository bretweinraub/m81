#!/usr/bin/perl

=pod

=head1 smfind.pl

This script will resolve the location of an action.



=cut

use xmlhelper;
use VariableExpander;

use File::Basename;
use Getopt::Long;
use Data::Dumper;

GetOptions("config:s" => \my $configFile);

$xmlhelper = xmlhelper::new (configFile => $configFile);
$expander = VariableExpander::new (expansionStyle => "traditional");

$xml = $xmlhelper->getProperty(xml);

foreach my $module (@{$xml->{module}}) {
    my $moduleName = $expander->expand(text => $module->{name});
    my $deployDir = $expander->expand(text => $module->{deployDir});
    my $scoped = $expander->expand(text => $module->{scoped});
    my $commandPrototype = $module->{commandPrototype};

    foreach (@{$module->{tasks}}) {
	foreach (@{$_->{task}}) {
	    $this = $_;
	    $this->{moduleName} = $moduleName;
	    $this->{deployDir} = $deployDir;
	    $this->{name} = $expander->expand( text => ($scoped ? $moduleName . "-" : "") . $this->{name});
	}
	print Dumper($this);
    }

    foreach (@{$module->{actions}}) {
	foreach (@{$_->{action}}) {
	    $this = $_;
	    $this->{moduleName} = $moduleName;
	    $this->{deployDir} = $deployDir;
	    $this->{name} = $expander->expand(text => ($scoped ? $moduleName . "-" : "") . $this->{name});
	    if ($commandPrototype) {
		$this->{commandPrototype} = $commandPrototype ;
	    }
	    print Dumper($this);
	}
    }
}



