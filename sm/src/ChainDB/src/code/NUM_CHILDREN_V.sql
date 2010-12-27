create 	or replace view 
	NUM_CHILDREN_V 
AS
select	task.task_id,
	task.status parent_status,
	nvl(num_children,0) num_children
from	(
		select 	parent_task_id task_id,
		count	(*) num_children
		from	task
		where	parent_task_id is not null
		and	processed is null
		group	by parent_task_id
	) parents,
	task
	where task.task_id = parents.task_id(+)
