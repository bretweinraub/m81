-- CREATE or replace TYPE contextObj AS OBJECT
-- (
-- 	node varchar2(4000)
-- )
-- /
-- 
-- 
-- CREATE TYPE contextObjTable AS TABLE OF contextObj
-- /

create or replace function context
(
	tci   task_context.task_context_id%type
)
RETURN contextObjTable PIPELINED
IS
	Cursor c1 is 
	select
 		lpad(tag,length(tag) + LEVEL-1,' ') || '=' || value || '(' || task_context_id || ',' || parent_task_context_id || ')' node
	from 		task_context 
	start with 	task_context_id = context.tci
	connect by 	prior task_context_id = parent_task_context_id
	order siblings by tag;

	outRec contextObj  := contextObj(NULL);

BEGIN
	for rec in c1 LOOP
		outRec.node := rec.node;
		pipe row(outRec);
	END LOOP;
	RETURN;
END;
