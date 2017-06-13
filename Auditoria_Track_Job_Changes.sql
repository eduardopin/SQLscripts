USE msdb 
GO 
Alter TRIGGER tr_SysJobs_enabled 
ON sysjobs 
FOR UPDATE AS 
---------------------------------------------------------------------------- 
-- Object Type : Trigger 
-- Object name : msdb..tr_SysJobs_enabled 
-- Description : trigger to email DBA team when a job is enabled or disabled 
---------------------------------------------------------------------------- 
SET NOCOUNT ON 

DECLARE @Username VARCHAR(50), 
@Hostname VARCHAR(50), 
@Jobname VARCHAR(100), 
@DeletedJobname VARCHAR(100), 
@New_enabled INT, 
@Old_enabled INT, 
@BodyText VARCHAR(200), 
@SubjectText VARCHAR(200),
@Servername VARCHAR(50),
@MailProfile VARCHAR(50)

SELECT @Username = SYSTEM_USER, @Hostname = HOST_name() 
SELECT @New_enabled = enabled FROM Inserted 
SELECT @Old_enabled = enabled FROM Deleted 
SELECT @Jobname = name FROM Inserted 
SELECT @Servername = @@servername
Select @MailProfile = (select name from sysmail_profile)

-- check if the enabled flag has been updated.
IF @New_enabled <> @Old_enabled 
BEGIN 

  IF @New_enabled = 1 
  BEGIN 
    SET @BodyText = 'User: '+@Username+' from '+@Hostname+
        ' enabled SQL Job ['+@Jobname+'] at '+CONVERT(VARCHAR(20),GETDATE(),100) 
    SET @SubjectText = @Servername+' : ['+@Jobname+
        '] has been enabled at '+CONVERT(VARCHAR(20),GETDATE(),100) 
  END 

  IF @New_enabled = 0 
  BEGIN 
    SET @BodyText = 'User: '+@Username+' from '+@Hostname+
        ' DISABLED SQL Job ['+@Jobname+'] at '+CONVERT(VARCHAR(20),GETDATE(),100) 
    SET @SubjectText = @Servername+' : ['+@Jobname+
        '] has been DISABLED at '+CONVERT(VARCHAR(20),GETDATE(),100) 
  END 

  SET @SubjectText = 'SQL Server, JOB ' + @SubjectText 


  -- send out alert email
  EXEC msdb.dbo.sp_send_dbmail 
  @profile_name = @MailProfile, --<<< insert your Mail Profile here
  @recipients = 'grpdba@marisa.com.br',
  @copy_recipients = 'operacao@marisa.com.br', --<<< insert your team email here
  @body = @BodyText, 
  @subject = @SubjectText 

END

-- drop trigger tr_SysJobs_enabled 