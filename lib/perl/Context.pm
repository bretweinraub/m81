
package Context;

use URI::Escape;
use Storable qw( dclone );
use MIME::Base64;
use Exporter;
use Data::Dumper;
use Carp;
use FunctionalProgramming;
use CGI;

@ISA = qw( Exporter );
$Data::Dumper::Purity = 1;
$Data::Dumper::Indent = 0;
$Data::Dumper::Terse  = 1;

sub new {
    my ($class, %args) = @_;
    $args{_obj} = {};
    my $name = ref($class) || $class;
    return bless \%args, $name;
}


sub prop {
    my ($this, $prop, $val) = @_;
    if ( defined $val ) {
	$this->{$prop} = $val;
        return $val;
    } elsif ( defined $prop ) {
	return $this->{$prop};
    }
}

#
# CREATE the elem_<attribute>, push_<attribute>, merge_<attribute>, pop_<attrib>, delete_<attrib> functions on 
# the fly. This isn't general enough, but it works today. Next step is to integrate Fn recursion into the pattern
# and write some kind of Query language that uses it. xpath? regexp?
#
# ALSO CREATE getX, get_X, setX, set_X, X([arg]) functions that allow access to the fields of this object on the fly.
#
sub AUTOLOAD {
    my $self = shift;
    my $memoize = 0;
    if ($AUTOLOAD =~ /^.*::elem_(\w+)/i) { # $self->{_obj} access routines
        my $attribute = $1;
        *{$AUTOLOAD} = sub { 
            my ($_self, $v) = @_;
            if ($v) { 
                if (ref $v eq 'ARRAY') {
                    $_self->{_obj}->{$attribute} = $v; return $v;
                } else {
                    $_self->{_obj}->{$attribute} = [$v]; return $v;
                }
            } else {
                if (exists $_self->{_obj}->{$attribute}) {
                    return @{ $_self->{_obj}->{$attribute} };
                } else {
                    return undef;
                }
            } 
        };
        $memoize = 1;
    }
    elsif ($AUTOLOAD =~ /^.*::push_(\w+)/i) { # $self->{_obj} PUSH based access routines
        my $attribute = $1;
        *{$AUTOLOAD} = sub { 
            my $_self = shift;
            push @{ $_self->{_obj}->{$attribute} }, @_; 
            return $_self->{_obj}->{$attribute};
        };
        $memoize = 1;
    }
    elsif ($AUTOLOAD =~ /^.*::merge_(\w+)/i) { # $self->{_obj} MERGE (which is based on PUSH) based access routines
        my $attribute = $1;
        *{$AUTOLOAD} = sub { 
            my $_self = shift;
            for my $x (@_) {
                if (ref $x eq 'HASH') {
                    my ($k) = keys %$x; # single key support only { k => v } or { k => [ v1, v2 ] }
                    if (exists $_self->{_obj}->{$attribute}) {
                        my $found = 0;
                        for (my $i = 0; $i < scalar @{ $_self->{_obj}->{$attribute} }; $i++) {
                            if (exists $_self->{_obj}->{$attribute}->[$i]->{$k}) {
                                $_self->{_obj}->{$attribute}->[$i] = $x;
                                $found++;
                                print STDERR "x is a hash " . Dumper($x) . " with key: $k , checking existence: " , $_self->{_obj}->{$attribute}->[$i]->{$k}, " merged\n";
                            }
                        }
                        push @{ $_self->{_obj}->{$attribute} }, $x unless $found;
                    } else {
                        $_self->{_obj}->{$attribute} = [$x];
                    }
                } else { # Assume scalar
                    if ($_self->{_obj}->{$attribute}) {
                        my $found = 0;
                        for (my $i = 0; $i < scalar @{ $_self->{_obj}->{$attribute} }; $i++) {
                            $found++ if ($_self->{_obj}->{$attribute}->[$i] eq $x);
                        }
                        push @{ $_self->{_obj}->{$attribute} }, $x unless $found;
                    } else {
                        $_self->{_obj}->{$attribute} = [$x];
                    }
                }
            }
            return $_self->{_obj}->{$attribute};
        };
        $memoize = 1;
    }
    elsif ($AUTOLOAD =~ /^.*::pop_(\w+)/i) { # $self->{_obj} POP based access routines
        my $attribute = $1;
        *{$AUTOLOAD} = sub { 
            my ($_self) = @_;
            return pop @{ $_self->{_obj}->{$attribute} }; 
        };
        $memoize = 1;
    }
    elsif ($AUTOLOAD =~ /^.*::delete_(\w+)/i) { # $self->{_obj} DELETE routines
        my $attribute = $1;
        *{$AUTOLOAD} = sub { 
            my $_self = shift;
            if (scalar @_) {
                for my $k (@_) {
                    for (my $i = 0; $i < scalar @{ $_self->{_obj}->{$attribute} }; $i++) {                
                        if (exists $_self->{_obj}->{$attribute}->[$i]->{$k}) {
                            delete $_self->{_obj}->{$attribute}->[$i];
                        }
                    }
                }
            } else {
                return delete $_self->{_obj}->{$attribute}; 
            }
        };
        $memoize = 1;
    }


    elsif ($AUTOLOAD =~ /^.*::(get|set)*_*(\w+)/i) { # $self access routines
        my ($op, $attribute) = ($1, $2);
        
        if (lc $op eq 'set') {
            *{$AUTOLOAD} = sub { $_[0]->{$attribute} = @_ ; return $_[0]->{$attribute} };
            $memoize = 1;
        } elsif ( lc $op eq 'get') {
            *{$AUTOLOAD} = sub { $_[0]->{$attribute} };
            $memoize = 1;
        } else {
            *{$AUTOLOAD} = sub { 
                my ($_self, $v) = @_;
                if ($v) { 
                    $_self->{$attribute} = $v; return $v;
                } else {
                    return $_self->{$attribute};
                } 
            };
            $memoize = 1;
        }
    }  
  
    if ($memoize) {
        &{ $AUTOLOAD }($self, @_);
    } else {
        confess __PACKAGE__ . " is not sure what to do with the fn $AUTOLOAD\n";
    }
}


sub serialize { 
    my ($self) = @_;
    my $s = Dumper( $self->prop(_obj) );
    chomp $s;
    $s = encode_base64( $s );
    chomp $s;
    return "_o=" . uri_escape( $s );
}

sub deserialize {
    my ($self) = @_;

    return if $self->deserialized();

    my $o = decode_base64($self->CGI()->param('_o'));
#    print STDERR "_o is $o\n";
    my $tmp = eval $o;
#    print STDERR "deserialize tmp is: " , Dumper($tmp), "\n";
    if ($tmp) {
        $self->prop( _obj, $tmp );
    } else {
        $self->prop( _obj, {} );
    }
    $self->deserialized(1);
    return $self;
}

sub clone { return dclone($_[0]) }

1;
