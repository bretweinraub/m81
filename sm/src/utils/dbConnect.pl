use DBI;
use Env;
use dbutil;

my $username="$CONTROLLER_USER";
my $sid="$CONTROLLER_SID";
my $host="$CONTROLLER_HOST";
my $port="$CONTROLLER_PORT";
my $password="$CONTROLLER_PASSWD";
my $dbtype="$CONTROLLER_DBTYPE";

if ($dbtype == "Oracle") {
    die "failed to connect to dbi:$dbtype:host=$host;sid=$sid;port=$port" 
	unless ($dbh = DBI->connect("dbi:$dbtype:host=$host;sid=$sid;port=$port", "$username", "$password",
				    { RaiseError => 1 }));

} elsif ($dbtype == "Pg") {
    die "failed to connect to dbi:$dbtype:host=$host;database=$sid;port=$port" 
	unless ($dbh = DBI->connect("dbi:$dbtype:host=$host;database=$sid;port=$port", "$username", "$password",
				    { RaiseError => 1 }));
} else {
    confess "you haven't set a dbtype in you CONTROLLER_DBTYPE ... and that makes me mad";
}
