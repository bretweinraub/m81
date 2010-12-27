package VariableExpander; # -*-perl-*-
use Carp qw(cluck);

m4_include(./perloo.m4)m4_dnl

sub new {
    my $arg = &_dn_options;

    my $object = {};
    bless $object, "VariableExpander";
    
    map {$object->setProperty($_, $arg->{$_});} (keys (%{$arg}));
    return $object;
};

sub splitexpand {
    $_[0]->{debug}->debug(3,"VariableExpander::_expand (" . join (',', @_) . ")") if $_[0]->{debug};
    my $ref = shift;

    my %arg = @_;

    @matches = split (/\./, $arg{match});
    return $ref->_expand(type=> $matches[0], 
			 variable => $matches[1], 
			 modifier => $matches[2],
			 taskContext => $arg{taskContext},
			 taskHistory => $arg{taskHistory},
			 taskOBJ => $arg{taskOBJ});
}

sub expand {
    $_[0]->{debug}->debug(3,"VariableExpander::expand (" . join (',', @_) . ")") if $_[0]->{debug};

    my $ref = shift;
    my $arg = &_dn_options;

#
# The original expansion algorithm .... semi-flat ANT style.
#
#    if (! $ref->getProperty(expansionStyle) =~ m/exp/i) {
    my $text = $arg->{text};
    my $taskContext = $arg->{taskContext};
    my $taskOBJ = $arg->{taskOBJ};
    my $taskHistory = $arg->{taskHistory};

    my $origText = $text;
    $text =~ s/\$\((.+?)\)/$ref->splitexpand(match=> $1, 
					     taskContext => $taskContext,
					     taskHistory => $taskHistory,
					     taskOBJ => $taskOBJ)/ge;
#    $text =~ s/\$\(([^.]+)\.([^\)]+)\)/$ref->_expand(type=> $1, 
#						     variable => $2, 
#						     taskContext => $taskContext,
#						     taskHistory => $taskHistory,
#						     taskOBJ => $taskOBJ)/ge;

    $ref->{debug}->debug(3, "VariableExpander::expand: \"$origText\" expanded to \"$text\"") if $ref->{debug};
    return $text;
#    } else {
#
# V2 expansion algorithm ; eval (sprintf)
#
#	my $thistask = $arg->{thistask};
#	return eval "sprintf (\"" . $arg->{text} . "\")";
#    }
}

sub _expand {
    $_[0]->{debug}->debug(3,"VariableExpander::_expand (" . join (',', @_) . ")") if $_[0]->{debug};
    my $ref = shift;
    my $arg = &_dn_options;

    my $debug = $arg->{debug};
    my $type = $arg->{type};
    my $variable = $arg->{variable};
    my $modifier = $arg->{modifier};
    my $taskContext = $arg->{taskContext};
    my $taskOBJ = $arg->{taskOBJ};
    my $taskHistory = $arg->{taskHistory};

    my $mapper = $taskOBJ->getMapper if $taskOBJ;

    $variable =~ $mapper if $mapper;

    $debug->debug(3, "looking for variable ($variable) type $type") if $debug;

    ($type =~ /env/) && do {return $ENV{$variable};};
    ($type =~ /taskobj/) && do {
	return $taskOBJ->getProperty($variable) if $taskOBJ;
	cluck ("\$(taskobj) formulation found with no \$taskOBJ");
    };
    ($type =~ /thistask/) && do {return $taskOBJ->getProperty($variable);};

    ($type =~ /context/) && do {
	return ($taskContext 
		? $taskContext->{$variable}
		: $taskOBJ->fetchContextSimple($variable));
    };

    ($type =~ /task/) && do {
	$debug->debug(2, "WARNING: use of deprecated \$(task.) construct; use \$(context.) instead.  This formulation will be removed in a future release",
			      $taskOBJ ? $taskOBJ->getProperty(task_id) : undef) if $debug;
			      
	return ($taskContext 
		? $taskContext->{$variable}
		: $taskOBJ->fetchContextSimple($variable));
    };

#
# Order matters since these regexps are not "bounded" by '^' or '$'
#

    ($type =~ /internal/) && do {my $ret = eval "$variable"; return $ret;};
    ($type =~ /history/) && do {return $taskHistory->{$variable}{$modifier} ; };
}

1;
