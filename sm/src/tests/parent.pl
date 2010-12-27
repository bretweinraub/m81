
$testXMLFile = "testMachine/testChassis.xml";

@tests = (

    {commands => [{name => "parent", command => "createTask.pl -task parentTest_parent"}],
     wait => 5,
     expectations => [{name => "parent", table => "TASK", field => status, expectation => 'waiting'},],},
    );
	  

1;
