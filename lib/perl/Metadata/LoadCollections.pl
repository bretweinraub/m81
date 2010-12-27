use File::Basename;
use Env;

sub printmsg (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$) @_.\n" ;
}

sub docmd (@) {    
    printmsg "@_" ;
    system(@_);

    my $rc;
    if ($? == -1) {
        $rc = -1; printmsg "failed to execute: $!";
    }
    elsif ($? & 127) {
        $rc = $? & 127;
        printmsg "child process died with signal $rc, ", ($? & 128) ? 'with' : 'without', " coredump";
    }
    else {
        $rc = $? >> 8;
        if ($rc) {
            printmsg "child process exited with value $rc - Exiting!";
            exit $rc;
        }
    }
}

sub debugPrint_ ($@) { 
    my $level = shift;
    if ($debug >= $level) {
        my ($caller) = (caller(1))[3];
        $caller = "[$caller]:" if $caller;
        my $date = localtime;
        print STDERR $caller . $date . ":" . basename($0) . ":($$): @_.\n" ;
    }
}

#
# backup scripts if they us the "_collections" syntax.
#
printmsg "In required script LoadCollections.pl";
printmsg "collections is $collections";
printmsg "_collections is $_collections";
unless ($collections && -f $collections) {
    if ($_collections) {
	$archiveDir="$AUTOMATOR_STAGE_DIR/collections";
	docmd ("mkdir -p $archiveDir");
	my $new;
	foreach $coll (split (/,/,$_collections)) {
	    docmd("cp -p $coll $archiveDir");
	    $new .= "," if $new;
	    $new .= "$archiveDir/" . basename($coll);
	}
	docmd ("createContext.pl -tag collections -value $new -task_id $task_id");
	$collections = $new;
    }
}

foreach (split (/,/,$collections)) {
    unless ($ENV{DEBUG}) {
# 	open OLDOUT,     ">&", \*STDOUT or die "Can't dup STDOUT: $!";
# 	open OLDERR,     ">&", \*STDERR or die "Can't dup STDERR: $!";

# 	open STDOUT, '>', "/dev/null" or die "Can't redirect STDOUT: $!";
# 	open STDERR, ">&STDOUT"     or die "Can't dup STDOUT: $!";

 	debugPrint_(0, "LoadCollections loading script $_");
	require $_;

# 	open STDOUT, ">&OLDOUT"    or die "Can't dup OLDERR: $!";
# 	open STDERR, ">&OLDERR"    or die "Can't dup OLDERR: $!";
    } else {
	require $_;
    }
}

1;
