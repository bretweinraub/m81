package xmlhelper;   # -*-perl-*-


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

use XML::Simple;

sub new {
    my $arg = &_dn_options;

    my $object = {};

    bless $object, "xmlhelper";
    
    map {$object->setProperty($_, $arg->{$_});} (keys (%{$arg}));

#
# Cache the last modified date of the XML file so we can reload it if we need to(or exit).
#
    $object->setProperty('WRITETIME', (stat($object->{configFile}))[9]);
#
# Do m80 expansions if a .m80 file .... don't hate me because I don't like to code!
#
    if ($object->{configFile} =~ m/\.m80$/) {
	my $data = `runPath -file $object->{configFile}`;
	print $data if $object->{dumpxml};
	$object->setProperty('xml', XMLin($data, "ForceArray"=>1, "KeyAttr"=>[]));
    } else {
	$object->setProperty('xml', XMLin($object->{configFile}, "ForceArray"=>1, "KeyAttr"=>[]));
    }

    return $object;
};


1;
