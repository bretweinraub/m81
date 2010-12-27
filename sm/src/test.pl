#!/usr/bin/perl

# use Data::Dumper;
# use Proc::ProcessTable;

# my $p = new Proc::ProcessTable;

# $\="\n";

# print $$;
# my $thisp;
# foreach my $proc (@{$p->table}) {
#     if ($proc->{pid} =~ $$) {
# 	$thisp = $proc;
# 	break;
#     }
# }

# print Dumper($thisp);
# 

sub describe {
    my %hash = %{$_[0]};
    
    my $ret;

    foreach my $key (keys(%hash)) {
	$ret .= ($ret ? " " : "") . "$key=\"$hash{$key}\"" 
    }
    $ret;
}



my %ret = (
	   'this' => 'that',
	   '212' => 'xxxxx',
	   'numC' => 1,
	   'z' => [
		   '1' => '2',
		   ],
	   );


print describe(\%ret);


