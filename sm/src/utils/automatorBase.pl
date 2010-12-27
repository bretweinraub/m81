
use DBI;

require "require.pl";

$username="$ENV{CONTROLLER_USER}";
$sid="$ENV{CONTROLLER_SID}";
$host="$ENV{CONTROLLER_HOST}";
$port="$ENV{CONTROLLER_PORT}";
$password="$ENV{CONTROLLER_PASSWD}";

$task_id = $ENV{task_id};

die "failed to connect to dbi:Oracle:host=$host;sid=$sid;port=$port" 
    unless ($dbh = DBI->connect("dbi:Oracle:host=$host;sid=$sid;port=$port", "$username", "$password",
				{ RaiseError => 1 }));
