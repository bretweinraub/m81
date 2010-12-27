sub _require
{
    map { 
	eval "\$derive = sprintf(\"%s\", \$$_)";
	die "set -$_" unless $derive;
    } (@_);
}

1;
