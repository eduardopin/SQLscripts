USE [msdb]
GO

/****** Object:  Job [DBA - CHECK DISK SPACE]    Script Date: 05/04/2013 11:35:30 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 05/04/2013 11:35:30 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - CHECK DISK SPACE', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Verifica o espaço em disco disponivel no servidor.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'CENTRAL\usrMSSQL', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Verifica espaço em disco]    Script Date: 05/04/2013 11:35:30 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Verifica espaço em disco', 
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

CREATE TABLE ##tbDriveSpace (
drive CHAR(1) NOT NULL,
mbFree INT NOT NULL )

INSERT INTO ##tbDriveSpace
EXEC master..xp_fixeddrives


IF EXISTS ( SELECT 1 FROM ##tbDriveSpace
	WHERE	(drive = ''C'' AND mbFree < 500000)
	OR           (drive = ''D'' AND mbFree < 5000)
		OR	(drive = ''E'' AND mbFree < 5000)
		OR	(drive = ''F'' AND mbFree < 5000)
		OR	(drive = ''G'' AND mbFree < 5000)
		OR	(drive = ''H'' AND mbFree < 5000)
		OR	(drive = ''I'' AND mbFree < 5000)
		OR	(drive = ''J'' AND mbFree < 5000)
		OR	(drive = ''K'' AND mbFree < 5000)
		OR	(drive = ''L'' AND mbFree < 5000))
	
	EXEC msdb..sp_send_dbmail 	@profile_name = ''DBA'',
					@recipients = ''grpDBA@marisa.com.br;operacao@marisa.com.br'',
					@body =  ''MARI216 SAP CRM  Com pouco espaço em disco, avisar os administradores. Verificar espaço livre em disco nos drives abaixo:'',
					@query = ''SET NOCOUNT ON 
			SELECT drive AS DRIVE, mbFree AS MB_FREE FROM ##tbDriveSpace
			WHERE	(drive = ''''C'''' AND mbFree < 5000)
	OR  (drive = ''''D'''' AND mbFree < 5000)
	OR	(drive = ''''E'''' AND mbFree < 5000)
	OR	(drive = ''''F'''' AND mbFree < 5000)
	OR	(drive = ''''G'''' AND mbFree < 5000)
	OR	(drive = ''''H'''' AND mbFree < 5000)
	OR	(drive = ''''I'''' AND mbFree < 5000)
	OR	(drive = ''''J'''' AND mbFree < 5000)
	OR	(drive = ''''K'''' AND mbFree < 5000)
	OR	(drive = ''''L'''' AND mbFree < 5000)'',
					@subject = ''MARI216 DISK SPACE - NÍVEL BAIXO!''
DROP TABLE ##tbDriveSpace', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'check disk space', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20111214, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'9a140a75-ea6d-41a4-a11b-06f7dd6e8c9a'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


