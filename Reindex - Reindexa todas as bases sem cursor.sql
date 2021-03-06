exec sp_msForeachdb
'use [?]; 
IF ''?'' <> ''TEMPDB''
SELECT
     RowNum = ROW_NUMBER() OVER(ORDER BY t.TABLE_NAME)
    ,TableName =  t.TABLE_SCHEMA + ''.'' + t.TABLE_NAME
    ,AlterMe = ''Alter index all on  [''  + t.TABLE_SCHEMA + ''].['' + t.TABLE_NAME + ''] rebuild'' + char(10)   
INTO #Reindex_Tables
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_TYPE = ''BASE TABLE''

--select * from #Reindex_Tables
 
DECLARE @Iter INT
DECLARE @MaxIndex INT
DECLARE @ExecMe VARCHAR(MAX)
 
SET @Iter = 1
SET @MaxIndex =
(
    SELECT COUNT(1)
    FROM #Reindex_Tables
)
 
WHILE @Iter < @MaxIndex
BEGIN
    SET @ExecMe =
    (
        SELECT AlterMe
        FROM #Reindex_Tables
        WHERE RowNum = @Iter
    )
 
    EXEC (@ExecMe)
    PRINT @ExecMe + '' Executed''
 
    SET @Iter = @Iter + 1
END
'
