package Utils::ContextInsensitiveHash;

use Carp;
use Data::Dumper;
use Term::ANSIColor qw(:constants);
use strict;
sub Confess (@) {confess BOLD, RED, @_, RESET}
sub Warn (@) { warn YELLOW, BOLD, ON_BLACK, @_, RESET }

use File::Basename;

sub printmsg (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$): @_.\n" ;
}

sub printmsgn (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$): @_\n" ;
}

sub TIEHASH {
    my $self = shift;

    my %hash;

    return bless \%hash, $self;
}

sub FETCH {
    my ($self,$key) = @_;
    $self->{lc($key)};
}

sub STORE {
    my ($self,$key, $value) = @_;
    $self->{lc($key)} = $value;
}

sub DELETE {
    my ($self,$key) = @_;
    delete $self->{lc($key)};
}


sub CLEAR {
    my ($self) = @_;

    foreach my $key ( keys %{$self}) {
	$self->DELETE($key);
    }    
}

sub EXISTS   {
    my $self = shift;
    my $key = shift;
    return exists $self->{lc($key)};
}

sub FIRSTKEY {
    my $self = shift;
    my $a = keys %{$self};		# reset each() iterator
    each %{$self}
}

sub NEXTKEY  {
    my $self = shift;
    return each %{ $self }
}

sub SCALAR {
    my $self = shift;
    return scalar %{ $self }
}

1;
