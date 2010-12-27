
$testXMLFile = "testMachine/testChassis.xml";

@tests = (
	  {commands => [
			{name => "startSimple",command => "createTask.pl -ta parallelTest -context sleepVal=0,exitVal=0",},
			{name => "validToRestart",command => "createTask.pl -ta restartTest -context",},
			{command => 'sleep 2; date',},
			{command => 'restartTask.pl -task_id $tasks{startSimple} -status running',},
			{command => 'restartTask.pl -task_id $tasks{validToRestart} -status running',},
			{command => "bumpSM", type => "internal"},
			{command => 'sleep 2; date',},
			],
	   wait => "2",
	   expectations => [{name => "startSimple",table => "TASK",field => status,expectation => 'failed',},
			    {name => "startSimple",table => "TASK",field => failurereason,expectation => 'metadata did not support restart',},
			    {name => "validToRestart",table => "TASK",field => status,expectation => 'succeeded',},
			    {name => "validToRestart",table => "TASK",field => failurereason,expectation => 'transition',},
			    ]},

	  );
	  

1;
