
#
# Implementation of state machine for domain specific languages
#

package shellHelpers;
use File::Basename;
use Carp;

require "options.pl";

sub moduleName {$_= basename(`pwd`); chomp; return $_}

sub shellScript {
    my $ret; 
    my $arg = &_dn_options;
    $ret .= q(m4_define(`SHELL',/bin/bash)m4_dnl ` -*-shell-script-*-);$ret .= "\n";
    $ret .= q(m4_include(shell/shellScripts.m4)m4_dnl);$ret .= "\n";
    $ret .= q(shell_load_functions(printmsg,cleanup,require,filesize,docmd,docmdi,checkfile,sshcommand));$ret .= "\n";
    $ret .= q();$ret .= "\n";
    $ret .= q(unset QUIET);$ret .= "\n";
    $ret .= qq(shell_getopt($arg->{getopts}));$ret .= "\n";
    unless ($arg->{suppressChangeQuote}) {
	$ret .=  q(m4_changequote(!*!,*!*));$ret .= "\n";
    }
    map { $ret .= "require $_\n" if $_ } (@{$arg->{r}}) ;
    $ret .= "\n";$ret .= "\n";
    return $ret;
}

sub _generatedTemplateName {
    my ($t);
    ($t = $_[0]) =~ s/\.m80$//;
    return $t;
}

sub _scpCopy {
    my ($src, $destination) = @_;
    $src = _generatedTemplateName($src);
    return "docmd scp -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey $src \$user\@\$host:$destination/$src\n";
}

sub _scpCopyReName {
    my ($src, $destination) = @_;
    $src = _generatedTemplateName($src);
    return "docmd scp -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey $src \$user\@\$host:$destination\n";
}

sub _scpGet {
    my ($src, $destination) = @_;
    return "docmd scp -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey \$user\@\$host:$src $destination/\n";
}

sub _sshmkdir {
    my ($destination) = @_;
    return "docmd ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey \$user\@\$host \"mkdir -p $destination\"\n";
}

sub _genTemplate {
    my ($templateName, @requiredVars, $extras) = @_;
    my $ret = '';
    $ret .= "docmd mkdir -p \$AUTOMATOR_STAGE_DIR/templates\n";
    $ret .= "templateDir=`dirname \$0`/templates\n";
    $ret .= "docmdi cp -f \$templateDir/" . $templateName . " \$AUTOMATOR_STAGE_DIR/templates\n";
    $ret .= "docmdi cp -f \$templateDir/*.m80_ \$AUTOMATOR_STAGE_DIR # .m80_ are include files, if any exist\n";
    $ret .= "docmd cd \$AUTOMATOR_STAGE_DIR/templates\n";
    $ret .= "docmd runPath.pl -file $templateName\n";
    $ret .= 'docmd chmod +r ' . _generatedTemplateName($templateName) . "\n";
    return $ret;
}

sub _genAndPushTemplate {
    my ($templateName, $destination, @requiredVars) = @_;
    my $ret = '';
    $ret .= _genTemplate($templateName, @requiredVars);
    $ret .= _scpCopy( $templateName, $destination );
    $ret .= "cd \$OLDPWD\n";
    return $ret;
}


sub _genAndPushTemplateReName {
    my ($templateName, $destination, @requiredVars) = @_;
    my $ret = '';
    $ret .= _genTemplate($templateName, @requiredVars);
    $ret .= _scpCopyReName( $templateName, $destination );
    $ret .= "cd \$OLDPWD\n";
    return $ret;
}

sub genAndPushTemplate {
    my $ret; 
    my %arg = @_;
    $ret = shellScript(r => [AUTOMATOR_STAGE_DIR, user, host, @{$arg{requiredVars}}]);
    if ($arg{rename}) {
        $ret .= _genAndPushTemplateReName( $arg{templateName}, $arg{destination}, @$arg{requiredVars} );
    } else {
        $ret .= _genAndPushTemplate( $arg{templateName}, $arg{destination}, @$arg{requiredVars} );
    }
    $ret .= "\ncleanup 0\n";

    return $ret;
}


#
# args:
#   rename => t : specify the destination file - otherwise the fmk derives it from the src name
#   no_shell_script_block => t : don't spit out the 'shellScript' headers
#   mkdir => t  : create the destination directories
sub genAndPushTemplates {
    my $ret = ''; 
    my %arg = @_;
    $ret = shellScript(r => [AUTOMATOR_STAGE_DIR, user, host, @{$arg{requiredVars}}])
        unless $arg{no_shell_script_block};
    $ret .= "
\$SSHCOMMAND \$user@\$host <<EOF
";
    foreach $tmpl (@{$arg{templates}}) {
        if ($arg{rename}) {
            $ret .= "chmod +w $tmpl->{destination}\n";
        } else {
            $ret .= "chmod +w $tmpl->{destination}/" . _generatedTemplateName ($tmpl->{templateName}) . "\n";
        }
    }
    

    $ret .= "\nEOF\n\n";
    foreach $tmpl (@{$arg{templates}}) {
        if ($arg{mkdir} && ! $arg{rename}) { # don't try and calculate the dir name if the file is being recalced.
            $ret .= _sshmkdir($tmpl->{destination});
        }
        if ($arg{rename}) {
            $ret .= _genAndPushTemplateReName( $tmpl->{templateName}, $tmpl->{destination}, @$arg{requiredVars} );
        } else {
            $ret .= _genAndPushTemplate( $tmpl->{templateName}, $tmpl->{destination}, @$arg{requiredVars} );
        }
    }

    return $ret;
}


#
# args:
#   no_shell_script_block => t : don't spit out the 'shellScript' headers
#   templates => [ { templatetemplateName1, templateName2, ... ] : 
sub genAndPushTemplatesToAssembly {
    my $ret = ''; 
    my %arg = @_;
    $ret = shellScript(r => [AUTOMATOR_STAGE_DIR, user, host, @{$arg{requiredVars}}])
        unless $arg{no_shell_script_block};

    foreach $tmpl (@{$arg{templates}}) {
        my $expansion = _generatedTemplateName($tmpl->{templateName});
        my $destination = $tmpl->{destination}; $destination ||= '.';
        $ret .= 'MYPWD=`pwd`' . "\n";
        $ret .= _genTemplate($tmpl->{templateName});
        $ret .= "docmd mkdir -p \$APPLICATION_STAGE_DIR/$destination\n";
        $ret .= "docmd cp $expansion \$APPLICATION_STAGE_DIR/$destination\n";
#         $ret .= "tar cvf - $expansion | (cd \$APPLICATION_STAGE_DIR/$destination && tar xvf -)\n";
#         $ret .= "RC=\$?
# if test \$RC -ne 0; then
#     cleanup \$RC failure copying template to assembly directory
# fi
# ";
        $ret .= 'docmd cd $MYPWD' . "\n";
    }
    return $ret;
}

sub genTemplate {
    my $ret; 
    my ($templateName, @requiredVars) = @_;
    $ret = shellScript(r => [AUTOMATOR_STAGE_DIR, @requiredVars]);
    $ret .= _genTemplate($templateName, @requiredVars);
    return $ret;
}
    
sub _genAndPushExtraCommands {
    my ($templateName, $destination, $racommands, $rarequiredVars) = @_;
    my $ret;
    $ret .= _genTemplate($templateName, @$rarequiredVars);
    for my $cmd (@$racommands) {
        $ret .= "docmd $cmd\n";
    }
    $ret .= _scpCopy( $templateName, $destination );
    return $ret;
}

sub genAndPushDOSTemplates {
    my $ret; 
    my %arg = @_;
    $arg{r} = [AUTOMATOR_STAGE_DIR, user, host, @{ $arg{requiredVars} }];
    $ret = shellScript(%arg) unless $arg{no_shell_script_block};    
    for $href (@{$arg{templates}}) {
        $ret .= 'MYOLDPWD=`pwd`' . "\n";
        $ret .= onlyGenAndPushDOSTemplate(%$href, requiredVars => $arg{requiredVars}, r => $arg{r}, suppressCleanup => t);
        $ret .= 'docmd cd $MYOLDPWD' . "\n";
    }
    return $ret;
}

sub genAndPushDOSTemplate {
    my $ret; 
    my %arg = @_;
    $arg{r} = [AUTOMATOR_STAGE_DIR, user, host, @{ $arg{requiredVars} }];
    $ret = shellScript(%arg) unless $arg{no_shell_script_block};    
    $ret .= onlyGenAndPushDOSTemplate(@_);
    return $ret;
}


sub onlyGenAndPushDOSTemplate {
    my $ret; 
    my %arg = @_;

    $ret .= _genAndPushExtraCommands( 
                                      $arg{templateName}, 
                                      $arg{destination},
                                      [ 'unix2dos ' . _generatedTemplateName($arg{templateName}),
                                        _sshmkdir( $arg{destination} ) ],
                                      $arg{requiredVars}
                                      );
    $ret .= "\ncleanup 0\n" unless $arg{suppressCleanup};

    return $ret;
}

sub printmsg {
    my $o =<<'EOF';
use File::Basename;

sub printmsg (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$) @_.\n" ;
}

sub printmsgn (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$) @_\n" ;
}

