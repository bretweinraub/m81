
alter table task drop constraint task_ckc1;

alter table task
      add constraint task_ckc1 check ( status in ('new','analyzing', 'starting', 'started','running', 'succeeded','failed','recovering', 'finished','retry','error','waiting', 'queued'));
