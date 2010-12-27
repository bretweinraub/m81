
$testXMLFile = "testMachine/testChassis.xml";

@tests = (
	  {commands => [{name => "STUPID",command => "createTask.pl -task stupid",},],
	   wait => "5",
	   expectations => [{name => "STUPID",table => "TASK",field => status,expectation => 'failed',},],
	   },
	  {commands => [{name => "NoSuchTransition",command => "createTask.pl -ta parallelTest -context sleepVal=1,exitVal=12",},],
	   wait => "2",
	   expectations => [{name => "NoSuchTransition",table => "TASK",field => status,expectation => 'failed',},
			    {name => "NoSuchTransition",table => "TASK",field => failurereason,expectation=>"no transition was found"}]},
	  {commands => [{name => "NoSuchTransition2",command => "createTask.pl -ta parallelTest -context sleepVal=0,exitVal=0",},],
	   wait => "2",
	   expectations => [{name => "NoSuchTransition2",table => "TASK",field => status,expectation => 'succeeded',}]},
	  {commands => [{name => "simpleErrorTest",command => "createTask.pl -ta errorTest",},],
	   wait => "4",
	   expectations => [{name => "simpleErrorTest",table => "TASK",field => status,expectation => 'failed',},
			    {name => "simpleErrorTest",table => "TASK_V",field => numfailures,expectation => '3',},
			    {name => "simpleErrorTest",table => "TASK_V",field => failurereason,expectation => 'exceeded failure threshold',},
			    ]},
	  {commands => [
			{name => "apTest1",command => "createTask.pl -ta apTest -context sleepVal=1,exitVal=1",},
			{name => "apTest2",command => "createTask.pl -ta apTest -context sleepVal=5,exitVal=0",},
			{name => "apTest3",command => "createTask.pl -ta apTest -context sleepVal=5,exitVal=0",},
			],
	   wait => "10",
	   expectations => [
			    {name => "apTest2",table => "TASK",field => status,expectation => 'queued',},
			    {name => "apTest3",table => "TASK",field => status,expectation => 'queued',},
			    ]},
	  {commands => [
			{name => "apTest1",command => "createTask.pl -ta apTest2 -context sleepVal=1,exitVal=1",},
			{name => "apTest2",command => "createTask.pl -ta apTest2 -context sleepVal=5,exitVal=0",},
			{name => "apTest3",command => "createTask.pl -ta apTest2 -context sleepVal=5,exitVal=0",},
			],
	   wait => "10",
	   expectations => [
			    {name => "apTest2",table => "TASK",field => status,expectation => 'queued',},
			    {name => "apTest3",table => "TASK",field => status,expectation => 'queued',},
			    ]},


	  );
	  

1;
