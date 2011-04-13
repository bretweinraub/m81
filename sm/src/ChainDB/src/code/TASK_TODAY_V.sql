-- $m80path = [{command => "embedperl.pl"}]



create	or replace view	TASK_TODAY_V AS
select	task_v.*,
	'<a href="http://localhost:80/bond-demo/taskData/' || task_v.task_id || '/">link</a>' ETL_LOG_FILES,
	decode (tcv.value, null, 'N/A',
		'<a href="http://localhost:80/bond-demo/stage/' || tcv.value || '/' || task_v.task_id || '/">link</a>') RESULTS_DIR,
        '<a href="/stateMachineWeb/contextviewer/begin.do?' || '&&' || '_autoscope__filter=contextViewerControllerGridName~TASK_ID~eq~' || task_v.task_id || '">link</a>' CONTEXT
from	task_v,
	(
		select 	value ,
			task_id
		from 	task_context 
		where 	tag = 'LRA_Workspace_CurrServer'
	) tcv
where 	task_inserted_dt > (SYSDATE - 1)
and	task_v.task_id = tcv.task_id(+)
order	by
	task_v.task_id desc
