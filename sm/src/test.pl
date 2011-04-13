#!/usr/bin/perl

use File::Basename;

if (dirname($0) =~ /^\./) {
    $script_dir=`pwd`;
    chomp($dir);
} else {
    $script_dir = dirname($0);
}

print $dir;

$args = "";

foreach $arg (@ARGV) {
    $args .= "$arg ";
}




print $args;


$status="cancel";

if ( $status !~ /cancel/) {
    print "match";
} else {
    print "no match";
}
