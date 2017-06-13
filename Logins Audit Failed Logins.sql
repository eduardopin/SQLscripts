--Enable trigger DBA_AUDIT on database

USE [msdb];
GO

CREATE QUEUE FailedLoginNotificationQueue;
GO

CREATE SERVICE FailedLoginNotificationService
    ON QUEUE FailedLoginNotificationQueue 
   ([http://schemas.microsoft.com/SQL/Notifications/PostEventNotification]);
GO

CREATE EVENT NOTIFICATION FailedLoginNotification
    ON SERVER WITH FAN_IN
    FOR AUDIT_LOGIN_FAILED
    TO SERVICE 'FailedLoginNotificationService', 'current database';
GO

USE [msdb];
GO

Create PROCEDURE [dbo].[ProcessFailedLoginEvents]
WITH EXECUTE AS OWNER
AS 
BEGIN
   SET NOCOUNT ON;

   DECLARE
       @message_body XML,
       @message NVARCHAR(MAX),
       @subject NVARCHAR(255) = 'There was a login failed event on ' + @@SERVERNAME,
	   @MailProfile VARCHAR(50)

   WHILE (1 = 1)
   BEGIN
       WAITFOR 
       (
           RECEIVE TOP(1) @message_body = message_body
               FROM dbo.FailedLoginNotificationQueue
       ), TIMEOUT 1000;

       IF (@@ROWCOUNT = 1)
       BEGIN
           IF (@message_body.value('(/EVENT_INSTANCE/State)[1]', 'int') in (5,8))
           BEGIN
               SELECT @message = 'From Event Notification: Login failed for user '
                   + @message_body.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(128)' )
                   + '. Full error message follows:' + CHAR(13) + CHAR(10)
                   + @message_body.value('(/EVENT_INSTANCE/TextData)[1]', 'varchar(4000)' );
     Select @MailProfile = (select name from sysmail_profile)
               EXEC msdb.dbo.sp_send_dbmail
                   @profile_name = @MailProfile, 
                   @recipients = 'grpdba@marisa.com.br',
                   @copy_recipients = 'operacao@marisa.com.br',
                   @subject = 'Falhas de logon ocorrendo no MARI058 PI, verificar os logs!' ,
                   @body = @message;
           END
       END
   END
END
GO

ALTER QUEUE FailedLoginNotificationQueue
WITH ACTIVATION
(
   STATUS = OFF,
   PROCEDURE_NAME = [dbo].[ProcessFailedLoginEvents],
   MAX_QUEUE_READERS = 1,
   EXECUTE AS OWNER
);
GO