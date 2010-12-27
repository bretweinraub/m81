
BEGIN
	execute immediate 'alter table action drop constraint action_ckc1';
EXCEPTION
	when others then
		NULL;
END;
/


alter table action
      add constraint action_ckc1 check ( actionstatus in ('new','analyzing', 'starting', 'started','running', 'succeeded','failed','recovering', 'finished','retry','error','waiting', 'queued'));
