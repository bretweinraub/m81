create	or replace view	TASK_V AS
select	/*+ USE_HASH(task action) */
	task.TASK_NAME,
	task.DESCRIPTION,
	task.STATUS,
	task.TASKNAME,
	task.FAILUREREASON,
	task.CUR_ACTION_ID,
	task.CHAINGANG_ID,
	task.TASK_ID,
	task.inserted_dt task_inserted_dt,
	task.updated_dt task_updated_dt,
	task.PARENT_TASK_ID,
	task.start_by,
	task.task_group,
	task.mapper,
	action.ACTIONNAME,
	action.NUMFAILURES,
	action.ACTIONSTATUS,
	action.ACTIONPID,
	action.OUTPUTURL,
	action.action_id,
	action.callbacks,
	action.actionmapper,
	action.export_filter
from	task,
	action
where	task.task_id = action.task_id(+)
and	task.cur_action_id = action.action_id(+)
