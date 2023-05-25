
USE msdb
go

DECLARE @TimeSeconds INT = 0

SELECT @TimeSeconds = DATEDIFF(SECOND,aj.start_execution_date,GetDate())  
FROM msdb..sysjobactivity aj  
JOIN msdb..sysjobs sj on sj.job_id = aj.job_id  
WHERE aj.stop_execution_date IS NULL -- job hasn't stopped running  
AND aj.start_execution_date IS NOT NULL -- job is currently running  
AND sj.name = 'ExecutaOLAP'--job name  
and not exists( -- make sure this is the most recent run  
    select 1  
    from msdb..sysjobactivity new  
    where new.job_id = aj.job_id  
    and new.start_execution_date > aj.start_execution_date  
)


PRINT @TimeSeconds

--28800 -- 8 hours
--21600 -- 6 Hours
IF @TimeSeconds > 28800 -- 8 hours

BEGIN

DECLARE @TimeText VARCHAR(MAX) = '0'

   PRINT 'Job ExecutaOLAP has been running for more than 8 hours: ' + CAST((@TimeSeconds/3600) as VARCHAR) + ' hours';
   SET @TimeText = 'LONG RUNNING JOB ExecutaOLAP > 8 hours! It has been executed for: ' + CAST((@TimeSeconds/3600) as VARCHAR) + ' hours';


   --send email 
    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'DBA_Email_Profile_PRD',
        @recipients = 'dba@company.com'
        ,@subject = 'LONG RUNNING JOB: ExecutaOLAP'
        ,@body = @TimeText
        ,@body_format = 'TEXT'
        ,@importance = 'High';
END
ELSE
BEGIN
	PRINT 'JOB ACTIVITY NORMAL'
END

