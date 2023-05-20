DECLARE @max INT;
SELECT  @max = max_workers_count
FROM    sys.dm_os_sys_info;

SELECT  @max - SUM (active_workers_count) AS [AvailableThreads]
FROM    sys.dm_os_schedulers
WHERE   status = 'VISIBLE ONLINE';

select *
from sys.dm_os_sys_info
