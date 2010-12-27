$testXMLFile = "testMachine/testChassis.xml";
{commands => [{name => "STUPID",command => "createTask.pl -task stupid",},],
 wait => "1",
 expectations => [{name => "STUPID",table => "TASK",field => status,expectation => 'failed',},],
},
