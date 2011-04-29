package dbutil;
use DBI;
use Carp;
#use Exporter;
#@ISA = qw( Exporter );
#@EXPORT = qw( slurp loadSQL runSQL );

sub slurp
{
    my ($DATA, $cursor, $verbose) = @_;
    my @row;
    
    $DATA->{rows} = 0;
    for (my $i = 0; $i < $cursor->{NUM_OF_FIELDS}; $i++) {
	push (@{$DATA->{_fields}},uc($cursor->{NAME}->[$i]));
	print STDERR uc($cursor->{NAME}->[$i]) . "\t" if $verbose;
    }
    print STDERR  "\n" if $verbose;
    while (@row = $cursor->fetchrow_array()) {
	$DATA->{rows}++;
	for (my $i = 0; $i < $cursor->{NUM_OF_FIELDS} ; $i++) {
	    push (@{$DATA->{uc($cursor->{NAME}->[$i])}},$row[$i]);
	    print STDERR  $row[$i] . "\t" if $verbose;
	}
	print STDERR  "\n" if $verbose;
    }
    $cursor->finish;
}



sub loadSQL
{
    my ($dbh, $sql, $DATA, $verbose) = @_;
    
    eval {
	my $stmt = $dbh->prepare($sql);
    };
    confess "$@" if $@;
    print STDERR ($sql . "\n") if $verbose;
    $stmt->execute
	or confess "ERROR: $DBI::errstr";
    slurp($DATA,$stmt,$verbose) if $DATA;
    return $DATA;
}

sub runSQL
{
    my ($dbh, $sql, $verbose) = @_;

    print STDERR ($sql . "\n") if $verbose;
    $dbh->prepare($sql)->execute 
	or confess "ERROR: $DBI::errstr";
}
1;
