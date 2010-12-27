package Utils::ISAutil;

use Exporter;
@ISA = qw( Exporter );
@EXPORT = qw( _isa _isa_regexp check_isa);

%cache = ();

sub __isa {
    my ($class) = @_;
    my (@classes, @tmpclasses);

    eval "\@classes = \@$class" . "::ISA";
    @tmpclasses = @classes;

    map { push (@classes, @{__isa($_)}) if __isa($_)} (@tmpclasses);
    \@classes
}

sub _isa {
    my ($class) = @_;
    return $cache{$class} if $cache{$class};

    my @classes;

    @classes = @{__isa($class)};
    unshift (@classes, $class);
    $cache{$class} = \@classes;
    \@classes
}

sub _isa_regexp {
    my ($regexp, $obj) = @_;
    my @tmp = @{ _isa(ref($obj)) };
    return grep { /$regexp/ } @tmp;
}

sub check_isa {
    my ($obj, $check) = @_;
    return grep { /^$check$/ } @{_isa(ref($obj))};
}

1;
