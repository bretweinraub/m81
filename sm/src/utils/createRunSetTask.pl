#!/usr/bin/perl
# $m80path = [{ command => 'embedperl', chmod => '+x' }]
=pod

=head1 NAME

createRunSetTask.pl

=head1 DESCRIPTION

A command line interface to create runset and task information.

=head1 OPTIONS

=over

=item -name C<tag>

The name of the runset

=item -description C<tag>

The description of the runset

=item -url C<tag>

A url pointing to the description of this runset

=item @ARGV

pass through to the createTask.pl script

=back

=cut

use File::Basename;
use lib dirname($0);
use Carp;
use Getopt::Long;
use dbutil;
use Data::Dumper;
use Env;

$username="$CONTROLLER_USER";
$sid="$CONTROLLER_SID";
$host="$CONTROLLER_HOST";
$port="$CONTROLLER_PORT";
$password="$CONTROLLER_PASSWD";

my $contextAssignment = "=";
my $contextSeperator = ",";
$parent="NULL";

$status="new";

Getopt::Long::Configure( "pass_through" );
GetOptions("runSetName=s" => \$name,
           "taskName=s" => \$task,
	   "description:s" => \$description,
	   "url:s" => \$description_url,
	   "debug" => \$debug);

confess "Specify -runSetName" unless $name;
confess "Specify -taskName" unless $task;

# 
# main() ....
#

$\="\n";
$debug="true";


confess "failed to connect to dbi:Oracle:host=$host;sid=$sid;port=$port" 
    unless ($dbh = DBI->connect("dbi:Oracle:host=$host;sid=$sid;port=$port", "$username", "$password",
				{ RaiseError => 1,
				  AutoCommit => 0 }));

if ($description && $description_url) {
    dbutil::runSQL ($dbh, "insert into run_set (name, description, descriptionurl) values ('$name', '$description', '$description_url')", $debug);
  } elsif ($description_url) {
    dbutil::runSQL ($dbh, "insert into run_set (name, description, descriptionurl) values ('$name', null, '$description_url')", $debug);
  } elsif ($description) {
    dbutil::runSQL ($dbh, "insert into run_set (name, description, descriptionurl) values ('$name', '$description', null)", $debug);
  } else {
      dbutil::runSQL ($dbh, "insert into run_set (name, description, descriptionurl) values ('$name', null, null)", $debug);
}

$dbh->commit();
$dbh->disconnect();
#docmd('createTask.pl', "-task $taskName", @ARGV);
undef $name;
require "createTask.pl";

exit 0;


