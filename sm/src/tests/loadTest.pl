
$testXMLFile = "testMachine/testChassis.xml";

@tests = (
	  {commands => [
			],
	   wait => "180",
	   expectations => [
			    {name => "loadTest_0",table => "TASK",field => status,expectation => 'succeeded',},
			    {name => "loadTest_999",table => "TASK",field => status,expectation => 'queued',},
			    ]},
	  );

for ($i = 0; $i < 1000; $i++) {
    push (@{$tests[0]->{commands}}, {name => "loadTest_$i",command => "createTask.pl -ta parallelTest -context sleepVal=$i,exitVal=0",});
}

1;
