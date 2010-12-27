package debug;  # -*-perl-*-
use FileHandle;
use Data::Dumper;


use assert;
use Carp;

sub _options {
  my %ret = @_;
  my $once = 0;
  for my $v (grep { /^-/ } keys %ret) {
    require Carp;
    $once++ or Carp::carp("deprecated use of leading - for options");
    $ret{substr($v,1)} = $ret{$v};
  }

  $ret{control} = [ map { (ref($_) =~ /[^A-Z]/) ? $_->to_asn : $_ } 
		      ref($ret{control}) eq 'ARRAY'
			? @{$ret{control}}
			: $ret{control}
                  ]
    if exists $ret{control};

  \%ret;
}


sub _dn_options {
  unshift @_, 'dn' if @_ & 1;
  &_options;
}

sub setProperty {
    my $ref = shift;
    my ($prop, $val) = @_;

    $ref->{$prop} = $val;
#
# setPropertyCallback: the routine is called by the setProperty routine in perloo.m4.  It
# allows for custom extensions to that set property routine to be expressed in the supplied subroutine.
# Look in task.pm.m4 for an example of its use.
#
    if ($ref->{setPropertyCallback} && ref($ref->{setPropertyCallback}) =~ /CODE/) {
	$callback = $ref->{setPropertyCallback};
	&$callback ($ref, $prop, $val);
    }
}

sub setProperties {
    my $ref = shift;
    my $arg = &_dn_options;
    map {$ref->setProperty($_, $arg->{$_});} (keys (%{$arg}));
}
    

sub getProperty {
    my $ref = shift;
    my ($prop) = @_;

    return $ref->{$prop};
}

sub debugCmd {
    $ref = shift;
    my ($level, $cmd) = @_;
    eval ($cmd) if ($level <= $ref->{level});
}

sub debug {
    $ref = shift;
    
    my ($level, $data, $task_id) = @_;

    if ($level =~ m/$ref->{level}/ || $level <= $ref->{level}) {
        my ($caller) = (caller(1))[3];
        my ($line) = (caller(1))[2];
        $caller = "[$caller:$line]" if $caller;

	my $save = $\;
	$\ = "\n";
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$now = sprintf ("%2.2d/%2.2d/%02d-%2.2d:%2.2d:%2.2d",$mon+1,$mday,$year+1900,$hour,$min,$sec);
	my $logMsg = "";
	$logMsg .= $ref->{'prefix'} if defined $ref->{'prefix'};
	$logMsg .= "$now($$) $caller: $data";
	if ($ref->{logFH}) {
	    my $fh = $ref->{logFH};
	    print $fh $logMsg;
	    print $logMsg
		if $ref->{echo};
	} else {
	    print $logMsg;
	}
	if ($task_id) {
	    my $task = $task::allTasks{$task_id};
	    if ($task && $task->getProperty('taskLogFH')) {
		my $fh = $task->getProperty('taskLogFH');
		print $fh $logMsg;
	    }
	}
	$\ = $save;
    }
}


sub new {
    my $arg = &_dn_options;

    my $object = {};
    bless $object, "debug";
    
    map {$object->setProperty($_, $arg->{$_});} (keys (%{$arg}));

    if ($object->{logDir}) {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my $thisMonth = sprintf ("%4.4d%2.2d",$year+1900,$mon+1);
	
	my $newFile = "$object->{logDir}/$object->{logName}.$thisMonth.log";
	system ("mkdir -p $object->{logDir}") && confess "failed to create $object->{logDir}, check your -logDir setting or system permissions.";

	chmod 0644, $newFile;
	$object->{logFH} = new FileHandle;
	$object->{logFH}->autoflush(1);
	$object->{logFH}->open (">> $newFile") or 
	    die "cannot open log file $newFile";
    }

    return $object;
};

1;
