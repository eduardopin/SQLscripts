Create Procedure PRC_FFSPACE (@database varchar (30))
as
DECLARE @cmdSQL AS VARCHAR(1000)
CREATE TABLE ##tbFileStats (
[fileId] SMALLINT PRIMARY KEY,
[fileGroup] SMALLINT NOT NULL,
[totalExtents] INT NOT NULL,
[usedExtents] bigint,--(12,0) NOT NULL,
[name] VARCHAR(256) NOT NULL,
[fileName] VARCHAR(256) NOT NULL)

SET @cmdSQL = 'INSERT INTO ##tbFileStats EXEC (''USE Crivo  DBCC SHOWFILESTATS'')'
EXEC (@cmdSQL)

SELECT SUM(((([totalExtents]-[usedExtents])*64)/1024)/1024), 'GB', b.groupname
		FROM ##tbFileStats a
			INNER JOIN DW_PRD_CRED21.dbo.sysfilegroups b
				ON a.[fileGroup] = b.[groupid]
		GROUP BY b.[groupname]
		go
		
		DROP TABLE ##tbFileStats
		
--117953.437500	PRIMARY
--224157.187500	DATA
--9666.125000	INDX
--131997.062500	DATA_2

--DBCC SHOWFILESTATS

SELECT
--DB_NAME(SU.DATABASE_ID) DBNAME,
SUM (SU.TOTAL_PAGE_COUNT) *8/1024 /1024 TOTAL_SIZE_GB,
SUM (SU.ALLOCATED_EXTENT_PAGE_COUNT) *8/1024 / 1024 ESPAÇO_ALOCADO_GB,
SUM (SU.UNALLOCATED_EXTENT_PAGE_COUNT) *8/1024 / 1024 ESPAÇO_LIVRE_GB
FROM
SYS.DM_DB_FILE_SPACE_USAGE SU
JOIN SYS.MASTER_FILES AS MF
ON MF.DATABASE_ID = SU.DATABASE_ID
AND MF.FILE_ID = SU.FILE_ID
--group by DB_NAME(SU.DATABASE_ID)




SELECT DB.name, SUM(size) * 8 AS Tamanho FROM sys.databases DB
INNER JOIN sys.master_files
ON DB.database_id = sys.master_files.database_id
GROUP BY DB.name  
SELECT
(SELECT SUM(CAST(df.size as float)) FROM sys.database_files AS df 
   WHERE df.type in ( 0, 2, 4 ) ) AS [DbSize],
SUM(a.total_pages) AS [SpaceUsed],
(SELECT SUM(CAST(df.size as float)) FROM sys.database_files AS df 
   WHERE df.type in (1, 3)) AS [LogSize]
FROM
sys.partitions p join sys.allocation_units a 
  on p.partition_id = a.container_id 
left join sys.internal_tables it 
  on p.object_id = it.object_id 


  ;WITH t(s) AS
(
  SELECT CONVERT(DECIMAL(18,2), SUM(size)*8/1024.0)
   FROM sys.database_files
   WHERE [type] % 2 = 0
), 
d(s) AS
(
  SELECT CONVERT(DECIMAL(18,2), SUM(total_pages)*8/1024.0)
   FROM sys.partitions AS p
   INNER JOIN sys.allocation_units AS a 
   ON p.[partition_id] = a.container_id
)
SELECT 
  Allocated_Space = t.s, 
  Available_Space = t.s - d.s,
  [Available_%] = CONVERT(DECIMAL(5,2), (t.s - d.s)*100.0/t.s)
FROM t CROSS APPLY d;