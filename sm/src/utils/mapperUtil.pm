
package mapperUtil;

#
# =pod
#
# =head1 NAME
# 
#  mapperUtil.pm
#
# =head1 SYNOPSIS
#
# mapperUtil::envMapper - returns a string representing localized environment variables.
#


sub envMapper
{
    my ($prefix) = @_;
    my $ret;

    foreach $envVar (keys(%ENV)) {
	# build match regexp
	$orig = $envVar;
	$match = "^" . $prefix . "_";
	if ($envVar =~ /$match/) {
	    $envVar =~ s/$match//;
	    print STDERR (caller(0))[3] . ": setting \${$envVar} based on \${$orig}\n";
	    $ret .= " " if $ret;
	    $ret .= $envVar . "=\"" . $ENV{$orig} . "\"";
	}
    }
    return $ret;
}

1;
