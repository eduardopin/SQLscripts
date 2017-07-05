-- Funciona somente nos SQL Servers 2012 em diante.
-- select * from msdb.dbo.sysmail_profile
-- databasemail config Locaweb 
-- Servername:  flash.email.locaweb.com.br P 25 Reply --  ipi-w08dsql-03@lwo.locaweb.com.br (corrigir) -- Profile: LWO
-- Reply operacaoedn3 

Set nocount on
Create table ##fg_monitor 
 ( servername varchar (20),
  DBNAME varchar (20),
  Total_MB decimal (12,3),
  Alocado_MB decimal(12,3),
  Livre_MB decimal (12,3),
  Porcentagem decimal (14,2),
  Data date default getdate()
)
EXEC sp_MSforeachdb 
'
USE [?]
insert into ##fg_monitor 
select @@servername As servidor, 
DB_NAME(SU.DATABASE_ID) AS DBNAME,	 
(select SUM (SU.TOTAL_PAGE_COUNT) *8/1024 FROM
sys.dm_db_file_space_usage SU
JOIN sys.master_files AS MF
ON MF.DATABASE_ID = SU.DATABASE_ID
AND MF.FILE_ID = SU.FILE_ID 
having SUM (SU.TOTAL_PAGE_COUNT) *8/1024 > 0) AS TOTAL_MB,
SUM (SU.ALLOCATED_EXTENT_PAGE_COUNT) *8/1024 ALOCADO_MB,
SUM (SU.UNALLOCATED_EXTENT_PAGE_COUNT) *8/1024 LIVRE_MB,
cast(SUM (SU.TOTAL_PAGE_COUNT) *8/1024 as decimal (12,3)) / cast(SUM(SU.ALLOCATED_EXTENT_PAGE_COUNT) *8/1024 as decimal (12,3) )-1 as Porcentagem
,convert (date,getdate(),102) AS DATA
FROM
sys.dm_db_file_space_usage SU
JOIN sys.master_files AS MF
ON MF.DATABASE_ID = SU.DATABASE_ID
AND MF.FILE_ID = SU.FILE_ID
and SU.DATABASE_ID not in (1,2,3,4)
group by DB_NAME(SU.DATABASE_ID)'

--select Servername, DBNAME, LIVRE_MB, cast(Porcentagem * 100 as varchar(20)) + '%' as [% Livre]  from ##fg_monitor where Porcentagem < '0.05'
IF EXISTS (select 1 from ##fg_monitor
   where Porcentagem < '0.05')
   EXEC msdb..sp_send_dbmail 	@profile_name = 'SQLMAR',
   					@recipients = 'Eduardo.pin@marisa.com.br',
					@body = 'SQLMAR,  ESPAÇO LIVRE MENOR QUE 5% NOS BANCOS DE DADOS ABAIXO',
					@query = 'SET NOCOUNT ON 
				    select Servername, DBNAME, LIVRE_MB, cast(Porcentagem * 100 as varchar(20)) +  ''  % '' as [% Livre] from ##fg_monitor where Porcentagem < ''0.05''',
					@subject = 'SQLMAR, ESPAÇO INSUFICIENTE NOS BANCOS DE DADOS, ESPAÇO LIVRE < QUE 5%  ***'
drop table ##fg_monitor

