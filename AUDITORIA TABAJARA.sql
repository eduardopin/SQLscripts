-- Monta auditoria para auxiliar na migração dos servidores SQL Server 2000
-- Cria tabela 

if exists (select * from dbo.sysobjects 
where id = object_id(N'[dbo].[migra_SIV]')
 and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Migra]
GO

CREATE TABLE [dbo].[Migra] (
    [DB_NAME] [varchar] (100) NULL, 
	[Hostname] [varchar] (200) NULL ,
	[program_name] [varchar] (200) NULL ,
	[nt_username] [varchar] (200) NULL ,
	[loginame] [varchar] (200) NULL ,
	[data] [datetime] NULL 
) ON [PRIMARY]
GO

truncate table Migra
select distinct rtrim(ltrim(loginame)) from Migra

while 1 = 1
BEGIN
   WAITFOR DELAY '00:00:30'

insert into migra
Select DB_NAME(dbid), Hostname, program_name, nt_username, loginame, getdate()  from master..sysprocesses
where 
      spid > 20 and
      program_name not like 'SQLAgent - Generic Refresher' and
      program_name not like 'SQLAgent - Alert Engine' and 
      nt_username not like '%Eduardo.Pin%' and
      loginame not like '%CENTRAL\Eduardo.Pin%'
END    


     