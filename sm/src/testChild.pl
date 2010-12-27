#!/usr/bin/perl

use Acme::JavaTrace;
use DBI;
use Getopt::Long;

$\="\n";

$username="$ENV{AutomationServerUser}";
$sid="$ENV{AutomationServerSID}";
$host="$ENV{AutomationServerHost}";
$port="$ENV{AutomationServerPort}";
$password="$ENV{AutomationServerPasswd}";

GetOptions("username:s" => \$username,
	   "sid:s" => \$sid,
	   "host:s" => \$host,
	   "port:i" => \$port,
	   "password:s" => \$password,
	   "dofail" => \$dofail);

#
# loads a SQL query into a hash.
#

sub slurp
{
    my ($DATA, $cursor) = @_;
    my @row;
    
    $DATA->{rows} = 0;
    for (my $i = 0; $i < $cursor->{NUM_OF_FIELDS}; $i++) {
	push (@{$DATA->{_fields}},$cursor->{NAME}->[$i]);
    }
    while (@row = $cursor->fetchrow_array()) {
	$DATA->{rows}++;
	for (my $i = 0; $i < $cursor->{NUM_OF_FIELDS} ; $i++) {
	    push (@{$DATA->{$cursor->{NAME}->[$i]}},$row[$i]);
	}
    }
    $cursor->finish;
}

sub loadSQL
{
    my ($sql, $DATA) = @_;
    
    my $stmt = $dbh->prepare($sql);
    $stmt->execute or die "ERROR: $DBI::errstr";
    slurp($DATA,$stmt) if $DATA;
    return $DATA;
}

sub runSQL {
    my ($sql) = @_;
    print $sql;
    $dbh->prepare($sql)->execute or die "ERROR: $DBI::errstr";
}

# 
# main() ....
#

die "failed to connect to dbi:Oracle:host=$host;sid=$sid;port=$port" 
    unless ($dbh = DBI->connect("dbi:Oracle:host=$host;sid=$sid;port=$port", "$username", "$password"));

die "set numChildren in the env" unless $ENV{numChildren};


runSQL("update task set status = 'waiting' where task_id = $ENV{task_id}");

for ($i = 0 ; $i < $ENV{numChildren} ; $i++) {
    if ((! $dofail) || ((int($i/2)*2) == (($i/2)*2))) {
	system ("./createTask.pl -task sleep -parent $ENV{task_id} -context sleepVal=5");
    } else {
	system ("./createTask.pl -task forceFailure -parent $ENV{task_id}");
    }

}

exit 0;