EOF

}

sub docmd {
    my $o =<<'EOF';
use Carp;

sub docmd (@) {    
    printmsg "@_" ;
    system(@_);

    my $rc;
    if ($? == -1) {
        $rc = -1; printmsg "failed to execute: $!";
    }
    elsif ($? & 127) {
        $rc = $? & 127;
        printmsg "child process died with signal $rc, ", ($? & 128) ? 'with' : 'without', " coredump";
    }
    else {
        $rc = $? >> 8;
        if ($rc) {
            printmsg "child process exited with value $rc - Exiting!";
            exit $rc;
        }
    }
}
EOF

}


sub docmdi (@) {
    my $o =<<'EOF';
sub docmdi {    
    printmsg "@_";
    system(@_);

    my $rc;
    if ($? == -1) {
        $rc = -1; printmsg "failed to execute: $!";
    }
    elsif ($? & 127) {
        $rc = $? & 127;
        printmsg "child process died with signal $rc, ", ($? & 128) ? 'with' : 'without', " coredump";
    }
    else {
        $rc = $? >> 8;
        if ($rc) {
            printmsg "child process exited with value $rc - ignoring\n";
        }
    }
}
EOF

}


sub termiteScript {
    my %args = @_;
    if (exists $args{getopts} && defined $args{getopts}) {
        $args{getopts} .= ",(-k,keepLogs)" unless $args{getopts} =~ /keepLogs/;
        $args{getopts} .= ",(d,destination)" unless $args{getopts} =~ /destination/;
    } else {
        $args{getopts} = '(-k,keepLogs),(d,destination)';
    }
        
    my $o = shellScript(%args);
    $o .=<<'EOF';
#
# remote_copy
#   
# Description: copy a remote file locally, succeed on error
#
function remote_copy () {
    printmsg "remote_copy: $user@$host:$1 to $2"
    docmd mkdir -p $2;
    docmdi scp -r -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey $user@$host:$1 $2
}


#
# remote_docmdi
#   
# Description: run a command remotely, succeed on error
#
function remote_docmdi () {
    printmsg "remote_docmd: $user@$host '$*'"
    docmdi "ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey $user@$host '$*'"
}



# SETUP
if test -n "$keepLogs"; then keepLogs=-k; fi

if test -n "$wsrp_master_task_id"; then
    idToUse=$wsrp_master_task_id
elif test -n "$master_task_id"; then
    idToUse=$master_task_id
else
    idToUse=$task_id
fi

if test -z "$destination"; then
    destination="/var/www/html/$M80_BDF/wlogs/$idToUse"
fi

EOF

    return $o;

}
1;

    

    
