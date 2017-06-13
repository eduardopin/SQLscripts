USE [msdb]
GO

/****** Object:  Job [DBA - Check  File Group Space]    Script Date: 05/04/2013 11:35:23 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 05/04/2013 11:35:23 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Check  File Group Space', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'CENTRAL\usrMSSQL', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Filegroup]    Script Date: 05/04/2013 11:35:24 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Filegroup', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON
DECLARE @cmdSQL AS VARCHAR (350)
CREATE TABLE ##tbFileStats (
[fileId] SMALLINT PRIMARY KEY,
[fileGroup] SMALLINT NOT NULL,
[totalExtents] INT NOT NULL,
[usedExtents] NUMERIC(12,0) NOT NULL,
[name] VARCHAR(256) NOT NULL,
[fileName] VARCHAR(256) NOT NULL)

SET @cmdSQL = ''INSERT INTO ##tbFileStats EXEC (''''USE BODS_ADMIN  DBCC SHOWFILESTATS'''')''
EXEC (@cmdSQL)

IF EXISTS (SELECT 1
		FROM ##tbFileStats a
			INNER JOIN BODS_ADMIN.dbo.sysfilegroups b
				ON a.[fileGroup] = b.[groupid]
		GROUP BY b.[groupname]
		HAVING 	SUM((([totalExtents]-[usedExtents])*64)/1024.0) < 500000 )

			
					
					EXEC msdb..sp_send_dbmail 	@profile_name = ''DBA'',
					@recipients = ''grpDBA@marisa.com.br;operacao@marisa.com.br'',
					@body = ''MARI216\BOP BODS_ADMIN , Verificar espaço livre nos FILEGROUPs abaixo:'',
					@query = ''SET NOCOUNT ON 
				SELECT  CAST(b.[groupname] AS VARCHAR(10)) AS [FILEGROUP], 
					CAST(SUM(([totalExtents]*64)/1024.0) AS NUMERIC(10,2)) AS [SPACE_TOTAL (MB)],  
					CAST(SUM((([totalExtents]-[usedExtents])*64)/1024.0) AS NUMERIC(10,2)) AS [FREE_SPACE (MB)], 
					CAST(SUM((([totalExtents]-[usedExtents])*64)/1024.0)/SUM(([totalExtents]*64)/1024.0)*100  AS NUMERIC(5,2)) AS [PERCENT_FREE]
				FROM ##tbFileStats a
					INNER JOIN BODS_ADMIN..sysfilegroups b
						ON a.[fileGroup] = b.[groupid]
				GROUP BY CAST(b.[groupname] AS VARCHAR(10))
				HAVING 	SUM((([totalExtents]-[usedExtents])*64)/1024.0) < 500000'',
					@subject = ''MARI216\BOP BODS_ADMIN, FILEGROUP FREE SPACE < 5 Gb! Verificar com Urgencia!!! ***''
					
DROP TABLE ##tbFileStats', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Check Filegroup', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20120905, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'8633eb4a-d63a-44c4-95b9-07c84e1b2fba'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


