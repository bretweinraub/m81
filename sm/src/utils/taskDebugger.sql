-- use script for debugging tasks

set pages 300
set lines 300

column 	taskname 	format A12
column 	status 		format A10
column 	actionname 	format A30
column 	failurereason 	format A70

select 	task_id,
	taskname,
	status,
	actionname,
	failurereason,
	parent_task_id,
	actionpid
from 	task_v
where	TASK_INSERTED_DT > sysdate - 1/240
order by
	task_id desc
/

