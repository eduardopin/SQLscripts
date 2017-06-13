select top 100 [name], b.name, avg_fragmentation_in_percent
 from 
inner join sys.sysobjects b
on sys.dm_db_index_physical_stats.object_id = b.id
where page_count > 1000


select top 100 * from sys.sysobjects b
select * from sysindexes 

SELECT
    i.name                  AS IndexName,
    s.used_page_count * 8   AS IndexSizeKB
FROM sys.dm_db_partition_stats  AS s 
JOIN sys.indexes                AS i
ON s.[object_id] = i.[object_id] AND s.index_id = i.index_id
--WHERE s.[object_id] = object_id('dbo.TableName')
where i.name    is not null
ORDER BY 2 desc

SELECT
    i.name              AS IndexName,
    SUM(page_count * 8) AS IndexSizeKB
FROM sys.dm_db_index_physical_stats(
    db_id(), object_id('dbo.TableName'), NULL, NULL, 'DETAILED') AS s
JOIN sys.indexes AS i
ON s.[object_id] = i.[object_id] AND s.index_id = i.index_id
GROUP BY i.name
ORDER BY i.name
