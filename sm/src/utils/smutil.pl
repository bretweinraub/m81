#
# =pod
#
# =head1 NAME
#
# smutil.pl
# 
# =head1 SYNOPSIS
# 
# simple utilities for state machine code.
# 
# =head1 EXAMPLES
#
# require "smutil.pl";
#
# requireScalar(fieldName,viewName,taskName,contextVariableName);
#
#
# =cut 
# 

use Carp;

sub requireScalar {
    my $x;
    map { 
	eval "\$x = \$$_;";
#
# The next line is not necessary if the calling script does a "use Env";
#
	eval "\$x = \$ENV{$_};" unless ($x);
	confess "variable \$$_ is required but not set, use -$_ or set \${$_} in your environment" unless $x ;
    } (@_);
}

1;


