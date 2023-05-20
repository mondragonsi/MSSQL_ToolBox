select 
req.start_time,
ses.session_id, 
command, 
blocking_session_id, 
wait_time, 
req.wait_type, 
wait_resource,
req.database_id,
req.cpu_time,
ses.total_elapsed_time,
ses.session_id,
ses.status,
dbs.name
from sys.dm_exec_requests  req
inner join sys.dm_exec_sessions ses
on req.session_id = ses.session_id
inner join sys.databases dbs
on ses.database_id = dbs.database_id
where command  = 'DB STARTUP'

