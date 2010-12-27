#!/usr/bin/perl 

use Utils::ContextInsensitiveHash;
use Data::Dumper;
use strict;


tie my %x, "Utils::ContextInsensitiveHash";

$x{'ThIs'} = 'That';

$x{'OthEr'} = 'Foo';

$\="\n";

die "failed to validate context insensitivity"
    unless ($x{'This'} =~ /That/ and
	    $x{'this'} =~ /That/ and
	    $x{'THIS'} =~ /That/);

print "Validated context insensitivity";

my $key;
print "Dumping Keys";
foreach $key (keys(%x)) {
    print "$key = " . $x{$key};
}

sub valExists {
    foreach my $arg (@_) {
	if (exists $x{$arg}) {
	    print "Validated context insensitivity with exists: $arg";
	} else {
	    die "failed  Validated context insensitivity with exists:  $arg";
	}
    }
}

print "x{THIS} = " . $x{THIS};
valExists('this', 'THIS');

exit 1;






