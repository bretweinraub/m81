-- -*-perl-*-
-- M80_VARIABLE RDBMS_TYPE
-- M80_VARIABLE MODULE_NAME
-- M80_VARIABLE SEQ_INCREMENT_NO
-- M80_VARIABLE SEQ_INCREMENT_VAL

m4_include(m4/base.m4)
m4_include(db/generic/tables.m4)
m4_include(db/RDBMS_TYPE/RDBMS_TYPE.m4)

createM80StandardTable(context_summary,
		       (
			LRA_FIXED_DBNAME	varchar2(32),
			FLATRUNSETNAME		varchar2(256),
			NUM_USERS		number
			),(task),,(INSTANTIATION_TABLE=true))





			
