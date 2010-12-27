-- local objects -*-perl-*-
--
--
-- createM80[]StandardTable
-- Arg1 => tablename
-- Arg2 => custom columns In a list
-- Arg3 => List of reference tables
-- Arg4 => a List of check constraints
-- (checkConstraint1 [, .... checkConstraint1n])
-- where each check constraint is of form
-- (field, nullflag, (list of values))
--
-- some useful tokens:
-- varcharType
-- INSTANTIATION_TABLE
-- datetime
-- bigNumber
--
--
-- if nullflag is blank, nulls are not allowed
-- Arg5 => list of arguments of form (flag1,flag2=value2,flag3

m4_define(maxNodeLength,64)
m4_define(booleanField,varcharType(16))
m4_define(booleanCheck,[($1, , ('true','false'))])
m4_define(states, ['new','analyzing', 'starting', 'started','running', 'succeeded','failed','recovering', 'finished','retry','error'])

createM80StandardTable(chainGang,
		       (
			hostname        varcharType(32) not null,
			PID             bigNumber not null
			),,,)

createM80StandardTable(global_namespace,
		       (
			tag    varcharType(64),
			value  varcharType(4000)
			),(chainGang),,(INSTANTIATION_TABLE=true))


createM80StandardTable(task,
		       (
			status      varcharType(32),
			taskName  varcharType(64),
--			actionName  varcharType(64),
--			numFailures bigNumber default 0,
--			actionStatus varcharType(32),
			failureReason varcharType(256),
			cur_action_id bigNumber
--			actionPid bigNumber
			),(chainGang),(
				       (status, , (states))
				       ),)

createM80StandardTable(task_namespace,
		       (
			tag    varcharType(64),
			value  varcharType(4000)
			),
		       (task),,(INSTANTIATION_TABLE=true))


createM80StandardTable(task_log,
		       (
			log_msg varcharType(4000),
			return_code bigNumber
			),(task),,(INSTANTIATION_TABLE=true))

createM80StandardTable(action,
		       (
			actionName  varcharType(64),
			numFailures bigNumber default 0,
			actionStatus varcharType(32),
			actionPid bigNumber,
			outputurl varcharType(256),
			actionSequence bigNumber not null
			),(task),
		       ((actionStatus, , (states))),(INSTANTIATION_TABLE=true))

alter table task
      add constraint task_FK2 foreign key  (cur_action_id)
       references action (action_id);
