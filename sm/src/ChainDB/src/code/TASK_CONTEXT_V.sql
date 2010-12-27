create or replace view task_context_v as
select task_context.* , 'task_context' source_table  from task_context

