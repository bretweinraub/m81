#!/usr/bin/perl

use Data::Dumper;
use moduleHelpers;
use Carp;
use Term::ANSIColor qw(:constants);
use Getopt::Long;
use File::Basename;
use lib dirname($0);

require "results.pl";

GetOptions ("testnum:i" => \$testnum,
	    "clip:i" => \$clip);

my @tests = (
	     # test for unterminated chain

	     {block => {a => [{n => action1},
			      {name => action2}],},
	      expectation => {rc => 0,
			      error => 'unterminated chain detected, use t|target => "NEXTACTIONNAME" or e|external => "true" (look near action action1)'}},

	     # test for target not in last step of a chain.

	     {block => {a => [{n => action1,
			       t => 'nextAction'},
			      {name => action2}],},
	      expectation => {rc => 0,
			      error => 't|target => "ANYVALUE" only valid in last action of a chain' . "\n"}},

	     # simple block test.

	     {block => {a => [{n => action1},
			      {name => action2,
			       t => "__SUCCESS__",}
			      ],},
	      expectation => {rc => 1,
			      error => undef}},

	     # mapper test with commands.

	     {block => {m => qw(s/this/that/),
			a => [{n => action1,
			       c => "stupidCommand.pl",},
			      {name => action2,
			       t => "__SUCCESS__",}
			      ],},
	      expectation => {rc => 1,
			      error => undef}},

	     {block => {a => [{name => startAction,
			       Callback => true,
#			       Transitions => [task1, task2],
			   }
			      ],},
	      expectation => {rc => 1,
			      error => undef}},
	     {block => {a => [{name => startAction,
			       Callback => true,
			       Transitions => [task1, task2],
			   }
			      ],},
	      expectation => {rc => 0,
			      error => 'unterminated chain detected, use t|target => "NEXTACTIONNAME" or e|external => "true" (look near action startAction)'}},

	     {block => {a => [{name => startAction,
			       Callback => true,
			       target => '__SUCCESS__',
			       Transitions => [task1, task2],
			   }
			      ],},
	      expectation => {rc => 1,
			      error => undef}},

	     {block => {a => [{name => startAction,
			       Callback => true,
			       Transitions => [task1]},
			      {n => "nextAction",
			       t => '__SUCCESS__'},
			      ],},
	      expectation => {rc => 1,
			      error => undef}},


	     {block => {a => [{name => startAction},
			      {name => externalAction,
			       e => true,
			       T => [task1]},
			      {n => "nextAction",
			       t => '__SUCCESS__'},
			      ],},
	      expectation => {rc => 1,
			      error => undef}},


	     {block => {a => [{n => loadCollections, 
			       C => true, # create callbacks for all configured TASKS ; allows for multiple entry pts
			       T => [task1]}, 
			      {n => parent1,
			       p => true, # actually a parent; so do a wait
			       C => true, # create callbacks for all configured TASKS ; allows for multiple entry pts
			       T => [task1],
			       c => 'childCommand',
			       chain => {a => [{name => firstChild},
					       {n => pushRemoteTools, 
						e => true, # external action syntax
						T => [task1]}, 
					       {n => runSilentInstall,
						t => '__SUCCESS__'},
					       ]}},
			      {n => parentReturn,
			       t => __SUCCESS__},
			      ]},
					       
	      expectation => {rc => 1,
			      error => undef}},


	     {block => {a => [{n => loadCollections, 
			       C => true, # create callbacks for all configured TASKS ; allows for multiple entry pts
			       T => [layDownInstaller,siInstaller]}, 
			      {n => genPlatformSpecificPaths,
			       p => true, # actually a parent; so do a wait
			       C => true, # create callbacks for all configured TASKS ; allows for multiple entry pts
			       T => [layDownInstaller],		   
			       c => 'spawnChildTasks.pl -algorithm ListFlagMatch -list ALL_HOSTS -flag wls_server -child genPlatformSpecificPaths -s true',
			       chain => {a => [{n => genPlatformSpecificPaths},
					       {n => getInstallerVersion,
						c => 'getInstallerVersion.pl'},
					       {n => setBEAHome},
					       {n => buildRemoteDirs},
					       {n => pushRemoteTools, 
						e => true, # external action syntax
						T => [layDownInstaller,siInstaller]}, 
					       {n => pushSSHKeys},
					       {n => remoteFetchInstaller},
					       {n => genSilentXML},
					       {n => runSilentInstall,
						t => '__SUCCESS__'},
					       ]}},
			      {n => genCreateDomain,
			       p => true, # actually a parent; so do a wait
			       c => 'spawnChildTasks.pl -algorithm ListFlagMatch -list ALL_HOSTS -flag wls_server -child genCreateDomain -s true',
			       chain => {a => [{n => genCreateDomain},
					       {n => genDomainWLST,
						t => '__SUCCESS__'},
					       ]}},
			      {n => exitStub,
			       c => 'exit 0',
			       t => __SUCCESS__},
			      ]},
	      expectation => {rc => 1,
			      error => undef}},
	     
	     {block => {a => [{n => action1,
			       transitions => { '1' => 'oneAction',
						'2' => 'twoAction'}},
			      {n => action2,
			       transitions => { 0 => 'wacky',
						'\\d+' => 'crazy'}},
			      {name => final,
			       t => "__SUCCESS__",}
			      ],},
	      expectation => {rc => 1,
			      error => undef}},
	     {block => {a => [{n => genDomainWLST,
			       m => 's/_adminserver_//;'},
			      {n => fetchDomain},
			      {n => pushDomain,
			       p => true,
			       c => 'spawnChildTasks.pl -algorithm UniqueList -list ALL_MANAGEDSERVERS -unique host -child pushDomain',
			       chain => {a => [{n => pushDomain,
						t => __SUCCESS__}]}},
			      {n => asBootstrapExitStub,
			       t => '__SUCCESS'},]},
	      expectation => {rc => 1,
			      error => undef}},
	     {block => {a => [{n => dependsonStep1,
			       m => 's/_adminserver_//;',
                               d => [Step1]},
			      {n => nextStep,
                               d => [Step1],
                               c => 'hardcodedCommand',
			       t => '__SUCCESS'},]},
	      expectation => {rc => 1,
			      error => undef}},
	     {block => {a => [{n => dependsonStep1andStep2,
			       m => 's/_adminserver_//;',
                               d => [Step1,Step2]},
			      {n => nextStep,
			       t => '__SUCCESS'},]},
	      expectation => {rc => 1,
			      error => undef}},
	     {block => {a => [{n => entryAction,
			       d => [dependAction]},
			      {n => endAction,
			       t => __SUCCESS__}]},
	      expectation => {rc => 1,
			      error => undef}},
# test 17
	     {block => {a => [{n => suppress1},
			      {n => suppress2,
			       s => true},
			      {n => suppress3,
			       t => __SUCCESS__}]},
	      expectation => {rc => 1,
			      error => undef}},
	     );


