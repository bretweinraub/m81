#!/usr/bin/perl

use Carp;
use Getopt::Long;
use Data::Dumper;
use Pod::Usage;
use File::Basename;

sub print_usage {
    if (scalar @_ > 0) {
        print STDERR "@_\n";
        exit(1);
    } else {
        pod2usage({ -exitval => 1, 
                    -verbose => ($debug ? $debug : 1),
                    -output  => \*STDERR});
    }
}

use Metadata::Object;
use StateMachine::EventAdapter::XMLFile;
use File::Basename;

sub printmsg (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$): @_.\n" ;
}

sub printmsgn (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$): @_\n" ;
}

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
    $rc;
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
sub cleanup ($@) { 
    my $exit_code = shift;
    printmsg @_ if scalar @_;
    printmsg "exiting with exit code = $exit_code";
    exit $exit_code;
}
sub debugPrint ($@) { 
    my $level = shift;
    if ($debug >= $level) {
        my ($caller) = (caller(1))[3];
        $caller = "[$caller]:" if $caller;
        my $date = localtime;
        print STDERR $caller . $date . ":" . basename($0) . ":($$): @_.\n" ;
    }
}
use Term::ANSIColor qw(:constants);
sub Confess (@) {confess BOLD, RED, @_, RESET}
sub Warn (@) { warn YELLOW, BOLD, ON_BLACK, "@_", RESET }
my $task_id;
$task_id = $ENV{task_id} if $ENV{task_id};
my $event;
$event = $ENV{event} if $ENV{event};
my $PROJECT;
$PROJECT = $ENV{PROJECT} if $ENV{PROJECT};
my $taskname;
$taskname = $ENV{taskname} if $ENV{taskname};
my $nospawn;
$nospawn = $ENV{nospawn} if $ENV{nospawn};
my $interface;
$interface = $ENV{interface} if $ENV{interface};
my $scopedActionList;
$scopedActionList = $ENV{scopedActionList} if $ENV{scopedActionList};
$trace = "0";
$trace = $ENV{trace} if $ENV{trace};
$debug = "0";
$debug = $ENV{debug} if $ENV{debug};
my $help = "0";
$help = $ENV{help} if $ENV{help};

GetOptions( 	'task_id:i'	=> \$task_id,
	'event:s'	=> \$event,
	'PROJECT'	=> \$PROJECT,
	'taskname:s'	=> \$taskname,
	'nospawn'	=> \$nospawn,
	'interface:s'	=> \$interface,
	'scopedActionList:s'	=> \$scopedActionList,
	'trace'	=> \$trace,
	'debug+'	=> \$debug,
	'help'	=> \$help,
 );

print_usage() if $help;
unless ($task_id) { Warn "task_id is required" ; print_usage() ; } 
unless ($event) { Warn "event is required" ; print_usage() ; } 
unless ($PROJECT) { Warn "PROJECT is required" ; print_usage() ; } 
unless ($interface) { Warn "interface is required" ; print_usage() ; } 

=pod

=head1 NAME

XMLEventDispatcher.pl    

=head1 SYNOPSIS


Event Dispatcher (State Machine Utility) using an XML model to describe the relationships between the interfaces, providers, events, and subscribers.

=head1 ARGUMENTS

=over 4


=item [REQUIRED] 'task_id:i'

task_id of the currently running task_id 


=item [REQUIRED] 'event:s'

name of the event that is to be dispatched


=item [REQUIRED] 'PROJECT'

name of the project


=item 'taskname:s'

name of task to generate if different than the event name


=item 'nospawn'

don't spawn tasks ... useful for debugging


=item [REQUIRED] 'interface:s'

name of the interface that events will be dispatched on


=item 'scopedActionList:s'

A list of all the scoped actions for all modules.  This allows this script to determine whether a module actually implemenets a lifecycle event or not


=item 'trace'

The $trace command line flag turns on trace functionality


=item 'debug+'

The $debug command line flag is additive and can be used with the &debugPrint subroutine


=item 'help'

The help command line flag will print the help message



=back



=head1 PERLSCRIPT GENERATED SCRIPTS

This script was generated with the Helpers::PerlScript pre-compiler.

This file was automatically generated from the file: XMLEventDispatcher.pl.m80 by
bret on  (Linux ubuntu 2.6.31-19-generic-pae #56-Ubuntu SMP Thu Jan 28 02:29:51 UTC 2010 i686 GNU/Linux
) on Wed Feb 17 01:08:43 2010.

The following functions are included by default. The functions all have 
prototypes that make the parens optional.

=over 4

=item printmsg (@)

Will print a formatted message to STDERR.

=item docmdi (@)

Will run a system command and ignore the return code

=item docmd (@)

Will run a system command and exit with the return code of the child process, if it is non-zero

=item debugPrint ($@)

Use it like C<debugPrint 1, 'Some info message'> or C<debugPrint 2, 'Some trace message'> and
it will print out a little more information than the printmsg command.

