select dbschemas.name as schema_name,
       dbtables.name as table_name,
       dbindexes.name as index_name,
       indexstats.avg_fragmentation_in_percent
from sys.dm_db_index_physical_stats (db_id(), null, null, null, null) indexstats
join sys.tables dbtables on dbtables.object_id = indexstats.object_id
join sys.schemas dbschemas on dbtables.schema_id = dbschemas.schema_id
join sys.indexes dbindexes on dbindexes.object_id = indexstats.object_id and dbindexes.index_id = indexstats.index_id
where indexstats.avg_fragmentation_in_percent > 20;
