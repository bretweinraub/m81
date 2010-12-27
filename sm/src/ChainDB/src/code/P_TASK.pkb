-- -*-sql-*- --
-----------------------------------------------------------------
-- Package:		P_TASK
--
-- Date:		
--
-- Description:		
--
-----------------------------------------------------------------
--
PROMPT Creating PACKAGE BODY P_TASK.
CREATE OR REPLACE PACKAGE BODY P_TASK AS

PROCEDURE     	SET_ACTION 
(
	task_id		task.task_id%type,
	actionname	action.actionname%type
)
IS
	cur_action_id	task.cur_action_id%type;
	nextActionSequence	action.actionSequence%type;
	cur_actionname	action.actionname%type;
	
	
BEGIN

-- Algorithm:
-- First - 	Select out the current action associated to the task.
-- 
-- Second - 	If there is no action associated with the task, set it as
--			defined in the procedure argument.
--			Update the "cur_action_id" field.
-- Third -      If there is a current action defined, check to see if it is
--			the same as the procedure argument.  If it is; do nothing.
--			If it isn't ; set this as the current action and mark the
--			last action finished.
		
	select	task.cur_action_id,
		nvl(actionSequence,-1) + 1 actionSequence
	into	set_action.cur_action_id,
		nextActionSequence
	from	action,
		task
	where	task.cur_action_id = action.action_id(+)
	and	task.task_id = set_action.task_id;

--
-- No task defined. 
--
	if CUR_ACTION_ID IS NULL THEN
		insert into action
		(
			actionname,
			actionstatus,
			actionSequence,
			task_id
		) values
		(
			set_action.actionname,
			'new',
			set_action.nextActionSequence,
			set_action.task_id
		);
		
		BEGIN
			select	action_id
			into	set_action.cur_action_id
			from	action
			where	task_id = set_action.task_id
			and	actionSequence = nextActionSequence;
		EXCEPTION
			when no_data_found then
				null;
		END;

		update	task
		set	cur_action_id = set_action.cur_action_id
		where	task_id	= set_action.task_id;
	ELSE
		select	actionname
		into	set_action.cur_actionname
		from	action
		where	action_id = cur_action_id;

		if actionname <> cur_actionname THEN
			update  action
			set 	actionstatus = 'succeeded'
			where	action_id = cur_action_id;

-- insert the new row; unless it is already there
-- if it is already there; set its status to 'retry'.

			CUR_ACTION_ID := NULL;

			BEGIN
				select	action_id
				into	set_action.cur_action_id
				from	action
				where	task_id = set_action.task_id
				and	actionSequence = nextActionSequence;
			EXCEPTION
				when no_data_found then
					null;
			END;

			if CUR_ACTION_ID IS NULL THEN
				insert into action
				(
					actionname,
					actionstatus,
					actionSequence,
					task_id
				) values
				(
					set_action.actionname,
					'new',
					set_action.nextActionSequence,
					set_action.task_id
				);
-- Not sure this following begin/end block is actually needed.
				BEGIN
					select	action_id
					into	set_action.cur_action_id
					from	action
					where	task_id = set_action.task_id
					and	actionSequence = nextActionSequence;
				EXCEPTION
					when no_data_found then
						null;
				END;
			else
				update	action
				set	actionstatus = 'retry'
				where 	action_id = set_action.cur_action_id;
			end if;
	
			update	task
			set	cur_action_id = set_action.cur_action_id
			where	task_id	= set_action.task_id;
		END IF;
	END IF;
END;

END;
