
package makeHelpers;

use File::Basename;

require "options.pl";

$sshOptions = "-o StrictHostKeyChecking=no -o PreferredAuthentications=publickey";

sub nl { print "\n"; }
sub tab { print "\t"; }

sub moduleName {$_= basename(`pwd`); chomp; print}

sub m80rule {

    print qq(.SUFFIXES	:	.sh);nl;
    print qq();nl;
    print qq(%.sh : %.sh.m80);nl;
    print qq/		runPath.pl $(DEBUGFLAG) -file $< /;nl;
    print qq();nl;
}

sub collectionsrule {
    my $arg = &_dn_options;

    print q();nl;
    print qq(.PHONY: $arg->{t});nl;
    print q();nl;
    print qq($arg->{t} :: );nl;
    print q(	@RC=0 ; \\);nl;
    print q(	for collection in $$(echo $(collections) | perl -nle '$$$\\\\="\\n" ; map {print} (split(/,/));') ; do \\);nl;
print q(		echo Running $${collection} ; \\);nl;
print q(		$${collection} | shell2context.pl ; \\);nl;
print q(		RC1=$$? ; \\);nl;
print q(		echo $${collection} exited with code $$RC1 ; \\);nl;
print q(		((RC=$$RC+$$RC1)) ; \\);nl;
print q(	done ; \\);nl;
print q(	exit $$RC);nl;
}

sub _action {
    my $arg = &_dn_options;

    print q(    );nl;
    print qq(.PHONY: $arg->{t});nl;
    print qq($arg->{t} :  ./$arg->{t}.$arg->{s});nl;
    print qq(\t./$arg->{t}.$arg->{s});nl;
}

sub actions {
    my $arg = &_dn_options;

    my @actions = @{$arg->{a}};

    while ($#actions >= 0) {
	_action (t => $actions[0], s => $arg->{s});
	shift (@actions);
    }
}

sub genFile {
    my $arg = &_dn_options;

    print q(    );nl;
    print qq($arg->{t} :);nl;
    print qq(	cp $arg->{f} \$\(AUTOMATOR_STAGE_DIR\));nl;
    print qq(	\(cd \$\(AUTOMATOR_STAGE_DIR\) && runPath.pl -file $arg->{f}\));nl;
}


sub genAndPush {
    my $arg = &_dn_options;

    genFile(@_);
    $arg->{f} =~ s/\.m80//;
    print qq{	\(cd \$\(AUTOMATOR_STAGE_DIR\) && scp $sshOptions $arg->{f} $arg->{d}\)};nl;
}

sub sshcommand {
    print q{sshcommand=ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey $(user)@$(host)};
}

sub require {
    my $arg = &_dn_options;

    my $nls=0;
    map {
	do {nl; tab; } if $nls++;
	print qq(if [ -z "\$($_)" ]; then \\);nl;
	print qq(		echo Target \$\@ cannot be run without defining the \\\$\$$_ variable. ; \\);nl;
	print qq(		exit 1 ; \\);nl;
	print qq(	fi);
    } (@{$arg->{v}});
}
    

1;
