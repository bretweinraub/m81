

=pod

=head1 NAME - Template::SimpleTextArchive

Bundle several files into a single archive, but do it in plain text.

Designed to be used with a runPath or some templating engine. Since both the filenames
and file contents are available in plain text it is easy to turn these archives into 
complex templates. 

This acts a lot like tar, you can point it at a directory and it will pull all the files
in that archive together into a single ArchiveFile. The big difference from tar is that it 
is all ascii based, so you are free to edit the ArchiveFile in plain text.

The archive file can be made to have a '$m80path' directive in the file (and SHOULD have one if
the archive contains other embedded m80 templates - that define their own '$m80path' directive.)
In addition to the individual file's contents being available in plain text, the file NAME is
also available in plain text. This means that you can change the output file easily by templating
the archive (with an '$m80path' variable) and expanding a filename.

The file meta-information is saved in a string that looks like the following:

        <!-- FILE|$file|$mode[|DoNotOverride] -->

Where $file is the filename relative to the $SimpleTextArchive->getRootDirectory(), the mode is
something like 644, or 755 and is determined at the time of the creation of the Archive. The 
DoNotOverride flag is optional and specifies what to do if the file already exists in the extraction
directory. If it exists and is set to '1' then the file will overwrite an existing file during
the extract phase. THE DEFAULT IS TO OVERWRITE EXISTING FILES.



=head1 EXAMPLE

No example(s) have been documented for this object.

=cut

# This file was automatically generated from SimpleTextArchive.pm.m80 by 
# bret on ubuntu (Linux ubuntu 2.6.31-19-generic-pae #56-Ubuntu SMP Thu Jan 28 02:29:51 UTC 2010 i686 GNU/Linux)
# DO NOT EDIT THIS FILE 


package Template::SimpleTextArchive;

use Carp;
use Data::Dumper;
use Term::ANSIColor qw(:constants);
use strict;
sub Confess (@) {confess BOLD, RED, @_, RESET}
sub Warn (@) { warn YELLOW, BOLD, ON_BLACK, @_, RESET }

use File::Basename;

sub printmsg (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$): @_.\n" ;
}

sub printmsgn (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$): @_\n" ;
}

use File::Basename;
use fields qw( debug rootDirectory archiveFile defaultRunPathHeader verbose );

=pod

=head1 CONSTRUCTOR

=over 4

=item Template::SimpleTextArchive->new()

initializes on object of type Template::SimpleTextArchive

=back

=cut


# %_allSetters - an array of all setters for all members of the class
my %_allSetters = ();

my %_allMemberAttributes = ();

BEGIN {
# $_allMembers{_TYPE} = 1; # - WHAT IS THIS FOR?
$_allMemberAttributes{debug} = {
          'name' => 'debug',
          'description' => 'turn on debugging output'
        }
;
$_allSetters{debug} = \&setDebug;
$_allMemberAttributes{rootDirectory} = {
          'name' => 'rootDirectory',
          'description' => 'The directory that is the root of the created ArchiveFile'
        }
;
$_allSetters{rootDirectory} = \&setRootDirectory;
$_allMemberAttributes{archiveFile} = {
          'name' => 'archiveFile',
          'description' => 'The name/location of the archive file'
        }
;
$_allSetters{archiveFile} = \&setArchiveFile;
$_allMemberAttributes{defaultRunPathHeader} = {
          'name' => 'defaultRunPathHeader',
          'description' => 'write a default runPath header into the template file'
        }
;
$_allSetters{defaultRunPathHeader} = \&setDefaultRunPathHeader;
$_allMemberAttributes{verbose} = {
          'name' => 'verbose',
          'description' => 'Print verbose output'
        }
;
$_allSetters{verbose} = \&setVerbose;


}

#
# TODO ... needs to merge in the parents attributes; the commented out block is close.
#
sub getReflectionAPI { 
#     my $this = shift; 
#     my %unified = (%{$this->SUPER::getReflectionAPI()}, %_allMemberAttributes);
#     \%unified;
    \%_allMemberAttributes;
}

