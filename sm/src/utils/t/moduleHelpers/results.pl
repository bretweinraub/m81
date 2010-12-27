
@results = (
	    #test 1,
	    undef,
	    #test 2,
	    undef,
	    #test 3,
	    '  <!-- simple chain (action1 ~ action2) -->
  <action name="action1">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => action2)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (action2 ~ __SUCCESS__) -->
  <action name="action2">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

',
	    #test 4,
	    q[  <!-- simple chain (action1 ~ action2) -->
  <action name="action1"
	  command="stupidCommand.pl">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => action2, mapper => q(s/this/that/))"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (action2 ~ __SUCCESS__) -->
  <action name="action2">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__, mapper => q(s/this/that/))"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

],
	    #test 5,
	    q[  <!-- callback chain (startAction) -->
  <action name="startAction">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => q(post-) . $thistask->getProperty(taskname) . q(-) . $thistask->getProperty(actionname))"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

],
	    #test 6,
	    undef,
	    #test 7,
	    q[  <!-- callback chain (startAction) -->
  <action name="startAction">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => q(post-) . $thistask->getProperty(taskname) . q(-) . $thistask->getProperty(actionname))"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- local callback handler (startAction) for task task1 to next action (__SUCCESS__) -->
  <action name="post-task1-startAction"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- local callback handler (startAction) for task task2 to next action (__SUCCESS__) -->
  <action name="post-task2-startAction"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

],
	    #test 8
	    q[  <!-- callback chain (startAction) -->
  <action name="startAction">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => q(post-) . $thistask->getProperty(taskname) . q(-) . $thistask->getProperty(actionname))"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- local callback handler (startAction) for task task1 to next action (nextAction) -->
  <action name="post-task1-startAction"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => nextAction)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (nextAction ~ __SUCCESS__) -->
  <action name="nextAction">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

],
	    #test 9
	    q[  <!-- simple chain (startAction ~ externalAction) -->
  <action name="startAction">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => externalAction)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- external callback handler (externalAction) for task task1 to next action (nextAction) -->
  <action name="post-task1-externalAction"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => nextAction)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (nextAction ~ __SUCCESS__) -->
  <action name="nextAction">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

],
#test 10
	    q[  <!-- callback chain (loadCollections) -->
  <action name="loadCollections">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => q(post-) . $thistask->getProperty(taskname) . q(-) . $thistask->getProperty(actionname))"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- local callback handler (loadCollections) for task task1 to next action (parent1_parent) -->
  <action name="post-task1-loadCollections"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => parent1_parent)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- callback chain (parent1_parent) -->
  <!-- use parent/child formulation for action parent1_parent -->
  <action name="parent1_parent"
	  command="childCommand">
    <transitionMap>
      <transition type="parent" value="ALLSUCCESS" code="$thistask->transitionTo(nextaction => q(post-) . $thistask->getProperty(taskname) . q(-) . $thistask->getProperty(actionname))"/>
      <transition type="parent" value="ANYFAIL" code="$thistask->transitionTo(__FAILED__)"/>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(__WAITING__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- local callback handler (parent1_parent) for task task1 to next action (parentReturn) -->
  <action name="post-task1-parent1_parent"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => parentReturn)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (firstChild ~ pushRemoteTools) -->
  <action name="firstChild">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => pushRemoteTools)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- external callback handler (pushRemoteTools) for task task1 to next action (runSilentInstall) -->
  <action name="post-task1-pushRemoteTools"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => runSilentInstall)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (runSilentInstall ~ __SUCCESS__) -->
  <action name="runSilentInstall">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (parentReturn ~ __SUCCESS__) -->
  <action name="parentReturn">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

],
#test 11
	    q[  <!-- callback chain (loadCollections) -->
  <action name="loadCollections">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => q(post-) . $thistask->getProperty(taskname) . q(-) . $thistask->getProperty(actionname))"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- local callback handler (loadCollections) for task layDownInstaller to next action (genPlatformSpecificPaths_parent) -->
  <action name="post-layDownInstaller-loadCollections"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => genPlatformSpecificPaths_parent)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- local callback handler (loadCollections) for task siInstaller to next action (genPlatformSpecificPaths_parent) -->
  <action name="post-siInstaller-loadCollections"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => genPlatformSpecificPaths_parent)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- callback chain (genPlatformSpecificPaths_parent) -->
  <!-- use parent/child formulation for action genPlatformSpecificPaths_parent -->
  <action name="genPlatformSpecificPaths_parent"
	  command="spawnChildTasks.pl -algorithm ListFlagMatch -list ALL_HOSTS -flag wls_server -child genPlatformSpecificPaths -s true">
    <transitionMap>
      <transition type="parent" value="ALLSUCCESS" code="$thistask->transitionTo(nextaction => q(post-) . $thistask->getProperty(taskname) . q(-) . $thistask->getProperty(actionname))"/>
      <transition type="parent" value="ANYFAIL" code="$thistask->transitionTo(__FAILED__)"/>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(__WAITING__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- local callback handler (genPlatformSpecificPaths_parent) for task layDownInstaller to next action (genCreateDomain_parent) -->
  <action name="post-layDownInstaller-genPlatformSpecificPaths_parent"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => genCreateDomain_parent)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (genPlatformSpecificPaths ~ getInstallerVersion) -->
  <action name="genPlatformSpecificPaths">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => getInstallerVersion)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (getInstallerVersion ~ setBEAHome) -->
  <action name="getInstallerVersion"
	  command="getInstallerVersion.pl">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => setBEAHome)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (setBEAHome ~ buildRemoteDirs) -->
  <action name="setBEAHome">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => buildRemoteDirs)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (buildRemoteDirs ~ pushRemoteTools) -->
  <action name="buildRemoteDirs">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => pushRemoteTools)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- external callback handler (pushRemoteTools) for task layDownInstaller to next action (pushSSHKeys) -->
  <action name="post-layDownInstaller-pushRemoteTools"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => pushSSHKeys)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- external callback handler (pushRemoteTools) for task siInstaller to next action (pushSSHKeys) -->
  <action name="post-siInstaller-pushRemoteTools"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => pushSSHKeys)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (pushSSHKeys ~ remoteFetchInstaller) -->
  <action name="pushSSHKeys">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => remoteFetchInstaller)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (remoteFetchInstaller ~ genSilentXML) -->
  <action name="remoteFetchInstaller">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => genSilentXML)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (genSilentXML ~ runSilentInstall) -->
  <action name="genSilentXML">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => runSilentInstall)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (runSilentInstall ~ __SUCCESS__) -->
  <action name="runSilentInstall">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (genCreateDomain_parent ~ exitStub) -->
  <!-- use parent/child formulation for action genCreateDomain_parent -->
  <action name="genCreateDomain_parent"
	  command="spawnChildTasks.pl -algorithm ListFlagMatch -list ALL_HOSTS -flag wls_server -child genCreateDomain -s true">
    <transitionMap>
      <transition type="parent" value="ALLSUCCESS" code="$thistask->transitionTo(nextaction => exitStub)"/>
      <transition type="parent" value="ANYFAIL" code="$thistask->transitionTo(__FAILED__)"/>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(__WAITING__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (genCreateDomain ~ genDomainWLST) -->
  <action name="genCreateDomain">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => genDomainWLST)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (genDomainWLST ~ __SUCCESS__) -->
  <action name="genDomainWLST">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (exitStub ~ __SUCCESS__) -->
  <action name="exitStub"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

],
	    #test 12
	    q[  <!-- simple chain (action1 ~ action2) -->
  <action name="action1">
    <transitionMap>
      <transition type="returnCode" value="1" code="$thistask->transitionTo(nextaction => oneAction)"/>
      <transition type="returnCode" value="2" code="$thistask->transitionTo(nextaction => twoAction)"/>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => action2)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (action2 ~ final) -->
  <action name="action2">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => wacky)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(nextaction => crazy)"/>
    </transitionMap>
  </action> 

  <!-- simple chain (final ~ __SUCCESS__) -->
  <action name="final">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

],
	    #test 13
	    q[  <!-- simple chain (genDomainWLST ~ fetchDomain) -->
  <action name="genDomainWLST">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => fetchDomain, mapper => q(s/_adminserver_//;))"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (fetchDomain ~ pushDomain_parent) -->
  <action name="fetchDomain">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => pushDomain_parent)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (pushDomain_parent ~ asBootstrapExitStub) -->
  <!-- use parent/child formulation for action pushDomain_parent -->
  <action name="pushDomain_parent"
	  command="spawnChildTasks.pl -algorithm UniqueList -list ALL_MANAGEDSERVERS -unique host -child pushDomain">
    <transitionMap>
      <transition type="parent" value="ALLSUCCESS" code="$thistask->transitionTo(nextaction => asBootstrapExitStub)"/>
      <transition type="parent" value="ANYFAIL" code="$thistask->transitionTo(__FAILED__)"/>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(__WAITING__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (pushDomain ~ __SUCCESS__) -->
  <action name="pushDomain">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (asBootstrapExitStub ~ __SUCCESS) -->
  <action name="asBootstrapExitStub">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

],
	    #test 14
	    q[  <!-- dependency chain (dependsonStep1 ~ dependency_dependsonStep1) -->
  <action name="dependsonStep1"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0"
                  code="$thistask->transitionTo(nextaction => Step1, callback => $thistask->getProperty(actionname))">
         <scope field="$(history.Step1.succeeded)" value="^$"/>
      </transition>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => dependency_dependsonStep1, mapper => q(s/_adminserver_//;))"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (dependency_dependsonStep1 ~ nextStep) -->
  <action name="dependency_dependsonStep1"
	  command="dependsonStep1.sh">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => nextStep, mapper => q(s/_adminserver_//;))"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- dependency chain (nextStep ~ dependency_nextStep) -->
  <action name="nextStep"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0"
                  code="$thistask->transitionTo(nextaction => Step1, callback => $thistask->getProperty(actionname))">
         <scope field="$(history.Step1.succeeded)" value="^$"/>
      </transition>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => dependency_nextStep)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (dependency_nextStep ~ __SUCCESS) -->
  <action name="dependency_nextStep"
	  command="hardcodedCommand">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

],
	    #test 15
	    q[  <!-- dependency chain (dependsonStep1andStep2 ~ dependency_dependsonStep1andStep2) -->
  <action name="dependsonStep1andStep2"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0"
                  code="$thistask->transitionTo(nextaction => Step1, callback => $thistask->getProperty(actionname))">
         <scope field="$(history.Step1.succeeded)" value="^$"/>
      </transition>
      <transition type="returnCode" value="0"
                  code="$thistask->transitionTo(nextaction => Step2, callback => $thistask->getProperty(actionname))">
         <scope field="$(history.Step2.succeeded)" value="^$"/>
      </transition>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => dependency_dependsonStep1andStep2, mapper => q(s/_adminserver_//;))"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (dependency_dependsonStep1andStep2 ~ nextStep) -->
  <action name="dependency_dependsonStep1andStep2"
	  command="dependsonStep1andStep2.sh">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => nextStep, mapper => q(s/_adminserver_//;))"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (nextStep ~ __SUCCESS) -->
  <action name="nextStep">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

],
	    #test 16
	    q[  <!-- dependency chain (entryAction ~ dependency_entryAction) -->
  <action name="entryAction"
	  command="exit 0">
    <transitionMap>
      <transition type="returnCode" value="0"
                  code="$thistask->transitionTo(nextaction => dependAction, callback => $thistask->getProperty(actionname))">
         <scope field="$(history.dependAction.succeeded)" value="^$"/>
      </transition>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => dependency_entryAction)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (dependency_entryAction ~ endAction) -->
  <action name="dependency_entryAction"
	  command="entryAction.sh">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => endAction)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (endAction ~ __SUCCESS__) -->
  <action name="endAction">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

],
	    #test 17
	    q[  <!-- simple chain (suppress1 ~ suppress2) -->
  <action name="suppress1">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => suppress2)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

  <!-- simple chain (suppress3 ~ __SUCCESS__) -->
  <action name="suppress3">
    <transitionMap>
      <transition type="returnCode" value="0" code="$thistask->transitionTo(nextaction => __SUCCESS__)"/>
      <transition type="returnCode" value="\d+" code="$thistask->transitionTo(q(__FAILED__))"/>
    </transitionMap>
  </action> 

],
	    );

1;

	    