my $success=0;
my $failure=0;
my $tests=0;
my $testsrun=0;

foreach $test (@tests) {
    $tests++;
    next if $testnum and ($tests ne $testnum);
    $testsrun++;
    confess "no block defined for test $tests" unless $test->{block};
    confess "no expectation defined for test $tests" unless defined $test->{expectation};
    my ($data, $error);
    use vars qw ($data $error);
    $data = "";
    $error ="";
    my $rc = _chainActions (%{$test->{block}}, error => \$error, data => \$data);
    print "Test $tests ";
    if ($rc eq $test->{expectation}->{rc} and
	$error eq $test->{expectation}->{error} and
#	$data eq $test->{expectation}->{data}) {
	$data eq $results[$tests-1]) {
	print BOLD, BLUE, "SUCCEDED", RESET;
	$success++;
	unless ($clip) {
	    print " ($test->{expectation}->{rc}, $results[$tests-1], $test->{expectation}->{error})\n";
	} else {
	    print " ($test->{expectation}->{rc}, " . substr ($results[$tests-1], 1, $clip) . " ..... <<clipped at $clip chars>>, $test->{expectation}->{error})\n";
	}
    } else {
	print BOLD, RED, "FAILED", RESET;
	open OUT, "> diff.0";
	print OUT $data;
	close OUT;
	open OUT, "> diff.1";
	print OUT $results[$tests-1];
	close OUT;
	$failure++;
	print " ($test->{expectation}->{rc}, $results[$tests-1], $test->{expectation}->{error}) => ($rc, $data, $error)\n";
	print BOLD, RED;
	system("diff -C 5 diff.?");
	print RESET;
	print "Diff exited error code $?\n";
    }

}

print "$success out of $testsrun test(s) succeeded, or % " . abs(($success/$testsrun) * 10000)/100 . "\n";

exit $failure;

