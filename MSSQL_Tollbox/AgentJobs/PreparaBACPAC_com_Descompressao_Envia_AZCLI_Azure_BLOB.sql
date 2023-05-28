USE [msdb]
GO

/****** Object:  Job [Backup_DBNAME_for_BACPAC]    Script Date: 28/05/2023 10:37:03 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 28/05/2023 10:37:04 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup_DBNAME_for_BACPAC', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Takes a copy only full backup for DBNAME bacpack. The restore database from this backup will be used to remove a UTC Funcion and assembly that produces an error to DBNAME Client when they try to Import on their environment.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'Operator_Maint_IX_PRD', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop database]    Script Date: 28/05/2023 10:37:06 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop database', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use [master]
GO

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N''DBA_AppName.DBNAME_BI_PRD''
GO

use [DBA_AppName.DBNAME_BI_PRD]
GO

USE [master]
GO

ALTER DATABASE [DBA_AppName.DBNAME_BI_PRD] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

USE [master]
GO
/****** Object:  Database [DBA_AppName.DBNAME_BI_PRD]    Script Date: 3/29/2023 11:43:40 PM ******/
DROP DATABASE [DBA_AppName.DBNAME_BI_PRD]
GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Take Backup FULL Copy_only]    Script Date: 28/05/2023 10:37:06 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Take Backup FULL Copy_only', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [AppName.DBNAME] 
TO  DISK = N''B:\MSSQL\backup\DBNAME\DBA_AppName.DBNAME_BI_PRD.bak''
WITH  COPY_ONLY, NOFORMAT, INIT,  NAME = N''AppName.DBNAME-Full Database Backup'', 
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 1
GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore]    Script Date: 28/05/2023 10:37:06 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
RESTORE DATABASE [DBA_AppName.DBNAME_BI_PRD] 

FROM  DISK = N''B:\MSSQL\backup\DBNAME\DBA_AppName.DBNAME_BI_PRD.bak'' 

WITH  FILE = 1, 
 
MOVE N''AppName.EALabsoft'' TO N''E:\MSSQL\data\DBA_AppName.DBNAME_BI_PRD_Data.mdf'',  

MOVE N''AppName.EALabsoft_log'' TO N''L:\MSSQL\logs\DBA_AppName.DBNAME_BI_PRD_Log.ldf'', 
NOUNLOAD, REPLACE,  STATS = 1

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step_ChangeDB_to_SIMPLEMode]    Script Date: 28/05/2023 10:37:06 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step_ChangeDB_to_SIMPLEMode', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
ALTER DATABASE [DBA_AppName.DBNAME_BI_PRD] SET RECOVERY SIMPLE WITH NO_WAIT
GO
', 
		@database_name=N'master', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DeleteUTCFunction]    Script Date: 28/05/2023 10:37:06 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DeleteUTCFunction', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBA_AppName.DBNAME_BI_PRD]


DROP FUNCTION [dbo].[ToSpecificTimeZoneFromUTC]



DROP ASSEMBLY [UserDefinedFunctions]


', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step_Turnoff_Query_store]    Script Date: 28/05/2023 10:37:07 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step_Turnoff_Query_store', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
GO

ALTER DATABASE [DBA_AppName.DBNAME_BI_PRD] SET QUERY_STORE (QUERY_CAPTURE_MODE = ALL)
ALTER DATABASE [DBA_AppName.DBNAME_BI_PRD] SET QUERY_STORE = OFF
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Disable-Compression]    Script Date: 28/05/2023 10:37:07 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Disable-Compression', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'write-host "#############"
Start-Job -ScriptBlock {$ConfirmPreference = ''None'';Set-DbaDbCompression -SqlInstance "SRV-DB-01" -Database "DBA_AppName.DBNAME_BI_PRD" -CompressionType None -Verbose -Debug -Confirm:$false} -Name ''DBNAME''
write-host "#############"
while((Get-Job -Name ''DBNAME'').state -eq ''Running''){ 
Start-Sleep -Seconds 5; 
write-host "waiting..."
}', 
		@database_name=N'master', 
		@flags=40
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [RunsBACPAC]    Script Date: 28/05/2023 10:37:07 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'RunsBACPAC', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'cd "C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin"
.\sqlpackage.exe /a:Export /tf:"B:\MSSQL\backup\DBNAME\DBA_AppName.DBNAME_BI_PRD.bacpac" /scs:"Data Source=SRV-DB-01;Initial Catalog=DBA_AppName.DBNAME_BI_PRD;Integrated Security=True;TrustServerCertificate=True"', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [AzCopyBACPAC]    Script Date: 28/05/2023 10:37:07 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'AzCopyBACPAC', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'cd "C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin"
.\azcopy.exe copy "B:\MSSQL\backup\DBNAME\DBA_AppName.DBNAME_BI_PRD.bacpac" "https://stgAppNameprd.blob.core.windows.net/DBNAME-etl?sp=racw&st=2023-03-30T17:34:32Z&se=2024-04-02T01:34:32Z&spr=https&sv=2021-12-02&sr=c&sig=nKcV3gBpunFKKbMP%2FjhnRUvEWXPmsEfwg%2F0CGBGlmaI%3D"', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'schedule_backup', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20230401, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959, 
		@schedule_uid=N'7a14a32e-4866-4bc5-a13b-53740e81176a'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


