package xmlhelper;   # -*-perl-*-

m4_include(./perloo.m4)m4_dnl

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
