package Helpers::sshHelpers;

use Carp;
use shellHelpers;
use File::Basename;

sub _options {
  my %ret = @_;
  my $once = 0;
  for my $v (grep { /^-/ } keys %ret) {
    require Carp;
    $once++ or Carp::carp("deprecated use of leading - for options");
    $ret{substr($v,1)} = $ret{$v};
  }

  $ret{control} = [ map { (ref($_) =~ /[^A-Z]/) ? $_->to_asn : $_ } 
		      ref($ret{control}) eq 'ARRAY'
			? @{$ret{control}}
			: $ret{control}
                  ]
    if exists $ret{control};

  \%ret;
}


sub _dn_options {
  unshift @_, 'dn' if @_ & 1;
  &_options;
}

1;


sub nl { print "\n"; }

sub moduleName {
    my $ret; 
    $_= basename(`pwd`); 
    chomp; 
    $ret .= $_;
    return $ret;
}

sub sshShellScript {
    my $ret; 
    my $arg = &_dn_options;
    $ret .= shellHelpers::shellScript(getopts => "(h, -host),(u, -user)" . ($arg->{getopts} ? "," . $arg->{getopts} : ""),
				      r => $arg->{r},
				      suppressChangeQuote => true);
    $ret .=  q(printmsg spawning SSH here doc: $SSHCOMMAND ${user}@${host});$ret .= "\n";
    $ret .=  q($SSHCOMMAND -l ${user} ${host} <<EOF );$ret .= "\n";
    $ret .=  q(shell_load_functions(HDprintmsg,HDcleanup,HDrequire,HDfilesize,HDdocmd,HDcheckfile,HDdocmdi));$ret .= "\n";
    unless ($arg->{suppressChangeQuote}) {
        $ret .=  q(m4_changequote(!*!,*!*));$ret .= "\n";
    }
    if ($arg->{p4}) {
	$ret .= "export P4USER=\$P4USER\n";
	$ret .= "export P4CLIENT=\$P4CLIENT\n";
	$ret .= "export P4PASSWD=\$P4PASSWD\n";
	$ret .= "export P4PORT=\$P4PORT\n";
    }	
    return $ret;
}

sub sshScriptOnly {
    my $ret; 
    my $arg = &_dn_options;
    $ret .=  q(printmsg spawning SSH here doc: $SSHCOMMAND ${user}@${host});$ret .= "\n";
    $ret .=  q($SSHCOMMAND -l ${user} ${host} <<EOF );$ret .= "\n";
    $ret .=  q(shell_load_functions(HDprintmsg,HDcleanup,HDrequire,HDfilesize,HDdocmd,HDcheckfile,HDdocmdi));$ret .= "\n";
    unless ($arg->{suppressChangeQuote}) {
        $ret .=  q(m4_changequote(!*!,*!*));$ret .= "\n";
    }
    return $ret;
}

sub sshDevEnvScript {
    my $ret; 
    my $arg = &_dn_options;
#    my @args = ("beahome_$osflavor", "wlhome_$os"); push @args, @{ $arg->{r} };
    $ret .= shellHelpers::shellScript(getopts => "(h, -host),(u, -user)",
				      r => \@args,
				      suppressChangeQuote => true);
    $ret .=  q(printmsg spawning SSH here doc: $SSHCOMMAND ${user}@${host});$ret .= "\n";
    $ret .=  q($SSHCOMMAND -l ${user} ${host} <<EOF );$ret .= "\n";
    $ret .=  q(shell_load_functions(HDprintmsg,HDcleanup,HDrequire,HDfilesize,HDdocmd,HDcheckfile,HDdocmdi));$ret .= "\n";
    $ret .=  "docmd cd \$devbranch_$os\n";
    $ret .=  "if test ! -f wls/mydevenv.sh; then\n";
    $ret .=  "\tdocmd export BEA_HOME_ctl=\$beahome_$os\n";
    $ret .=  "\tdocmd export WL_HOME_ctl=\$wlhome_$os\n";
    $ret .=  "\t" . q(bash -c 'set -x ; . devenv.sh -dl') . "\n";
    $ret .=  "fi\n";
    $ret .=  "source wls/mydevenv.sh\n";
    $ret .=  q(m4_changequote(!*!,*!*));$ret .= "\n";
    return $ret;
}

sub endSshShellScript {
    my (%arg) = @_;
    my $ret; 
    $ret .=  q(EOF);$ret .= "\n";
    $ret .=  q();$ret .= "\n";
    $ret .=  q(RC=$?);$ret .= "\n";
    $ret .=  q(if test $RC -ne 0; then);$ret .= "\n";
    $ret .=  q(    cleanup $RC remote command failed);$ret .= "\n";
    $ret .=  q(fi);$ret .= "\n";
    $ret .=  q();$ret .= "\n";
    unless ($arg{suppressCleanup}) {
        $ret .=  q(cleanup 0);$ret .= "\n";
    }
    return $ret;

}


