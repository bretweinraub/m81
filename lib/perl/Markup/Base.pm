#
#
#

package Markup::Base;

use Exporter;
use Carp;
use Data::Dumper;
use DBI;
use dbutil;

@ISA = qw( Exporter );

sub new {
    my ($class, %args) = @_;
    my $name = ref($class) || $class;
    my $self =  bless \%args, $name;
    $self->context()->deserialize() if $self->context;
    return $self;
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

sub AUTOLOAD {
    my $self = shift;
    my $memoize = 0;
    $AUTOLOAD =~ /^.*::(get|set)*_*(\w+)/i;
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
    if ($memoize) {
        &{ $AUTOLOAD }($self, @_);
    } else {
        confess "Markup::Base is not sure what to do with the fn $AUTOLOAD\n";
    }
}

sub tableHeader { confess "tableHeader is an abstract function - use a derived class\n" }
sub tableFooter { confess "tableFooter is an abstract function - use a derived class\n" }
sub headerCell { confess "headerCell is an abstract function - use a derived class\n" }
# AKA cell
sub tableItem { confess "tableItem is an abstract function - use a derived class\n" }
sub rowHeader { confess "rowHeader is an abstract function - use a derived class\n" }
sub rowFooter { confess "rowFooter is an abstract function - use a derived class\n" }


sub table { 
    my ($self, %data) = @_;
    return $self->tableHeader(%data) . $data{data} . $self->tableFooter(%data);
}

sub row { 
    my ($self, %data) = @_;
    return $self->rowHeader(%data) . $data{data} . $self->rowFooter(%data);
}

sub cell { return $self->tableItem(@_) }

sub markup {
    my ($self) = @_;

    my $ret = "";

    my %results = %{$self->slurp};
    my @fields = @{$results{_fields}};
    my $rows = $results{rows};

    # debugging
    $ret .= "<!-- \n" . $self->title . "\n-->\n";
    $ret .= "<pre>" . $self->title . "</pre>\n" if $::DEBUG;


    $ret .= $self->tableHeader(title => $self->title);
    $ret .= $self->rowHeader();

    # header fields
    for my $field (@fields) {
	$ret .= $self->headerCell(data => $field);
    }

    $ret .= $self->rowFooter();
    
    # body field data
    for (my $i = 0 ; $i < $rows ; $i++) {
	$ret .= $self->rowHeader(row => $i);
	for my $field (@fields) {
	    $ret .= $self->tableItem( row => $i,
                                      data => $results{$field}[$i],
                                      field => $field );
	}
	$ret .= $self->rowFooter();
    }

    $ret .= $self->tableFooter();
    return $ret;
}

=pod

=over 4

=item createDBConnection

Returns the current database handle.  Creates it if it doesn't already exists.

=back

=cut


sub createDBConnection {
    my ($self) = @_;

    my $dbh = $self->prop(dbh);

    unless ($dbh) {
	my $host = $self->prop(host);
	my $SID = $self->prop(SID);
	my $port = $self->prop(port);
	my $user = $self->prop(user);
	my $password = $self->prop(password);

        die "failed to connect to oracle"
            unless ($dbh = DBI->connect("dbi:Oracle:host=$host;sid=$SID;port=$port", $user, $password,
                                        { RaiseError => 1 }));
    }

    return $dbh;
}

sub loadRowSet {
    my ($self) = @_;

    my $dbh = $self->GetConnection();
    my $sql = $self->prop(sql);
    my $debug = $self->prop(debug);

    confess "no database handle" unless $dbh;
    confess "no sql statement" unless $sql;

    #
    # sort changes the SQL statement order by clause
    #

    print STDERR Dumper($self), "\n" if $debug;

#
# elem_s() returns the "sort" attribute from the context.
#

    my $sortContext = $self->context()->elem_s();

    if ($sortContext) {
        # strip whatever was there... - it will be built from the object now
        $sql =~ s/order\s+by\s+.+$//;

        $sql .= ' order by ';

        my $field_appended = 0;
        for my $order_by_field ($sortContext) {
            next unless ref $order_by_field eq 'HASH'; # ASSERT
            my ($field, $sort_order) = each %$order_by_field;
            next unless $field && $sort_order;
            $sql .= ', ' if $field_appended;
            $sql .= "$field $sort_order";
            $field_appended++;
        }
    }
    
    my $results = {};
    dbutil::loadSQL($dbh, $sql, $results);
 
    $self->title($sql);
    $self->slurp($results);
}


sub grid {
    my ($self) = @_;
    $self->loadRowSet();
    return $self->markup();
}

1;
