-- $m80path = [{command => "embedperl"   }] -- -*-sql-*-




	
create	or replace VIEW CURRENTLY_RUNNING_V AS
select	task.task_id,
	task.taskname,
	task.status,
	task.updated_dt,
where	task.task_id = Description.task_id(+)
and	Description.tag(+) = 'Description'
and	task.task_id = adminserver_jvm_params.task_id(+)
and	adminserver_jvm_params.tag(+) = '_adminserver_jvm_params'
and	task.task_id = lrtest_urlOverride.task_id(+)
and	lrtest_urlOverride.tag(+) = '_lrtest_urlOverride'
and	task.task_id = collections.task_id(+)
and	collections.tag(+) = 'collections'
and	task.task_id = ALL_J2EEAPPS.task_id(+)
and	ALL_J2EEAPPS.tag(+) = 'ALL_J2EEAPPS'
and	task.task_id = adminserver_host.task_id(+)
and	adminserver_host.tag(+) = '_adminserver_host'
and	task.task_id = ALL_HOSTS.task_id(+)
and	ALL_HOSTS.tag(+) = 'ALL_HOSTS'
and	task.task_id = runSetName.task_id(+)
and	runSetName.tag(+) = 'runSetName'
and	task.task_id = SyncTo.task_id(+)
and	SyncTo.tag(+) = 'SyncTo'
and	task.task_id = matchedInstaller_p4change.task_id(+)
and	matchedInstaller_p4change.tag(+) = 'matchedInstaller_p4change'
and	task.task_id = propertyGroups.task_id(+)
and	propertyGroups.tag(+) = 'propertyGroups'
and	task.status in ('running', 'waiting', 'queued')
and	parent_task_id is null
order	by task.task_id asc
