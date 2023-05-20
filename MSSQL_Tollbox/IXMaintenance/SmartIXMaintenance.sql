USE [msdb]
GO

/****** Object:  Job [MAINT_REBUILD_DBS_PRD_0-05]    */
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Maint_REORG]    ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Maint_REORG' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Maint_REORG'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'MAINT_REBUILD_DBS_PRD_0-05', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'REORG INDEXES TO ALL DATABASES THAT HAVE SIZE IN THE RANGE OF 0-05GB', 
		@category_name=N'Maint_REORG', 
		@owner_login_name=N'svc_sql_maint_ix', 
		@notify_email_operator_name=N'Operator_Maint_IX_PRD', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step_CHECK_LOG_DISKSPACE_PROD]    Script Date: 20/05/2023 15:23:28 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step_CHECK_LOG_DISKSPACE_PROD', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @sizeLog INT;

EXECUTE sp_dbaGetLogSize
 @outSize = @sizeLog OUTPUT;

IF (@sizeLog  > 50)
		PRINT ''Tamanho do DISK do LOG SUFICIENTE para rodar REORG > 50GB'';
		
ELSE	
		--PRINT ''Tamanho do DISK do LOG INSUFICIENTE!'';
		THROW 50000, ''Tamanho do DISK do LOG INSUFICIENTE! < 50GB'',1;

PRINT @sizeLog
GO
', 
		@database_name=N'master', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step_REORG_PRD_0-05]    Script Date: 20/05/2023 15:23:28 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step_REORG_PRD_0-05', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE master;

DECLARE @OutPutList VARCHAR(MAX) = '''';

EXEC dbo.Maint_IX_GetListOfDB_NAMES_BY_Size
0,
05,
@OutPutList OUTPUT;

SELECT @OutPutList AS ListOfDBs;

EXECUTE master.dbo.IndexOptimize
@Databases = @OutPutList,
@Indexes = ''ALL_INDEXES'',
@FragmentationLow = NULL,
@FragmentationMedium = ''INDEX_REORGANIZE'',
@FragmentationHigh = ''INDEX_REBUILD_ONLINE,INDEX_REORGANIZE'',
@FragmentationLevel1 = 20,--************************************************* ADJUST IN PROD
@FragmentationLevel2 = 60,--************************************************* ADJUST IN PROD
@MinNumberOfPages = 2000, --************************************************* ADJUST IN PROD
@MaxDOP = 16,              --************************************************* ADJUST IN PROD
@FillFactor = 100,
@UpdateStatistics = NULL,
@OnlyModifiedStatistics =  ''Y'',
@StatisticsSample = 70,
--@StatisticsResample = ''Y'',
@TimeLimit = 7200,
@Delay = 5,                 --************************************************* ADJUST IN PROD
--@Resumable = ''Y'',
@SortInTempdb = ''Y'',
@LogToTable = ''Y'',
@Execute = ''Y''             --************************************************* ADJUST IN PROD
GO
', 
		@database_name=N'master', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule_REORG_PRD_0-05', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=64, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20230520, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e0b59dc0-0737-457c-b268-82a80ac8637c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

