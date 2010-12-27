#!/usr/bin/perl
# -*-perl-*-

use M80Repository::DeployableBits;

my $ret = M80Repository::DeployableBits->new(
    name => "DeployThis",
    srcPath => "/tmp",
    destPath => "/tmp/x",
    )->dump;

unless ($ret =~ /DeployThis_destPath/) {
    die "all required fields not generated from M80Repository::DeployableBits->new()";
}

exit 0;

