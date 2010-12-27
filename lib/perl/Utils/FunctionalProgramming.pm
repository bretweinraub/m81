package Utils::FunctionalProgramming;
use Data::Dumper;
use Carp;
use Exporter;
use Utils::ISAutil;

=pod

=head1 NAME

FunctionalProgramming.pm - Functions for working in a Functional Programming kind of way

=head1 DESCRIPTION

There is a collision that happens when moving between scripting and functional programming.
The most obvious case is looping over a list and processing elements as opposed to passing
the list to a block of processing code that manages the loop. This library exists to force
the programmer to realize that they are switching to a Functional Paradigm when they use
these functions. (And hopefully avoid some hard to find bugs.)

=cut

@ISA = qw( Exporter );
@EXPORT = qw( rmapcar getObjects getObjectsByKey atLeastOneObject getMDOPathDeriver getAllObjectsFromFile );

use vars qw( $VERSION );

$VERSION = '0.01';


=pod

=head1 FUNCTIONS

=head2 rmapcar

recursively apply a function to a list of objects.
REQUIRES THAT THE OBJECTS ARE HASH REFERENCES

give it a function: @array = function( \%hash );

your function can return an array, that array 
will be pushed onto a toplevel array
that is returned from the rmapcar() call.

Additionally, this function will keep track of the 
objects that it has recursed and only recurse them
once - This functionality is 'safe' - nested calls
to rmapcar will process all objects in their own
memory spaces.

=cut

my %_recursed_object_addresses;

sub rmapcar { 
    my $key = _create_memory();
    my @tmp = _rmapcar( $key, @_ );
    _clear_memory($key);
    return wantarray ? @tmp : $tmp[0];
}

sub _rmapcar {
    my $namespace = shift;
    my $code = shift;
    my @output = ();
    for my $obj (@_) {

        next if _have_recursed($namespace, $obj);

        ## CLOSURE CALL
        # brute force - get rid of null string scalars in results of the closure call!
        push @output, grep { ! /^\s*$/ } &{ $code }( $obj );

        #
        # In the metadata, everything is either an object (hash ref) or
        # an array of objects.
        #
        if ( ref($obj) eq 'ARRAY' ) {
            foreach my $arobj (@$obj) {
                push @output, _rmapcar( $namespace, $code, $arobj);
            }

        } elsif ( ref($obj) eq 'HASH' || 
                  ( ref($obj) !~ /(SCALAR|CODE|REF|GLOB|LVALUE)/ && ref($obj) =~ /\w+/ ) )  { # HASH or OBJECT (assume HASH ref)
            
            foreach my $key (keys %{$obj}) { # recurse on objects
                next if $suppress{$key};
                eval {
                    $_ = ref( $obj->{$key} );
                };
                carp "Caught $@ on dereferencing $key: ", Dumper($obj), "\n" if ($@);
 
                /ARRAY/ && do {
                    push @output, _rmapcar( $namespace, $code, @{ $obj->{$key} } );
                };

                /CODE/ && do {
                    push @output, _rmapcar( $namespace, $code, &{ $obj->{$key} } );
                };
                
                ! /(SCALAR|ARRAY|HASH|CODE|REF|GLOB|LVALUE)/ && /\w+/ && do { # An object
                    push @output, _rmapcar( $namespace, $code, $obj->{$key} );
                };
            }
        }
    }    
    return @output;
}

=pod

=head2 getObjects

C<@objs = getObjects($regexp, @list)>

Given a regexp, recursively match the TYPE of object against that regexp. Note that the
regexp will be placed between forward slashes like this: '/$regexp/'.

=cut

sub getObjects {
    my ($type, @list) = @_;
    return rmapcar( sub { 
	foreach $class (@{_isa(ref($_[0]))}) {
	    return $_[0] if $class =~ /$type/;
	}
    },
		    @list );
}


=pod

=head2 getObjectsByKey

C<@objs = getObjectsByKey( type => "Object Type",
                           key  => "The key to look for in Objects of $type",
                           match => "regex to match against found key's values",
                           list => \@list )>

    Example:

    my $boulderinstaller = getObjectsByKey (type => "StagingServer",
					    key => "host",
					    match => "boulderinstaller",
					    list => \@allObjects);

=cut

sub getObjectsByKey {
    my (%args) = @_;

    return unless $args{type} && $args{key} && $args{match} && $args{list};

    return (grep { $_->{$args{key}} =~ /$args{match}/ } 
            getObjects( $args{type}, $args{list} ));
}

=pod

=head2 atLeastOneObject

C<@objs = atLeastOneObject($regexp, $error_statement, @list)>

