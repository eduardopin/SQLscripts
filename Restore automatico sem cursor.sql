--DROP procedure PRC_DBA_UPDATESTATS
DECLARE @dbName sysname
DECLARE @backupPath NVARCHAR(500)
DECLARE @cmd NVARCHAR(500)
DECLARE @fileList TABLE (backupFile NVARCHAR(255))
--DECLARE @CommandList TABLE (Command NVARCHAR(255))

-- 2 - Initialize variables
SET @dbName = 'QAS_N'
SET @backupPath = 'C:\STORAGE_QAS\LUN_39_CX4_240\TRN\'

-- 3 - get list of files
SET @cmd = 'DIR /b ' + @backupPath

INSERT INTO @fileList(backupFile)
EXEC master.sys.xp_cmdshell @cmd

--select * from @fileList

SELECT 
     RowNum = ROW_NUMBER() OVER(ORDER BY backupFile)
    --,TableName =  t.TABLE_SCHEMA + '.' + t.TABLE_NAME
    ,backupFile = backupFile
	,AlterMe = 'restore log ' + @dbName + ' from disk = ''' + @backupPath + backupFile + ''' with norecovery'
INTO #Restore_table
FROM @fileList

--select * from #Restore_table

 
DECLARE @Iter INT
DECLARE @MaxIndex INT
DECLARE @ExecMe VARCHAR(MAX)
 
SET @Iter = 1
SET @MaxIndex =
(
    SELECT COUNT(1)
    FROM #Restore_table
)
 
WHILE @Iter < @MaxIndex
BEGIN
    SET @ExecMe =
    (
        SELECT AlterMe
        FROM #Restore_table
        WHERE RowNum = @Iter
    )
 
    EXEC (@ExecMe)
    PRINT @ExecMe + ' Executed'
 
    SET @Iter = @Iter + 1
END

drop table #Restore_table
