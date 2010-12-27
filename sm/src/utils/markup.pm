#
#
#

package markup;

use Exporter;
use Carp;
use Data::Dumper;

@ISA = qw( Exporter );
@EXPORT = qw( grid markup );

sub prop {
    my ($this, $prop, $val) = @_;

    if ( defined($val) ) {
	$this->setProperty( $prop, $val ) ;
    } elsif ( $prop ) {
	return $this->getProperty( $prop );
    }
}


=pod

=over 4

=item getProperty ($tag)

$this->getProperty(tag);

Returns the value of "tag" for the object.

=back

=cut


sub getProperty {
    my ($this, $prop) = @_;

    return $this->{$prop} if $this->{$prop};
}


=pod

=item setProperty ($tag, $value)

$this->setProperty('tag','value');

Basic "setter" method.  If the 'tag' portion of the call is not found with associated documentation in ObjectDocumentation.pl,
a fatal error is thrown.

=back

=cut


sub setProperty {
    my ($this, $prop, $val) = @_;
 
    my $found;
    foreach my $class (@{_isa(ref($this))}) {
	do {
	    $found=1;
	    last;
	} if $ObjectDocs{$class}{$prop};
    }
    
    confess "property '$prop' (" . join (",", @{_isa(ref($this))}) . ") does not have a definition in %ObjectDocs" unless $found;
    $this->{$prop} = $val;
}

sub new {
    my ($class, %args) = @_;

    my $name = ref($class) || $class;
    my $self = bless \%args, ref($class) || $class;

    return $self;
}

sub tableHeader {
    my %data = @_;
    my $title = $data{title};

    $title =~ s/\'//g;
    return "
<table border='1' width='90%' align='center' summary='$title'>
";
}

sub headerCell {
    my %data = @_;

    return "
    <td>
      <b>$data{data}</b>
    </td>
";
}

sub rowFooter {
    my %data = @_;

    return "
  </tr>
";

}

sub tableFooter {
    my %data = @_;

    return "
</table>
";
}


sub rowHeader {
    my %data = @_;
    my $row = $data{row};

    my $bg= ((($row % 2) > 0)  ? ' bgcolor="EFEFEF"' : " ") ;

    return "
  <tr$bg>
";
}

sub tableItem {
    my %data = @_;

    my $format = $data{format};
    my $field = $data{field};
    my $result = $data{data};
    my $row = $data{row};
    my $rowset = $data{rowset};

    foreach $_format (@{$format}) {
	if ($field =~ $_format->{field}) {
	    if ($_format->{type} =~ /func/) {
		$result = &{$_format->{function}}(celldata => $result, 
						  row => $row, 
						  field => $field,
						  rowset => $rowset);
	    } else { # sprintf
		$result = sprintf ($_format->{format}, $result);
		last;
	    }
	}
    }

    "
    <td $bg>
      $result
    </td>
";
}

%markupFunctions = (
		    tableHeader => \&tableHeader,
		    headerCell => \&headerCell,
		    rowFooter => \&rowFooter,
		    rowHeader => \&rowHeader,
		    tableItem => \&tableItem,
		    tableFooter => \&tableFooter,
		    );

sub markup {
    my $this = shift;
    my %data = @_;
    my $ret = "";

    my %results = %{$data{slurp}};
    my @fields = @{$results{_fields}};
    my $rows = $results{rows};

    my %_markupFunctions = ($data{markupFunctions} ? %{$data{markupFunctions}} : %markupFunctions);

    $ret .= &{$_markupFunctions{tableHeader}}(title => $data{title});

    $ret .= &{$_markupFunctions{rowHeader}};

    foreach my $_x (@fields) {
	my $tmp = $_x;
	$tmp =~ s/_/ /g;
	$ret .= &{$_markupFunctions{headerCell}}(data => $tmp);
    }

    $ret .= &{$_markupFunctions{rowFooter}}();
    
    for (my $i = 0 ; $i < $rows ; $i++) {
	$ret .= &{$_markupFunctions{rowHeader}}(row => $i);
	foreach $f (@fields) {
	    $ret .= &{$_markupFunctions{tableItem}}(row => $i,
						    data => $results{$f}[$i],
						    rowset => \%results,
						    field => $f,
						    format => $data{format});
	}
	$ret .= &{$_markupFunctions{rowFooter}}();
    }

    $ret .= &{$_markupFunctions{tableFooter}}();
    $ret;
}

sub grid {
    my $this = shift;

    my %data = @_;
    my $sql = $data{sql};
    my $dbh = $data{dbh};

    confess "no database handle" unless $dbh;
    confess "no sql statement" unless $sql;
    
    my %results = ();
    dbutil::loadSQL($dbh, $sql,\%results);

    return $this->markup(slurp => \%results,
			 title => $sql,
			 format => $data{format});
}

1;
