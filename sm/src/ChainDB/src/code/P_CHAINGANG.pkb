-- -*-sql-*- --
-----------------------------------------------------------------
-- Package:		P_CHAINGANG
--
-- Date:		
--
-- Description:		
--
-----------------------------------------------------------------
--
PROMPT Creating PACKAGE BODY P_CHAINGANG.
CREATE OR REPLACE PACKAGE BODY P_CHAINGANG AS

PROCEDURE REGISTER 
(
	chaingang_name chaingang.chaingang_name%type,
	hostname chaingang.hostname%type,
	pid	number
)
IS
BEGIN
	BEGIN
		insert into chaingang
		(
			chaingang_name,
			hostname,
			pid
		)
		select	register.chaingang_name,
			register.hostname,
			pid
		from	dual;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN
			null;
	end;

	update 	chaingang set
		pid = register.pid,
		hostname = register.hostname
	where	chaingang_name = register.chaingang_name;


	update	task
	set	status = 'abandoned'
	where	chaingang_id in
	(
		select	chaingang_id
		from	chaingang
		where	chaingang_name = register.chaingang_name
	);

END;

END;
