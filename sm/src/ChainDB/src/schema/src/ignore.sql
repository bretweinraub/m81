-- M80_VARIABLE SCHEMA_NAME
-- M80_VARIABLE RELEASE_NUMBER
-- M80_VARIABLE MODULE_NAME
-- M80_VARIABLE SEQ_INCREMENT_NO
-- M80_VARIABLE SEQ_INCREMENT_VAL
-- M80_VARIABLE RDBMS_TYPE

m4_include(m4/base.m4)
m4_include(db/generic/tables.m4)
m4_include(db/RDBMS_TYPE/RDBMS_TYPE.m4)

ignoreException([alter table task drop constraint task_ckc1],-2443)

m4_define(states, ['new','analyzing', 'starting', 'started','running', 'succeeded','failed','recovering', 'finished','retry','error','queued','cancel','canceled'])

addCheckConstraint(task,((status, , (states))))
