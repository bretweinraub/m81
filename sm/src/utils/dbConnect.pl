use DBI;
use Env;
use dbutil;

my $username="$CONTROLLER_USER";
my $sid="$CONTROLLER_SID";
my $host="$CONTROLLER_HOST";
my $port="$CONTROLLER_PORT";
my $password="$CONTROLLER_PASSWD";

die "failed to connect to dbi:Oracle:host=$host;sid=$sid;port=$port" 
    unless ($dbh = DBI->connect("dbi:Oracle:host=$host;sid=$sid;port=$port", "$username", "$password",
				{ RaiseError => 1 }));

