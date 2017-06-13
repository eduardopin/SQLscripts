CREATE PROCEDURE DBA_LIMPA_LOGS
AS

--EXECUTE IN MASTER CONTEXT
SET NOCOUNT ON;

-- 1 - Variable declaration
DECLARE @dbName sysname
DECLARE @backupPath NVARCHAR(500)
DECLARE @cmd NVARCHAR(500)
DECLARE @fileList TABLE (backupFile NVARCHAR(255))
DECLARE @lastFullBackup NVARCHAR(500)
DECLARE @lastDiffBackup NVARCHAR(500)
DECLARE @backupFile NVARCHAR(500)

-- 2 Initialize variables
SET @dbName = 'PRD_W2'
SET @backupPath = 'B:\RestoreLogs\' -- OS PATH TO LOG FILES

-- 3 Get list of files
SET @cmd = 'DIR /b ' + @backupPath
INSERT INTO @fileList(backupFile)
EXEC master.sys.xp_cmdshell @cmd

-- 4 - check for log backups
DECLARE backupFiles CURSOR FOR 
SELECT backupFile FROM @fileList
 WHERE substring (backupFile,5,14) < (SELECT substring (last_restored_file,20,14)
 FROM [msdb].[dbo].[log_shipping_secondary_databases] -- Stores information about restory history
 where [secondary_database] = 'PRD_W2')
 and backupFile LIKE '%.trn'  
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



