SELECT 
avg_user_impact AS average_improvement_percentage, 
avg_total_user_cost AS average_cost_of_query_without_missing_index, 
REPLACE (statement,'[PRD].[prd].','') as Tabela,
'CREATE INDEX ix_DBA_' + REPLACE (statement,'[DW_PRD_MARISA].[dbo].','') + 
--ISNULL(equality_columns, '_') +
--ISNULL(inequality_columns, '_') +
 ' ON ' + [statement] + 
' (' + ISNULL(equality_columns, ' , ') + 
ISNULL(inequality_columns, ' ') + ')' + 
ISNULL(' INCLUDE (' + included_columns + ')', '') 
AS create_missing_index_command
FROM sys.dm_db_missing_index_details a INNER JOIN 
sys.dm_db_missing_index_groups b ON a.index_handle = b.index_handle
INNER JOIN sys.dm_db_missing_index_group_stats c ON 
b.index_group_handle = c.group_handle
WHERE avg_user_impact > = 75
order by 2 desc

DBCC DROPCLEANBUFFERS