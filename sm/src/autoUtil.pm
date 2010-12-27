#
# This package contains minor utilities used by the automation tool.
#

package autoUtil;

sub removeSingleQuotes
{
    my $ret = $_[0];
    $ret =~ s/\'//g;
    return $ret;
}

sub removeAllQuoteChars
{
    my $ret = removeSingleQuotes($_[0]);
    $ret =~ s/\"//g;
    return $ret;
}

1;
