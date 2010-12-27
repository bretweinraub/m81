column an format A70
column status format A10
column actionname format A10
column mapper format A20
column status format A20
column date format A20
column actionstatus format A20
column secs format 999
set lines 300
set pages 300


select 	lpad(' ',3*(l-1)) || task.taskname || '.' || actionname an, 
	action.task_id, 
	task.mapper || action.mapper mapper,
	status,
	actionstatus,
	action_id,
	action.updated_dt,
	(action.updated_dt - action.inserted_dt) * (86400) secs,
	nvl(to_char(action.actionpid), 'N/A') actionpid
from 	action,
	task,
	( 
		select 	task_id, 
			level l
		from 	task  
		start with 
			task_id = 	(
						select 	max(task_id)
						from	task
						where	taskname = '&taskName'
					)
		connect by prior 
			task_id = parent_task_id 
	) iv
where 	action.task_id = iv.task_id
and	task.task_id = action.task_id
order by 
	action_id
/
