
package assert;
use Carp;


sub assert {
    my ($msg, $val) = @_;
    confess "an assertion failed: $msg" if (! $val);
}


1;
