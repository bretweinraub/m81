
--
-- I believe by outer joining the task table; we can identify which tasks have created no children.
-- 

create 	or replace view 
	CHILD_STATUS_V
AS
select	parentV.task_id,
	num_children,
	parent_status,
	child_status,
	nvl(num_child_tasks,0) num_child_tasks,
	task_name,
	taskname,
	cur_action_id action_id,
	actionname
from	num_children_v parentV,
	(
		select 	parent_task_id task_id,
			status child_status,
			count(*) num_child_tasks
		from	task
		where	parent_task_id is not null
		and	processed is null
		group	by
			parent_task_id,
			status
	) childV,
	task_v
where	parentV.task_id = childV.task_id(+)
and	parentV.task_id = task_v.task_id
