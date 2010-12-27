-- -*-perl-*-
-- M80_VARIABLE RDBMS_TYPE
-- M80_VARIABLE MODULE_NAME
-- M80_VARIABLE SEQ_INCREMENT_NO
-- M80_VARIABLE SEQ_INCREMENT_VAL

m4_include(m4/base.m4)
m4_include(db/generic/tables.m4)
m4_include(db/RDBMS_TYPE/RDBMS_TYPE.m4)

DECLARE	
   table_not_found exception;
   PRAGMA EXCEPTION_INIT(table_not_found, -942);
BEGIN
   execute immediate 'alter table task_namespace rename to task_namespace_old';
EXCEPTION
   WHEN table_not_found THEN
     NULL;
END;
/

createM80StandardTable(task_context,
		       (
			tag                             varcharType(128),
			value                           varcharType(4000),
			source                          varcharType(512),
			type                            varcharType(64),
			host                            varcharType(64),
			group_name                      varcharType(64),
			parent_task_context_id          bigNumber
			),(task),,(INSTANTIATION_TABLE=true))

_foreignKeyCustom(task_context,task_context,2,parent_task_context_id)

insert into task_context
(
	tag,
	value,
	source,
	type,
	task_id,
	is_deleted,
	inserted_dt,
	updated_dt
) 
select 	tag,
	value,
	source,
	type,
	task_id,
	is_deleted,
	inserted_dt,
	updated_dt
from	task_namespace_old;

commit;




			
