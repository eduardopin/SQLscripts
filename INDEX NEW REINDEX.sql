--sp_helpdb 
--sp_help dia_secao_loja_sap_02_02_2009_BKP
 --select top 10 b.name, * from sys.dm_db_index_physical_stats (7,null,null,null,null)
 --  inner join sys.objects b on b.object_id = sys.dm_db_index_physical_stats.object_id
-- select name from sysindexes
-- select top 10 * from sys.objects
--select * from sysobjects where type = 'u' order by name
--select * from master..sysdatabases
--go

create table #index (nome_tab nvarchar(200), nome_index nvarchar(200), avg_fragmentation_in_percent float)
go                     
--declare @cmd Nvarchar (1000)
insert into #index 
select 'alter index all on ' + [name] + ' rebuild' + CHAR(10) + 'GO'--, b.name, avg_fragmentation_in_percent
 from sys.dm_db_index_physical_stats (8,null,null,null,null)
inner join sys.sysobjects b
on sys.dm_db_index_physical_stats.object_id = b.id
where page_count > 1000
and avg_fragmentation_in_percent > 50
go
select 'DBCC DBREINDEX ('''+nome_tab+''')' + CHAR(10) + 'GO' from #index
--go
--drop table #index
--select * from #index
--go
--select * from master..sysdatabases
select distinct 'dbcc dbreindex ([' + name + '])' + Char(10) + 'GO' from sys.objects where type = 'U'