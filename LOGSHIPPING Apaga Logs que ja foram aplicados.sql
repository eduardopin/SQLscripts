USE master;
GO 
SET NOCOUNT ON
-- 1 - Variable declaration
DECLARE @dbName sysname
DECLARE @backupPath NVARCHAR(500)
DECLARE @cmd NVARCHAR(500)
DECLARE @fileList TABLE (backupFile NVARCHAR(255))
DECLARE @lastFullBackup NVARCHAR(500)
DECLARE @lastDiffBackup NVARCHAR(500)
DECLARE @backupFile NVARCHAR(500)

-- 2 - Initialize variables
SET @dbName = 'PRD'
SET @backupPath = 'G:\Standby\'

-- 3 - get list of files
SET @cmd = 'DIR /b ' + @backupPath
INSERT INTO @fileList(backupFile)
EXEC master.sys.xp_cmdshell @cmd
SET @cmd = 'xp_cmdshell Del  ' + @lastFullBackup 
PRINT @cmd

-- 5 - check for log backups
DECLARE backupFiles CURSOR FOR 
  SELECT backupFile 
  FROM @fileList A inner join msdb.dbo.backupmediafamily B
  on A.backupFile = substring (B.physical_device_name,12,24) 
  WHERE A.backupFile LIKE '%.trn'
  AND backupFile LIKE @dbName + '%'
  AND physical_device_name Like '%.trn'
OPEN backupFiles 

-- Loop through all the files for the database 
FETCH NEXT FROM backupFiles INTO @backupFile 
      WHILE @@FETCH_STATUS = 0 
      BEGIN 
      SET @cmd = 'EXEC master.dbo.xp_cmdshell ''del ' + @backupPath + @backupFile + '''' 
      PRINT @cmd
      Exec (@cmd)
   FETCH NEXT FROM backupFiles INTO @backupFile 
END
CLOSE backupFiles 
DEALLOCATE backupFiles 