=back

=cut

# ## This is autogenerated documentation


#MAIN############################################################################################################################################################
                                                                                # 
                                                                                # MAIN                                        
                                                                                # 
                                                                                ################################################################################                                        
require "$scopedActionList"                                                     # load all scoped actions; allows to only dispatch to methods that exist.
    if $scopedActionList;

debugPrint(0, "loaded $scopedActionList");

# print Dumper($ScopedActions1);

my $_x=$debug;
require 'Metadata/LoadCollections.pl';                                          # loads all metadata objects for this automation run/test into an @allObjects array
$debug=$_x;                                                                     # LoadCollections.pl can mess with $main::debug ;
                                                                                #                     
my $XMLFile = StateMachine::EventAdapter::XMLFile->new                          # 
    (filename =>                                                                
     "$ENV{M80_REPOSITORY}/projects/$ENV{PROJECT}/StateMachineInterfaces.pl");  # This gets built when the m80repository is built/deployed

#debugPrint (2, "xml data is " . Dumper($XMLFile));
                                                                                ################################################################################                    
                                                                                # Load the command line arguments into objects representing their data as was listed
                                                                                # in the XML document.                                            
my @Interfaces = @{$XMLFile->getInterfaceByName(interface => $interface)};      # Interface is of type StateMachine::EventAdapter::Interface
foreach my $Interface (@Interfaces) {
    my $Event = $Interface->getEventByName(event => $event);                    # Event is of type StateMachine::EventAdapter::Event
                                                                                #                     
                                                                                ################################################################################
                                                                                # 
                                                                                # getProviders return a hash table of providers where the module name is the key.
                                                                                #
                                                                                # This means to get out an individual provider you must do this 
                                                                                # $Providers->{moduleName};                    
                                                                                #
                                                                                ################################################################################

    do {
	printmsg "skipping $event for interface $interface";
	next ;
    } unless $Event;                                                            # when using multiple interface defintions, different events may be defined in different 
                                                                                # blocks.
    my %Providers = %{$Interface->getProviders()};                              # Providers is a hash of StateMachine::EventAdapter::Provider objects

    debugPrint(3, "providers are " . Dumper(%Providers));

    foreach $moduleName (keys(%Providers)) {                                    # For each "Provider" State Machine module for this interface
	printmsg "processing provider $moduleName for interface $interface";
	my $Provider = $Providers{$moduleName};                                 # $Provider is of type StateMachine::EventAdapter::Provider

	my %Subscribers = (%{$Provider->getSimpleSubscribers()},                # SimpleSubscribers is a hash of StateMachine::EventAdapter::SimpleSubscriber objects
			   %{$Provider->getContextSubscribers()},               # ContextSubscribers is a hash of StateMachine::EventAdapter::ContextSubscriber objects
			   %{$Provider->getThisIsOfTypeSubscribers()});         # ExclusiveSubscribers is a hash of StateMachine::EventAdapter::ThisIsOfTypeSubscriber 
                                                                                # objects

	if (keys %Subscribers) {                                                # We have Subscribers                                                           
	    foreach $objectType (keys(%Subscribers)) {                          # loop over the subscribers to this provider (these are MetaDataObject types)
		debugPrint (1, "dispatching $objectType");
		my $Subscriber = $Subscribers{$objectType};                     # Subscriber is of type StateMachine::EventAdapter:Subscriber
		printmsg 'Evaluating ' . ref $Subscriber . " $objectType\n";

		dispatchEvent(Subscriber => $Subscriber,                        # The work - dispatch the event to this provider
			      Provider => $Provider,
			      Interface => $Interface,
			      Event => $Event);
	    }
	} else {                                                                # No subscribers - dispatch the event without no mapped object
	    Confess "No subscribers found for provider $moduleName for interface $interface ... your XML may be incomplete; please verify";
	}                                                                       #                          
    }
}

cleanup 0;

