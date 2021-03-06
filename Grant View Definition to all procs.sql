disable trigger dba_audit on database
GO
DECLARE @tmpTable TABLE (
PK_ID INT IDENTITY (1, 1) NOT NULL PRIMARY KEY CLUSTERED,
[name] SYSNAME
)
--declare variables
DECLARE @name SYSNAME,
@RowCount INT,
@RecCount INT,
@strSQL VARCHAR(1000)
INSERT INTO @tmpTable ([name])
SELECT ROUTINE_SCHEMA+'.'+ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME NOT LIKE 'dt_%'
-- counters for while
SET @RecCount = (SELECT count(*) FROM @tmpTable)
SET @RowCount = 1
WHILE (@RowCount < @RecCount + 1)
BEGIN
SELECT @name = [name]
FROM @tmpTable
WHERE PK_ID = @RowCount
SET @strSQL = N'Grant view definition on ' + rtrim(cast(@name AS VARCHAR(128))) + ' to [CENTRAL\marcia.vmonteiro]'
--Execute the Sql
EXEC(@strSQL)
--Decrement the counter
SET @RowCount = @RowCount + 1
--reset vars, just in case...
SET @name = null
END
SELECT * FROM @tmpTable