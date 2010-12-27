##!/bin/bash -x
## $m80path = [{command => "embedperl.pl" , exec => }]
#
# Export local env and run command via ssh.
#

##set -x
##<:
parseCommandLine();
getExcludeList();
##:>


##ssh -l <:= $user :> <:= $pass :> <<EOF
print "ssh -l $user $pass <<EOF\n";

##<:
foreach $key (keys(%ENV)) {
    if (isExcluded($key)) {
        next;
    }
    my $value = $ENV{$key};
    $value = escape($value);
##:>
    
    ##export <:= $key :>=<:= $value :>
    print "  export $key=$value\n";

##<:    
}
##:>

##<:= $command :>
##EOF
print "  $command\n";
print "EOF\n";

#how do you get the exit code of $command back to the originating shell?
##return $?
#print "return $?";




########SUBS########

##<: 

#get a list of excluded vars from file sshenv.exclude (one var per line)
#and from environment var sshenv_exclude (space separated list)
sub getExcludeList {
    @excludes = split(/ /, $ENV{"sshenv_exclude"});
    
    open(EX, "sshenv.exclude") || die("Error: could not open file sshenv.excludes");
    while (<EX>) {
        chomp $_;
        @excludes = (@excludes, $_);
    }
}

sub isExcluded {
    my $check = $_[0];    
    foreach (@excludes) {
        if ($check eq $_) {
            return 1;
        }            
    }
    return 0;
}

sub parseCommandLine {
    if (@ARGV == 0) {
        usage();        
    }  
    $command = $ARGV[0];
    $user = $ARGV[1];    
    $pass = $ARGV[2];
    
    if (!defined($user)) {
        $user = $ENV{"sshenv_user"};
    }
    if (!defined($pass)) {
        $pass = $ENV{"sshenv_pass"};
    }
    if (!defined($user) || !defined($pass)) {
        usage("Error: user or pass not specified");
    }

}

sub usage {
    if (defined($_[0])) {
        print "\n$_[0]\n";
    }
    print "\nUsage: sshenv.pl [command] [user] [pass]\n\n";
    die;
}

#surround input in single quotes, plus convert any embedded single quotes to '\''
#input: o'reilly
#output 'o'\''reilly'
sub escape {    
    my $s = $_[0];
    $s =~ s/\'/\'\\\'\'/;    
    return '\'' . $s . '\'';
}

##:>