confess with $error_statement if no objects of type $regexp are matched recursively
in the @list. The $regexp will be inserted like this: /$regexp/;

=cut

sub atLeastOneObject {
    my ($regexp, $error_msg, @list) = @_;
    confess $error_msg unless getObjects( $regexp, @list );
}



sub _create_memory {
    return _randAlphaNum(16);
}

sub _clear_memory {
    my ($key) = @_;
    undef %{ $FunctionalProgramming::_recursed_object_addresses{$key} }; 
    delete $FunctionalProgramming::_recursed_object_addresses{$key}; 
}

sub _have_recursed {
    my ($namespace, $name) = @_;

## null name may be intended behavior
#
#     unless ($name) {
#         confess "Error in the namespace that you are trying to recurse - " .
#             "the thing that you are attempting to recurse is null.\nTechnically - that isn't possible!\n";
#     }

    return 1 if ($FunctionalProgramming::_recursed_object_addresses{$namespace}->{$name});

    $FunctionalProgramming::_recursed_object_addresses{$namespace}->{$name} = 1;
    return 0;
}

sub _randAlphaNum {
    my ($num) = @_;
    my $password = '';
    $num ||= 8;
    for (my $i = 0; $i < $num; $i++) { 

        $list =int(rand 3) + 1;
        if ($list == 1) {
            $char = int(rand 8)+49;
        }
        if ($list == 2){
            $char =int(rand 25)+65;
        }
        if ($list == 3) {
            $char =int(rand 25)+97;
        }
        $char = chr($char);
        $password .= $char;
    }
    return $password;
}


=pod

=head2 getMDOPathDeriver

If you use getObjects to get the name of an object and you want to get the value of a
variable in the current memory space where the name of the variable is:
 $<$object->name>_XXX, then you have to do something like eval(eval()). 

That is a difficult syntax to grasp, and it is hard to know what is happening internally
during processing of that command without knowing a lot of Perl (or more advanced usage of
'eval'). This provides a light wrapper around that functionality.

A note on implemenation. This differs from other functions that we have implemented
because it is a closure. It actually returns a function (a curried function) not an
object or a value. Because of this is uses a different Perl syntax. The syntax makes
it look like an object, but if you are debugging/troubleshooting, it might be
important to understand that it is not and object.

Use it like:

    my $domain_home_pather = getMDOPathDeriver('_domainhome_unix');
    my $path = $domain_home_pather->($host->{name});
    
    This will return the value of (for example):
    $usbohp360_1_domainhome_unix

A similar process/issue is when the script is inheriting the %ENV. In that 
case you could derive the ENV info with a:
    
    $ENV{ $host->{name} . '_domainhome_unix' }

However, if the variable is set in the local script and it didn't come 
from the environment, this process won't work.

There is a developer trade off here. Keep the maintenance costs in mind
when adding the additional generalizations that this fn provides.

=cut

sub getMDOPathDeriver {
    my $postfix = shift; 
    my $caller = (caller)[0]; # need to specify the variable in the running namespace, not the FP namespace.
    return sub { 
        my $prefix = shift; 
        my $command = '$' . $caller . '::' . eval(_tag2shell($prefix)) . _tag2shell($postfix) ;
        return eval $command;
    }
}

sub _tag2shell {
    my ($tag) = @_;
    $tag =~ s/-/_/g;
    $tag =~ s/\./_/g;
    return $tag;
}


=pod

=head2 getAllObjectsFromFile

Takes a filename and returns an ARRAY ref to @allObjects.

This is similar functionality to 'LoadCollections.pl'.

=cut

sub getAllObjectsFromFile {
    my ($file, $debug) = @_;
    if (ref $file) {
        confess "load_list should be called with static syntax: [\$list] = AbstractStructure::load_list( \$filename );";
    }
    my $f = undef;
    {
        local @allObjects;
        unless ($debug) {
            open OLDOUT,     ">&", \*STDOUT or die "Can't dup STDOUT: $!";
            open OLDERR,     ">&", \*STDERR or die "Can't dup STDERR: $!";
            
            open STDOUT, '>', "/dev/null" or die "Can't redirect STDOUT: $!";
            open STDERR, ">&STDOUT"     or die "Can't dup STDOUT: $!";
            
            require $file;
            
            open STDOUT, ">&OLDOUT"    or die "Can't dup OLDERR: $!";
            open STDERR, ">&OLDERR"    or die "Can't dup OLDERR: $!";
        } else {
            require $file;
        }
        $f = [ @allObjects ];
    }
    return $f;
}

1;
