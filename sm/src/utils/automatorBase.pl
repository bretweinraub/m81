
use DBI;

require "require.pl";

$username="$ENV{CONTROLLER_USER}";
$sid="$ENV{CONTROLLER_SID}";
$host="$ENV{CONTROLLER_HOST}";
$port="$ENV{CONTROLLER_PORT}";
$password="$ENV{CONTROLLER_PASSWD}";
$dbtype="$ENV{CONTROLLER_type}";

$task_id = $ENV{task_id};

if ($dbtype eq "oracle") {
    die "failed to connect to dbi:Oracle:host=$host;sid=$sid;port=$port" 
	unless ($dbh = DBI->connect("dbi:Oracle:host=$host;sid=$sid;port=$port", "$username", "$password",
				    { RaiseError => 1 }));

} elsif ($dbtype eq "Pg") {
    die "failed to connect to dbi:$dbtype:host=$host;database=$sid;port=$port" 
	unless ($dbh = DBI->connect("dbi:$dbtype:host=$host;database=$sid;port=$port", "$username", "$password",
				    { RaiseError => 1 }));
} else {
    confess "you haven't set a dbtype in you CONTROLLER_DBTYPE ... and that makes me mad";
}


