-- M80_VARIABLE RDBMS_TYPE
-- M80_VARIABLE MODULE_NAME
-- M80_VARIABLE SEQ_INCREMENT_NO
-- M80_VARIABLE SEQ_INCREMENT_VAL

m4_include(m4/base.m4)
m4_include(db/generic/tables.m4)
m4_include(db/RDBMS_TYPE/RDBMS_TYPE.m4)

alter table
	task add (parent_task_id number(10));

_foreignKeyCustom(task,task,3,parent_task_id)

alter table 
	task add (is_parent flagField)
/

alter table
	task add constraint is_parent_ckcparent check (is_parent in ('Y', 'N'))
/

update task
	set is_parent = 'N'
/

commit;




