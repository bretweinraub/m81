package Acme::JavaTrace;
use strict;

use vars qw($CLASS $VERSION);
$CLASS   = 'Acme::JavaTrace';
$VERSION = '0.01';

# Install warn() and die() substitues
$SIG{'__WARN__'} = \&do_warn;
$SIG{'__DIE__' } = \&do_die;

my $stderr = '';
my $in_eval = 0;


# 
# do_warn()
# -------
sub do_warn {
    local $SIG{'__WARN__'} = 'DEFAULT';
    
    my $msg = join '', @_;
    $msg =~ s/ at (.+) line (\d+)\.$//;
    $stderr .= $msg;
    $stderr .= "\n" if substr($msg, -1, 1) ne "\n";
    
    stack_trace($1, $2);
    
    print STDERR $stderr;
    $stderr = '';
    $in_eval = 0;
}


# 
# do_die()
# ------
sub do_die {
    local $SIG{'__WARN__'} = 'DEFAULT';
    local $SIG{'__DIE__' } = 'DEFAULT';
    
    CORE::die @_ if index($_[0], "\n\tat ") >= 0;
    
    my $msg = join '', @_;
    $msg =~ s/ at (.+) line (\d+)\.$//;
    $stderr .= $msg;
    $stderr .= "\n" if substr($msg, -1, 1) ne "\n";
    
    stack_trace($1, $2);
    
    if($in_eval) {
        $@ = $stderr;
        $stderr = '';
        $in_eval = 0;
        CORE::die $@
        
    } else {
        print STDERR $stderr;
        $stderr = '';
        exit -1
    }
}


# 
# stack_trace()
# -----------
sub stack_trace {
    my($file,$line) = @_;
    $file ||= '';  $line ||= '';
    $file =~ '(eval \d+)' and $file = '<eval>';
    
    my $level = 2;
    my @stack = ( ['', $file, $line] );  # @stack = ( [ function, file, line ], ... )
    
    while(my @context = caller($level++)) {
        $context[1] ||= '';  $context[2] ||= '';
        $context[1] =~ '(eval \d+)' and $context[1] = '<eval>' and $in_eval = 1;
        $context[3] eq '(eval)' and $context[3] = '<eval>' and $in_eval = 1;
        $stack[-1][0] = $context[3];
        push @stack, [ '', @context[1, 2] ];
    }
    $stack[-1][0] = 'main::';
    
    for my $func (@stack) {
        $$func[1] eq '' and $$func[1] = 'unknown source';
        $$func[2] and $$func[1] .= ':';
        $stderr .= "\tat $$func[0]($$func[1]$$func[2])\n";
    }
}


1;

__END__

=head1 NAME

Acme::JavaTrace - Module for using Java-like stack traces

=head1 SYNOPSIS

    use Acme::JavaTrace;
    warn "some kind of non-fatal exception occured";
    die "some kind of fatal exception occured";


=head1 DESCRIPTION

C<< <buzzword> >>This module tries to improves the Perl programmer 
experience by porting the Java paradigm to print stack traces, which 
is more professional than Perl's way. C<< </buzzword> >>

This is achieved by modifying the functions C<warn()> and C<die()> 
in order to replace the standard messages by complete stack traces 
that precisely indicates how and where the error or warning occurred. 
Other than this, their use should stay unchanged, even when using 
C<die()> inside C<eval()>. 


=head1 BLAME

Java, for its unhelpful kilometre-long stack traces. 


=head1 AUTHOR

SE<eacute>bastien Aperghis-Tramoni <sebastien@aperghis.net>


=head1 COPYRIGHT

Acme::JavaTrace is Copyright (C)2004 SE<eacute>bastien Aperghis-Tramoni.

This program is free software. You can redistribute it and/or modify it 
under the same terms as Perl itself. 

=cut
