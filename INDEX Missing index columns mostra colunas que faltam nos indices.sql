SELECT index_handle, column_name,
CASE
 WHEN column_usage IN ('EQUALITY', 'INEQUALITY') THEN 'index_key'
 WHEN column_usage = 'INCLUDE' THEN 'included_column'
END AS column_usage
FROM 
sys.dm_db_missing_index_groups a CROSS APPLY 
sys.dm_db_missing_index_columns (a.index_handle)