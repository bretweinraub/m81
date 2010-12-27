
column tag format A30
column value format A30
set pages 300
set lines 300

select
-- 		lpad(tag,length(tag) + LEVEL-1,' ') || '=' || value || '(' || task_context_id || ',' || parent_task_context_id || ')',
		SYS_CONNECT_BY_PATH(tag, '->') || '=' || value
--		tag,
--		value,
--		LEVEL 
from 		task_context 
start with 	task_context_id = &&task_context_id
connect by 	prior task_context_id = parent_task_context_id
order siblings by tag
/

select
 		lpad(tag,length(tag) + LEVEL-1,' ') || '=' || value || '(' || task_context_id || ',' || parent_task_context_id || ')'
--		SYS_CONNECT_BY_PATH(tag, '->') || '=' || value
--		tag,
--		value,
--		LEVEL 
from 		task_context 
start with 	task_context_id = &&task_context_id
connect by 	prior task_context_id = parent_task_context_id
order siblings by tag
/
