
-- gera reidex e statististica sem levar em conta o numero linhas
SELECT 'Alter index all on ([DW_PRD_MARISA.'+SCHEMA_NAME(schema_id)+'.['+name+']] rebuild ])' + CHAR(10) + 'GO'
+ CHAR(10) + 'update statistics Altitude.'+SCHEMA_NAME(schema_id)+'.['+name+ '] with resample, all'
+ char(10) + 'Go'
AS SchemaTable
FROM sys.tables 
where sys.tables.name not like '%history%'


-- DW gera reidex e statististica sem levar em conta o numero linhas
SELECT 'Alter index all on DW_PRD_MARISA.'+SCHEMA_NAME(schema_id)+'.['+name+'] rebuild ' + CHAR(10) + 'GO'
+ CHAR(10) + 'update statistics Altitude.'+SCHEMA_NAME(schema_id)+'.['+name+ '] with resample, all'
+ char(10) + 'Go'
AS SchemaTable
FROM sys.tables 
where sys.tables.name not like '%history%'


select top 100 * from sys.dm_db_partition_stats
in_row_data_page_count
in_row_reserved_page_count

                    
-- SAP conta o numero de linhas de cada tabela e gera o reindex... Util, muito util...                                  
select  'DBCC dbreindex ([PRD.'+SCHEMA_NAME(schema_id)+'.['+name+']]])' + CHAR(10) + 'GO'
+ CHAR(10) + 'update statistics PRD.'+SCHEMA_NAME(schema_id)+'.['+name+ '] with resample, all'
+ char(10) + 'Go'  FROM sys.tables a (nolock)
 inner join    sys.dm_db_partition_stats b (nolock) on a.object_id = b.object_id 
 order by b.in_row_reserved_page_count asc
 
 create table #temp (name varchar(30))
 insert into #temp select distict name from sys.tables
 
 
 
 select distinct 'DBCC dbreindex ([PRD.'+SCHEMA_NAME(schema_id)+'.['+name+']]])' + CHAR(10) + 'GO'
+ CHAR(10) + 'update statistics PRD.'+SCHEMA_NAME(schema_id)+'.['+name+ '] with resample, all'
+ char(10) + 'Go' as comando, b.in_row_reserved_page_count  FROM sys.tables a (nolock)
 inner join    sys.dm_db_partition_stats b (nolock) on a.object_id = b.object_id 
 order by b.in_row_reserved_page_count  desc                      
                                                       
                                  
                                  