#
# For some (currently) mysterious reason on perl 5.8.8 on the Linux kernel 2.6.18-8.1.14.el5 there
# is no data in the %_allMemberAttributes.  Therefore here is another way to get a list of member data
# out of the class.
#

sub getMembers {
    my $this = shift;
    my @ret = keys(%{$this});
    \@ret;
}
    
sub new {
    my Template::SimpleTextArchive $this = shift;

    print STDERR "in Template::SimpleTextArchive::new(" . join (",", @_) . ")\n" if $ENV{DEBUG};
    Confess "Missing the value for an argument (even nulls) on creation of Template::SimpleTextArchive" if scalar @_ % 2 != 0;

    my %args = @_;

    unless (ref $this) {
	$this = fields::new($this);
    }

    #
    # This next block tries to set any of the values that you passed into this
    # constructor. You might have said new X( arg1 => 123, arg2 => 456); It is going
    # to take that and try to call setArg1(123), setArg2(123). I.e. it is going
    # to derive the setter for your named argument (by upper casing the first letter
    # of your argument name) and then if it finds that the object can call the
    # setter (i.e. it is defined in this class or any parent class) it will call it.
    #
    # If the setter cannot be found - then assume that this is a bad argument
    # that was passed to the function and die with that information.
    #
    foreach my $key (keys(%args)) {

        my $setterName = $key;                              # workspace for determining the name of the setter
        $setterName =~ s/^(\w)/uc($1)/e;                    # uc the first char of the argument name. I.e. arg1 => Arg1.
        $setterName = "set" . $setterName;                  # prepend "set" to the uppercased argument name.

        if (my $fn = $this->UNIVERSAL::can($setterName)) {  # test that the object can call this function
            $fn->($this,$args{$key});                       # and call it
        } else {                                            # else fail with an error. 
            Confess "Field named \"$key\" is not defined in object Template::SimpleTextArchive. typo ?\n";
        }
    }



    #### __new is the magic "pre-constructor".  You can intercept a call to the parent
    #### constructor by defining a __new() procedure in your class.

    eval {Template::SimpleTextArchive::__new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?Template::SimpleTextArchive::__new/;

    #### Now call the parent constructor, if any.

    eval {$this->SUPER::new(%args)};

    croak $@ if $@
	and $@ !~ /^Can\'t locate object method/;

    ####
    #### Typically this following contains your "real" constructor"
    #### so if you are debugging this next call my be a good candidate to step into.
    ####

    eval {Template::SimpleTextArchive::_new($this,%args);};

    croak $@ if $@
	and $@ !~ /^Undefined subroutine.+?Template::SimpleTextArchive::_new/;

    $this;
}

###  END GENERATED CODE

=pod

=head1 MEMBERS AND MEMBER ACCESS METHODS

=cut



=pod

=head2 debug => "any string"

turn on debugging output

=cut

sub getDebug {

=pod

=head3 $SimpleTextArchive->getDebug ()


getter for member debug

=cut

    my $this = shift;





    return $this->{debug};
}
sub setDebug {

=pod

=head3 $SimpleTextArchive->setDebug (debug => "any string")

 - debug ("any string")		 : turn on debugging output

setter for member debug

=cut

    my $this = shift;


    my $debug = shift;



    $this->{debug} = $debug;
    return $debug;
}



=pod

=head2 rootDirectory => "any string"

The directory that is the root of the created ArchiveFile

=cut

sub getRootDirectory {

=pod

=head3 $SimpleTextArchive->getRootDirectory ()


getter for member rootDirectory

=cut

    my $this = shift;





    return $this->{rootDirectory};
}
sub setRootDirectory {

=pod

=head3 $SimpleTextArchive->setRootDirectory (rootDirectory => "any string")

 - rootDirectory ("any string")		 : The directory that is the root of the created ArchiveFile

setter for member rootDirectory

=cut

    my $this = shift;


    my $rootDirectory = shift;



    $this->{rootDirectory} = $rootDirectory;
    return $rootDirectory;
}



=pod

=head2 archiveFile => "any string"

The name/location of the archive file

=cut

sub getArchiveFile {

=pod

=head3 $SimpleTextArchive->getArchiveFile ()


getter for member archiveFile

=cut

    my $this = shift;





    return $this->{archiveFile};
}
sub setArchiveFile {

=pod

=head3 $SimpleTextArchive->setArchiveFile (archiveFile => "any string")

 - archiveFile ("any string")		 : The name/location of the archive file

setter for member archiveFile

=cut

    my $this = shift;


    my $archiveFile = shift;



    $this->{archiveFile} = $archiveFile;
    return $archiveFile;
}



=pod

=head2 defaultRunPathHeader => "any string"

write a default runPath header into the template file

=cut

sub getDefaultRunPathHeader {

=pod

=head3 $SimpleTextArchive->getDefaultRunPathHeader ()


getter for member defaultRunPathHeader

=cut

    my $this = shift;





    return $this->{defaultRunPathHeader};
}
sub setDefaultRunPathHeader {

=pod

=head3 $SimpleTextArchive->setDefaultRunPathHeader (defaultRunPathHeader => "any string")

 - defaultRunPathHeader ("any string")		 : write a default runPath header into the template file

setter for member defaultRunPathHeader

=cut

    my $this = shift;


    my $defaultRunPathHeader = shift;



    $this->{defaultRunPathHeader} = $defaultRunPathHeader;
    return $defaultRunPathHeader;
}



=pod

=head2 verbose => "any string"

Print verbose output

=cut

sub getVerbose {

=pod

=head3 $SimpleTextArchive->getVerbose ()


getter for member verbose

=cut

    my $this = shift;





    return $this->{verbose};
}
sub setVerbose {

=pod

=head3 $SimpleTextArchive->setVerbose (verbose => "any string")

 - verbose ("any string")		 : Print verbose output

setter for member verbose

=cut

    my $this = shift;


    my $verbose = shift;



    $this->{verbose} = $verbose;
    return $verbose;
}



=pod

=head1 GENERALIZED OBJECT METHODS 

=cut



=pod

=over 4

=item _require (member1,member2,...,memberN)

will iterate over arguments and validate there is a non null value for each of the listed object members

=back

=cut


sub _require
{
    my $this = shift;
    map { 
	Confess "required member variable $_ not set" unless $this->getProperty($_);
    } (@_);
}

sub debugPrint { 
    my $this = shift;
    my $level = shift;
    Confess 'you\'ve called debugPrint - convert this call to $this->debugPrint()'
	unless ref($this);
    if ($this->{debug} >= $level || $main::debug >= $level) {
        my ($caller) = (caller(1))[3];
        $caller = "[$caller]:" if $caller;
        my $date = localtime;
        print STDERR $caller . $date . ":" . basename($0) . ":($$): @_.\n" ;
    }
}

sub debugPrint_s {   # static version of debug print
    my $level = shift;
    if ($main::debug >= $level) {
        my ($caller) = (caller(1))[3];
        $caller = "[$caller]:" if $caller;
        my $date = localtime;
        print STDERR $caller . $date . ":" . basename($0) . ":($$): @_.\n" ;
    }
}

use Carp;

sub docmdq (@) {    
    system(@_);

    my $rc;
    if ($? == -1) {
        $rc = -1; printmsg "failed to execute: $!";
	exit -1;
    }
    elsif ($? & 127) {
        $rc = $? & 127;
        printmsg "child process died with signal $rc, ", ($? & 128) ? 'with' : 'without', " coredump";
	exit $rc;
    }
    else {
        $rc = $? >> 8;
        if ($rc) {
            printmsg "child process exited with value $rc - Exiting!";
            exit $rc;
        }
    }
}

sub docmd (@) {    
    printmsg "@_" ;
    docmdq(@_);
}

1;

=pod

=head1 NOTES ON THIS DOCUMENTATION

In method signatures a * denotes a required option.

This file was automatically generated from SimpleTextArchive.pm.m80 by 
bret on ubuntu (Linux ubuntu 2.6.31-19-generic-pae #56-Ubuntu SMP Thu Jan 28 02:29:51 UTC 2010 i686 GNU/Linux)


=head1 OBJECT METHODS

=cut



sub _shell_cmd {
    my ($self, $cmd) = @_;
    print STDERR $cmd, "\n" if $self->getDebug() > 1;
    return `$cmd`;
}

sub create {
    
=pod

=head3 $SimpleTextArchive->create ()


Create a new archive file

=cut

    my $this = shift;

    Confess "Template::SimpleTextArchive->create requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;




    my ($rootdir, $outputfile) = ($this->getRootDirectory, $this->getArchiveFile);
    my @files = $this->_shell_cmd("find $rootdir -type 'f'");

    open(O, ">$outputfile") || die "unable to open merged file $outputfile: $!";

    if ($this->getDefaultRunPathHeader) {
        print O "{! # -*- perl -*-
# \$m80path = [{ command => \"embedperl -magicStart '{' -magicEnd '}' -embedderChar '!'\"}]
use Env;

!}";
    }

    for my $file (@files) {
        chomp $file;

        my $mode = (stat($file))[2];
        $mode = sprintf( "%04o", $mode & 07777);

        open(F, "<$file") || die "unable to open file to be merged $file: $!";

        $file =~ s/$rootdir\///;
        print STDERR "$file\n" if $this->getVerbose;

        print O "<!-- FILE|$file|$mode -->\n";
        while (<F>) { 
            print O;
        }
        print O "\n";
        close(F);
    }
}

sub extract {
    
=pod

=head3 $SimpleTextArchive->extract ()


Extract an archive file to a root directory

=cut

    my $this = shift;

    Confess "Template::SimpleTextArchive->extract requires named arguments, or maybe a non-static method is being called in a static context " if scalar @_ && scalar @_ % 2 != 0;
    my %args = @_;




    my ($infile, $root) = ($this->getArchiveFile, $this->getRootDirectory);
    $root ||= './';

    open(I, "<$infile") || die "unable to open $infile: $!";
    print STDERR "infile is $infile\n" if $this->getDebug > 1;
    my $f_opened = 0;
    my ($mode, $file, $last_mode, $last_file, $do_not_overwrite_existing_file);
    while (<I>) {
        if (s/^\s*<!--\sFILE\|(.+?)\s*-->//) {
            $last_mode = $mode;
            $last_file = $file;
            ($file, $mode, $do_not_overwrite_existing_file) = split /\|/, $1;

            print STDERR "Found a match $file - $mode - $do_not_overwrite_existing_file:\n" if $this->getDebug > 1;

            if ($f_opened) {
                close(F);
                $this->_shell_cmd("chmod $last_mode $last_file");
                $f_opened = 0;
            }

            # determine the final filename
            $file =~ s/^\.\///;
            $file = "$root/$file";

            # should we overwrite the file if it exists?
            if (-f $file && $do_not_overwrite_existing_file) {
                $do_not_overwrite_existing_file = 1;
            } else {
                $do_not_overwrite_existing_file = 0;
            }

            # open a new file , if we are supposed to
            if ($do_not_overwrite_existing_file) {
                print STDERR "$file exists and do_not_overwrite is on - skipping file\n" if $this->getVerbose;
            } else {

                print "$file\n" if $this->getVerbose;

                my $dir = dirname($file);
                $this->_shell_cmd("mkdir -p $dir");
                
                open(F, ">$file") || die "unable to open $file: $!";
                $f_opened = 1;
                $_ = '';
            }
        }

        print F unless $do_not_overwrite_existing_file;
    }

}



1;