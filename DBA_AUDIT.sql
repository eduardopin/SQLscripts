/****** Object:  DdlTrigger [DBA_AUDIT]    Script Date: 09/21/2011 16:03:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


Create TRIGGER [DBA_AUDIT]
ON DATABASE
FOR  DDL_DATABASE_LEVEL_EVENTS
AS
PRINT '***Todas alterações nos bancos de dados estão sendo auditadas!**'
SET NOCOUNT ON

DECLARE @xmlEventData XML

-- Capture the event data that is created
SET @xmlEventData = eventdata()

-- Insert information to a EventLog table
INSERT INTO DBA.dbo.TBL_Audit_DBA
(
EventTime,
EventType,
ServerName,
DatabaseName,
ObjectType,
ObjectName,
UserName,
CommandText,
HOST
)
SELECT REPLACE(CONVERT(VARCHAR(max), @xmlEventData.query('data(/EVENT_INSTANCE/PostTime)')),'T', ' '),
CONVERT(VARCHAR(50), @xmlEventData.query('data(/EVENT_INSTANCE/EventType)')),
CONVERT(VARCHAR(50), @xmlEventData.query('data(/EVENT_INSTANCE/ServerName)')),
CONVERT(VARCHAR(50), @xmlEventData.query('data(/EVENT_INSTANCE/DatabaseName)')),
CONVERT(VARCHAR(50), @xmlEventData.query('data(/EVENT_INSTANCE/ObjectType)')),
CONVERT(VARCHAR(50), @xmlEventData.query('data(/EVENT_INSTANCE/ObjectName)')),
CONVERT(VARCHAR(50), @xmlEventData.query('data(/EVENT_INSTANCE/LoginName)')),
--@ed.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(256)')
CONVERT(VARCHAR(MAX), @xmlEventData.query('data(/EVENT_INSTANCE/TSQLCommand/CommandText)')),
HOST_NAME()


GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DISABLE TRIGGER [DBA_AUDIT] ON DATABASE
--GO
ENABLE TRIGGER [DBA_AUDIT] ON DATABASE
GO


