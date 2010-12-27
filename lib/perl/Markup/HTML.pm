package Markup::HTML;

use Env;
use Exporter;
use Carp;
use Data::Dumper;
use Markup::Base;

@ISA = qw( Markup::Base );

sub _useful_param {
    my ($cgi) = @_;
    
    my $o = '';
    my @do_not_pass_these_params = qw( _o );
    for $p ($cgi->param) {
        unless ( grep { /$p/ } @do_not_pass_these_params ) {
            $o .= '&' if $o;
            $o .= $p . '=' . $cgi->param($p);
        }
    }
    return $o;
}

sub _append_qs {
    my ($url, $s) = @_;
    $url =~ s/\&$//;
    if ($url =~ /\&/) {
        return $url . '&' . $s;
    } elsif ($url =~ /\?/) {
        if ($url =~ /\?$/) {
            return $url . $s;
        } else {
            return $url . '&' . $s;
        }
    } else {
        return '?' . $s;
    }
}

sub tableHeader {
    my ($self, %data) = @_;
    my $title = $data{title};

    $title =~ s/\'//g;
    return "
<table border='1' width='90%' align='center' summary='$title'>
";
}

sub headerCell {
    my ($self, %data) = @_;

    my $qs = '?' . _useful_param($self->CGI);

    my $sort_up = $self->context()->clone(); $sort_up->merge_s( { $data{data} => asc } ); 
    my $sort_dwn = $self->context()->clone(); $sort_dwn->merge_s( { $data{data} => desc } ); 
    my $sort_del = $self->context()->clone(); $sort_del->delete_s( $data{data} ); 

    $ret = "
    <th><table border=0><tr><th>
      $data{data}</th></tr>
      <tr><td>";

    $ret .= "<a href=$SCRIPT_NAME" . _append_qs( $qs, $sort_up->serialize()  ) . ">up</a>\n";
    $ret .= "<a href=$SCRIPT_NAME" . _append_qs( $qs, $sort_dwn->serialize() ) . ">dwn</a>\n";
    $ret .= "<a href=$SCRIPT_NAME" . _append_qs( $qs, $sort_del->serialize() ) . ">x</a>\n";

    $ret .= "</td></tr>
      </table>
    </th>
";
}

sub rowFooter {
    my ($self, %data) = @_;

    return "
  </tr>
";

}

sub tableFooter {
    my ($self, %data) = @_;

    return "
</table>
";
}


sub rowHeader {
    my ($self, %data) = @_;
    
    my $bgcolor = ($self->bgcolor ? $self->bgcolor : '#EFEFEF');
    my $row = $data{row};

    my $bg = ((($row % 2) > 0)  ? " bgcolor=\"$bgcolor\"" : " ") ;

    return "
  <tr$bg>
";
}

sub tableItem {
    my ($self, %data) = @_;

    my $format = $self->format;
    my $field = $data{field};
    my $result = $data{data};
    my $row = $data{row};
    my $rowset = $self->slurp;

    foreach $_format (@{$format}) {
	if (lc $field eq lc $_format->{field}) {
            
            if (lc $_format->{type} eq 'sprintf' || ! $_format->{type}) {  # backwards compat:
                $result = sprintf( $_format->{format}, $result );


            } else { # everything else is just code now.
                if (ref $_format->{function} eq 'CODE') { # a single function
                    $result = $_format->{function}->( celldata => $result,
                                                      row => $row,
                                                      field => $field,
                                                      rowset => $rowset );
                } elsif (ref $_format->{function} eq 'ARRAY') { # an array of functions
                    for $fn (@{ $_format->{function} }) {
                        $result = $fn->( celldata => $result,
                                         row => $row,
                                         field => $field,
                                         rowset => $rowset );
                    }
                }
            }
        }
    }

    "
    <td>
      $result
    </td>
";
}

1;
