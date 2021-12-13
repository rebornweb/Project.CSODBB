USE [msdb]
GO


/****** Object:  Job [Reload SAS2IDM for SSIS]    Script Date: 1/11/2021 2:53:26 PM ******/
BEGIN TRANSACTION

-- Parameters Section
DECLARE @JobName VARCHAR(100) = N'Reload SAS2IDM MIM Data for All Schools',
	@OwnerName VARCHAR(100) = N'DBB\svcSSIS',
	@StepName VARCHAR(100) = N'Execute SAS2IDM MIM.Replicate SSIS Package',
	@ISServer VARCHAR(100) = N'"\"\SSISDB\SAS2IDM\MIM.Replicate\Package.dtsx',
	@Server VARCHAR(100) = N'"\".',
	@Source_ServerName VARCHAR(500) = N'D-OCCCP-IM301',
	@Target_ServerName VARCHAR(500) = N'OCCCP-DB222',
	@SourceDB_FIMSynchronizationService_InitialCatalog VARCHAR(500) = N'FIMSynchronizationService',
	@TargetDB_MIMSyncReplica_InitialCatalog VARCHAR(500) = N'MIM_SyncReplica'

DECLARE @Cmd VARCHAR(MAX)
SET @Cmd = N'/ISSERVER ' + @ISServer + N'\"" /SERVER ' + @Server + N'\"" /Par "\"Source_ServerName\"";"\"' + @Source_ServerName + N'\"" /Par "\"Target_ServerName\"";"\"' + @Target_ServerName + N'\"" /Par "\"SourceDB_FIMSynchronizationService_InitialCatalog\"";"\"' + @SourceDB_FIMSynchronizationService_InitialCatalog + N'\"" /Par "\"TargetDB_MIMSyncReplica_InitialCatalog\"";"\"' + @TargetDB_MIMSyncReplica_InitialCatalog + N'\"" /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";3 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E';

DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 1/11/2021 2:53:26 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
select @jobId = job_id from msdb.dbo.sysjobs where (name = @JobName)
if (@jobId is NULL)
BEGIN
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@JobName, 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Execute SAS2IDM MIM.Replicate SSIS Package according to supplied parameters.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=@OwnerName, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END
/****** Object:  Step [Execute SAS2IDM Reconciliation SSIS Package]    Script Date: 1/11/2021 2:53:26 PM ******/
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 1)
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=@StepName, 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=@Cmd, 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'svcSSIS'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


