create  or replace  view failedtask
as
select 	task.task_id,
        lpad('X',3*(l-1)) indent,
	lpad(' ',3*(l-1)) || task.taskname taskname,
	task.taskname taskname_,
	l level_,
        actionname,
	task.status,
	actionstatus,
        actionpid pid,
        parent_task_id,
	cur_action_id,
	numfailures fails,
	decode (actionstatus, 'running', to_char((SYSDATE - action.inserted_dt) * (86400)),
				  	 (nvl(action.updated_dt,SYSDATE) - action.inserted_dt) * (86400)) secs,
        task.inserted_dt,
	action.updated_dt,
	task.mapper || action.actionmapper mapper,
	r rownum_,
	actionpid,
	numfailures
from	task,
	( 
		select task_id,
	               l,
		       rownum r
		from   (
			select 	task_id, 
				level l
			from 	task  
			start with 
			      	task_id in (select task_id from task where parent_task_id is null and status in ('failed', 'canceled'))
			connect by prior 
				task_id = parent_task_id 
			order	siblings 
			by      task_id
			)
	) iv,
	action
where	task.task_id= iv.task_id
and	task.cur_action_id = action.action_id
and	task.status in ('failed','canceled')
order	by r
