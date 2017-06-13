-- veriica espaço antes de compactar e armazena o resultado para comparação
SELECT
     OBJECT_NAME(object_id) As Tabela, Rows As Linhas,
     SUM(Total_Pages * 8/1024) As Reservado,
     SUM(CASE WHEN Index_ID > 1 THEN 0 ELSE Data_Pages * 8 END) As Dados,
         SUM(Used_Pages * 8/1024) -
         SUM(CASE WHEN Index_ID > 1 THEN 0 ELSE Data_Pages * 8 END) As Indice,
     SUM((Total_Pages - Used_Pages) * 8/1024) As NaoUtilizado

 FROM
     sys.partitions As P
     INNER JOIN sys.allocation_units As A ON P.hobt_id = A.container_id
 inner join sys.sysobjects S on (S.id = P.object_id)
 where S.type != 'S'
 GROUP BY OBJECT_NAME(object_id), Rows
 ORDER BY Tabela

 EXEC sp_MSForEachDB 'IF ''[?]'' NOT IN (''master'', ''model'', ''msdb'', ''tempdb'') 
select ''[?]'',count(*) from [?].dbo.sysobjects'

IF OBJECT_ID('data_growth', 'U') IS NOT NULL
DROP TABLE data_growth;

drop table data_growth
create table data_growth (
Servidor varchar (100),
DBNAME varchar (100),
TOTAL_SPACE_GB bigint,
ESPACO_UTILIZADO_GB bigint,
ESPACO_LIVRE_GB bigint,
DATA datetime 
)

insert into SQLDEV.dba.data_growth
EXEC sp_MSForEachDB 
'use [?]
 select @@servername, 
  ''[?]'', 
 --DB_NAME(SU.DATABASE_ID) AS DBNAME,	 
SUM (SU.TOTAL_PAGE_COUNT) *8/1024 /1024 TOTAL_SIZE_GB,
SUM (SU.ALLOCATED_EXTENT_PAGE_COUNT) *8/1024 / 1024 ESPAÇO_ALOCADO_GB,
SUM (SU.UNALLOCATED_EXTENT_PAGE_COUNT) *8/1024 / 1024 ESPAÇO_LIVRE_GB,
getdate() AS DATA
FROM
sys.dm_db_file_space_usage
JOIN sys.master_files AS MF
ON MF.DATABASE_ID = SU.DATABASE_ID
AND MF.FILE_ID = SU.FILE_ID
group by DB_NAME(SU.DATABASE_ID)'

select * from data_growth
select @@servername

