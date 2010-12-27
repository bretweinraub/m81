-- M80_VARIABLE RDBMS_TYPE                                                                                                                                                                                                      
-- M80_VARIABLE MODULE_NAME                                                                                                                                                                                                      
-- M80_VARIABLE SEQ_INCREMENT_NO                                                                                                                                                      
-- M80_VARIABLE SEQ_INCREMENT_VAL                                                                                                        

m4_include(m4/base.m4)
m4_include(db/generic/tables.m4)
m4_include(db/RDBMS_TYPE/RDBMS_TYPE.m4)

m4_define([dropIndex],[ignoreException([drop index $1],-1418)])m4_dnl

dropIndex( action_task_id_idx );

ignoreException([create index action_ta on action (task_id, action_id)],-0955)
ignoreException([create index task_ta on task (task_id, cur_action_id)],-0955)