#END MAIN#########################################################################################################################################################
sub dispatchEvent {                                                             # dispatchEvent() - worker bee for event dispatch
    my %args = @_;                                                              #
    my $Subscriber = $args{Subscriber};                                         ##################################################################################
    my $Provider = $args{Provider};
    my $Interface = $args{Interface};
    my $Event = $args{Event};

    my @subscribedObjects = $Subscriber->getObjects(allObjects => \@allObjects);# loop over the objects that are subscribed to the interface
#    print STDERR Dumper(\@subscribedObjects);

	debugPrint(1, "entered dispatchEvent");
    foreach my $subscribedObject (@subscribedObjects) { 

	debugPrint(1, "dispatching on " . ref($subscribedObject) );

	printmsg "Dispatching " . $Event->getName() . " event " . ref($subscribedObject) . 
	    ($subscribedObject->getProperty('name') ? "(" . $subscribedObject->getProperty('name') . ")" : "");
	
	my $mapper = $subscribedObject->getMapperForEventDispatch               # get the mapper - getMapperForEventDispatch is a method of class MetaDataObject
	    (                                                                   # pass in these objects just in case the class needs to know this info
	     Subscriber => $Subscriber,
	     Provider => $Provider,
	     Interface => $Interface,
	     Event => $Event,
             mapperBase => $Event->getMapperBase()                              # mapperBase refers to some data about which "key" of the object to use as a mapper
	    );

	printmsg "mapper resolved to $mapper";
	my @mappers = ($mapper);                                                # The old code supported arrays of mappers, so I retained that here
                                                                                # althought I don't have a use for it.

	my $FullyQualifiedTaskName = $Provider->getModule() . "-" .             # this is the scoped module syntax ... see the automator.pl xman page for more info
	    ($taskname ? $taskname :                                            # $taskname could be set from the command line, but rarely done in practice.
	     ($Subscriber->getAction() ? $Subscriber->getAction()               # override the default action (event name) via the XML event file.
	      : $Event->getName()));                                            # just use the event name.

# do not dispatch unless the action/task is implemented.

	if ($scopedActionList and not exists $ScopedActions1->{$FullyQualifiedTaskName}) {
	    printmsg "Skipping $FullyQualifiedTaskName as this is not implemented by " . $Provider->getModule();
	    next;
	}

	createTask (task_id => $task_id,                                        # Create the child task
		    taskname => $FullyQualifiedTaskName,                        # scoped module syntax
		    scopedActionList => $scopedActionList,                      # if we have a listed of scoped actions, we can choose to only dispatch when an 
		    mappers => \@mappers)                                       # action exists.
	    unless $nospawn;
    }
}

################################################################################################################################################################
                                                                                # 
sub createTask {                                                                # createTask() - encapsulates the logic on how to create a task.  Library?
    my %args = @_;                                                              #                                       
    my $task_id = $args{task_id};                                               ################################################################################
    my $taskname = $args{taskname};
    my @mappers = @{$args{mappers}};

    my $mapperText;                                                             # the -mapper argument to createTask (if necessary)
    my $syscmd = "createTask.pl -task $taskname -parent $task_id";

    for my $mapper (@mappers) {
	if ($mapper) {                                                          # could potentially be null                                          
	    $mapperText .= " -mapper '" unless $mapperText;                     # initialize the mapper argument
	    $mapperText .= "s/" . tag2shell($mapper) . "_//;";                  # good old tag2shell ;)                                                                                  
	}
    }

    $mapperText .= "'" if $mapperText;                                          # end the argument by quoting the entire mapper                                                          
    $syscmd .= $mapperText;

    debugPrint(1, "$syscmd");
    docmd($syscmd) unless $debug;                                               # bombs away
}

################################################################################################################################################################
                                                                                # 
sub getObjects {                                                                # getObjects() - encapsulates the logic on how to create a task.  Library?
    my %args = @_;                                                              #                                       
    my $task_id = $args{task_id};                                               ################################################################################
    my $taskname = $args{taskname};
    my @mappers = @{$args{mappers}};

    my $mapperText;                                                             # the -mapper argument to createTask (if necessary)
    my $syscmd = "createTask.pl -task $taskname -parent $task_id";

    for my $mapper (@mappers) {
	if ($mapper) {                                                          # could potentially be null                                          
	    $mapperText .= " -mapper '" unless $mapperText;                     # initialize the mapper argument
	    $mapperText .= "s/" . tag2shell($mapper) . "_//;";                  # good old tag2shell ;)                                                                                  
	}
    }

    $mapperText .= "'" if $mapperText;                                          # end the argument by quoting the entire mapper                                                          
    $syscmd .= $mapperText;

    docmd($syscmd) unless $debug;                                               # bombs away                                                     
}

################################################################################################################################################################



# END CODE - DOCS/POD to follow


=pod

=head1 USAGE

./XMLEventDispatcher.pl -interface SomeInterface -event SomeEvent

=head1 EXAMPLE XML Format

This script expects its XML file to be loaded from 

$M80_REPOSITORY/projects/$PROJECT/StateMachineInterfaces.pl

Here is an example XML block:

    <StateMachineInterfaces>
      <interfaces>
        <interface module="ManagedServerAdmin">
          <events>
            <event name="configure" mapperBase="name"/>
            <event name="start" mapperBase="name"/>
            <event name="postStart"/>
            <event name="stop"/>
          </events>
          <providers>
            <provider module="WLS8ManagedServerAdminImpl">
              <simple-subscribers>
                <simple-subscriber object="WLS8ManagedServer"/>
              </simple-subscribers>
            </provider> <!-- WLS8ManagedServerAdminImpl -->
          </providers>
        </interface>
      </interfaces>
    </StateMachineInterfaces>

=head1 SEE ALSO

http://wlp-wiki/display/portalSI/Event+Dispatcher+TODO+List

B<Event.pm>
B<Interface.pm>
B<Provider.pm>
B<SimpleSubscriber.pm>
B<XMLFile.pm>

=cut

