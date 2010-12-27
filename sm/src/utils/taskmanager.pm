package taskmanager;

use File::Basename;
use lib dirname($0);
use Acme::JavaTrace;
use Getopt::Long;
use dbutil;
use Data::Dumper;
use Env;
use Carp;

$username="$CONTROLLER_USER";
$sid="$CONTROLLER_SID";
$host="$CONTROLLER_HOST";
$port="$CONTROLLER_PORT";
$password="$CONTROLLER_PASSWD";

sub new {
    my ($class, %args) = @_;
    my $name = ref($class) || $class;
    my $self = bless \%args, ref($class) || $class;

    confess "failed to connect to dbi:Oracle:host=$host;sid=$sid;port=$port" 
	unless ($self->{dbh} = DBI->connect("dbi:Oracle:host=$host;sid=$sid;port=$port", "$username", "$password",
				    { RaiseError => 1,
				      AutoCommit => 0 }));

    return $self;
}

sub createTask {
    my $self = shift;
    my %args = @_;

    my $dbh = $self->{dbh};
    my $task = $args{name};
    my $status = $args{status};
    my $parent = $args{parent};
    my $debug = $args{debug};
    my %task;

    $date=`date +%Y%m%d%H%M%S.%N`;

    dbutil::runSQL 
	($dbh, 
	 "insert into task (task_name, taskname, status, parent_task_id, mapper) values ('$date', '$task', '$status', " . ($parent ? $parent : "NULL") . ", " . 
	 ($mapper ? "'$mapper')" : "NULL)"),
	 $debug);

    dbutil::loadSQL ($dbh, "select task_id from task where taskname = '$task' and task_name = '$date'", \%task, $debug);
    $task{TASK_ID}[0];
}

sub DESTROY {
    my $self = shift;

    $self->{dbh}->disconnect if $self->{dbh};

}

1;
