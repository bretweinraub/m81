#!/usr/bin/perl

#
# A simple script to manage cron entries.
#

#
# =pod
#
# =head1 NAME
#
# cronRegister.pl - A Simple script for updating cron entries.
# 
# =head1 SYNOPSIS
#
#   -> ./cronRegister.pl -tag TEST -command 'exit 0' -schedule '0 0 * * *' 
#   -> crontab -l | grep TEST
#   0 0 * * * exit 0 # CronManage: TEST
#   -> ./cronRegister.pl -tag TEST -command 'exit 0' -schedule '0 0 * * *' -uninstall
#   -> crontab -l | grep TEST
#   -> 
#
# =cut
#

use Getopt::Long;
use Fcntl ':flock'; # import LOCK_* constants
use Data::Dumper;
use File::Basename;

sub lock {
    my ($lockfile) = @_ if @_;
    open(LOCKFILE, ">$lockfile") or die "Can't open lockfile $lockfile: $!";

    unless (flock(LOCKFILE, LOCK_EX)) {
	die "could not acquire exclusive lock on $lockfile, although I tried to block even; geesh.";
    }
    print LOCKFILE $$ . "\n";
}

# =pod
# 
# =head1 OPTIONS AND ARGUMENTS
# 
# =over 4
# 
# =item -tag
# 
# required. This is the unique tag used to identify the job in the crontab.
# 
# =item -command
# 
# required. The command actually to be fed to cron.
#
# =item -schedule
#
# required. The cron schedule ... see man crontab(5) for more details
#
# =item -uninstall
#
# Instead of adding the item; deletes the item referred to by tag.
#
# =back
#
# =cut

my $controller = "CONTROLLER";

GetOptions("tag:s" => \my $tag,
	   "command:s" => \my $command,
	   "schedule:s" => \my $schedule,
	   "uninstall" => \my $uninstall,
	   "controller" => \$controller,
	   "help" => \my $help);

if ($help) {
    system ("env PD_DIRS=" . dirname($0) . " pd " . basename($0));
    exit 0;
}

die "set -schedule" unless $schedule;


die "set -tag" unless $tag;

die "set -command" unless $command;

$me=`whoami`;
chomp($me);
lock("/tmp/" . basename($0) . ".$me");


$host = $ENV{$controller . "_DEPLOY_HOST"};
$user = $ENV{$controller . "_DEPLOY_USER"};

die "could not derive deploy data for $controller" unless ($host && $user);

$sshcommand="ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey -l $user $host";

print STDERR "ssh command is $sshcommand\n";

@lines=`$sshcommand crontab -l`;

$newCronFile="/tmp/" . basename($0) . ".$me." . $$;

open NEWCRON, ">$newCronFile" or die "blast; can\'t open $newCronFile";

foreach $line (@lines) {
    if ($line =~ m/.+?\# CronManage: (.*)$/) {
	$matchedTag=$1;
	if ($matchedTag eq $tag) {
	    print "matched $1\n";
	} else {
	    print NEWCRON $line;	    
	}
    } else {
	print NEWCRON $line;
    }
}

unless ($uninstall) {
    print "$schedule $command \# CronManage: $tag\n";
    print NEWCRON "$schedule $command \# CronManage: $tag\n";
}

use Data::Dumper;
$newCommand="cat $newCronFile | $sshcommand 'cat > " . $newCronFile . "; crontab " . $newCronFile . "'";
print Dumper($newCommand);

system ($newCommand);

#
# =pod
# 
# =head1 DESCRIPTION
# 
# Simple script for plugging in, replacing, and removing cron entries based on a unique tag.
#
#
# =head1 TODO
#
# Needs to be made to work over ssh.
#
# =head1 WHERE
#
# //QA/wlp/main/perf/etl/util/cronRegister.pl
#
# =cut 
# 
