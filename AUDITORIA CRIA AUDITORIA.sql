--sp_configure 'show advanced options', 1
--reconfigure

/*DISABLE TRIGGER DBA_AUDIT ON DATABASE;
GO
ENABLE TRIGGER DBA_AUDIT ON DATABASE;
GO
*/


select * from  DBA.dbo.TBL_Audit_DBA
--DROP table teste (teste varchar (50))
DROP Table DBA.dbo.TBL_Audit_DBA
--create table sbrisma ( blabla varchar(10))
/*
Use DBA
go
Create TABLE [dbo].[TBL_Audit_DBA](
[ID] [int] IDENTITY(1,1) NOT NULL,
[EventTime] [datetime] NULL,
[EventType] [varchar](100) NULL,
[ServerName] [varchar](100) NULL, 
[DatabaseName] [varchar](100) NULL,
[ObjectType] [varchar](50) NULL,
[ObjectName] [varchar](50) NULL,
[UserName] [varchar](100) NULL,
[CommandText] [varchar](max) NULL,
[HOST] [varchar] (75) NULL
)
GO
*/


ALTER TRIGGER DBA_AUDIT
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

SELECT REPLACE(CONVERT(VARCHAR(100), @xmlEventData.query('data(/EVENT_INSTANCE/PostTime)')),

'T', ' '),

CONVERT(VARCHAR(150), @xmlEventData.query('data(/EVENT_INSTANCE/EventType)')),

CONVERT(VARCHAR(75), @xmlEventData.query('data(/EVENT_INSTANCE/ServerName)')),

CONVERT(VARCHAR(75), @xmlEventData.query('data(/EVENT_INSTANCE/DatabaseName)')),

CONVERT(VARCHAR(75), @xmlEventData.query('data(/EVENT_INSTANCE/ObjectType)')),

CONVERT(VARCHAR(150), @xmlEventData.query('data(/EVENT_INSTANCE/ObjectName)')),

CONVERT(VARCHAR(100), @xmlEventData.query('data(/EVENT_INSTANCE/LoginName)')),

--@ed.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(256)')

CONVERT(VARCHAR(MAX), @xmlEventData.query('data(/EVENT_INSTANCE/TSQLCommand/CommandText)')),

HOST_NAME()

GO


