column an format A65
column status format A10
column actionname format A10
column mapper format A20
column status format A10
column actionstatus format A12
column secs format A6
column callbacks format A80
set lines 300
set pages 300


select 	lpad(' ',3*(l-1)) || task.taskname || '.' || actionname an, 
	action.task_id, 
	task.mapper || action.mapper mapper,
	status,
	actionstatus,
	action_id,
	decode (actionstatus, 'running', to_char((SYSDATE - action.inserted_dt) * (86400)),
				  	 (nvl(action.updated_dt,SYSDATE) - action.inserted_dt) * (86400)) secs,
	action.callbacks 
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
