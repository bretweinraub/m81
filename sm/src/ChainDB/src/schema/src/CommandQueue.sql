-- -*-perl-*-
-- M80_VARIABLE RDBMS_TYPE
-- M80_VARIABLE MODULE_NAME
-- M80_VARIABLE SEQ_INCREMENT_NO
-- M80_VARIABLE SEQ_INCREMENT_VAL

m4_include(m4/base.m4)
m4_include(db/generic/tables.m4)
m4_include(db/RDBMS_TYPE/RDBMS_TYPE.m4)

createM80StandardTable(task_command_queue,
		       (
			command			varchar2(4000),
			result_code		number,
			result_message		varchar2(512),
			is_processed		varchar2(1) default	'N' constraint task_command_ckcprocess check (is_processed is null or is_processed in ('Y', 'N')),
			at_time			DATE,
			),(task,action),,(INSTANTIATION_TABLE=true))


