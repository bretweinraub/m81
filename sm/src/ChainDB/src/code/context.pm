package context;
use Exporter;
@ISA = qw( Exporter );
@EXPORT = qw( genContextFromClause genContextWhereClause aliasName view genContextSelectContext);

use vars qw( $VERSION );

$VERSION = '0.01';

sub view
{
    use File::Basename;
    my $ret;
    
    $ENV{M80PATH_FILE} =~ s/\.\w+//g;
    $ret .= "CREATE OR REPLACE VIEW " . $ENV{M80PATH_FILE} . " AS\nselect";
}

sub aliasName
{
    my $name = shift;
    $name =~ s/^_+//;
    $name;
}

sub genContextSelectContext
{
    my $ret, $i = 0; 
    
    map {
	$ret .= ",\n" if $i++;
	$ret .= "\t" . aliasName($_) . ".value " . aliasName($_);
    } (@_);
    return $ret;
}

sub genContextFromClause
{
    my $ret, $i = 0; 
    
    map {
	$ret .= ",\n" if $i++;
	$ret .= "\ttask_context " . aliasName($_);
    } (@_);
    return $ret;
}

sub genContextWhereClause
{
    my $drivingTable = shift;

    my $ret, $i = 0;
    
    map {
	$ret .= "\nand" if $i++;
	$ret .= "\t$drivingTable.task_id = " . aliasName($_) . ".task_id(+)\n" ;
	$ret .= "and\t" . aliasName($_) . ".tag(+) = \'$_\'";
    } (@_);
    $ret;
}
	
1;
