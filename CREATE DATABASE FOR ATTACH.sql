use master
go
Set nocount on

Select 'Use ' + name + char(10) + 'go' + char(10) + 'Set nocount on' + Char(10) + 
'Select ''CREATE DATABASE '' + Rtrim(db_name()) + '' ON'' from master.dbo.sysdatabases where name = Rtrim(db_name())'
+ char(10) + 'Set nocount on' + Char(10) + 'select ''     (FILENAME = '''''' + rtrim(filename) + '''''')'' from sysfiles Where fileid = 1 ' 
+ char(10) + 'Set nocount on' + Char(10) + 'select ''   , (FILENAME = '''''' + rtrim(filename) + '''''')'' from sysfiles Where fileid <> 1 order by fileid' 
+ char(10) + 'Set nocount on' + Char(10) + 'Select ''FOR ATTACH''' + Char(10) + 'Set nocount on' + Char(10) +
'Select ''go'''
+ char(10) + 'go'
  from sysdatabases 
where NOT(name IN ('master','tempdb','model','msdb'))
Order by name 





Use BIP
go
Set nocount on
Select 'CREATE DATABASE ' + Rtrim(db_name()) + ' ON' 
from master.dbo.sysdatabases where name = Rtrim(db_name()) 
Set nocount on select '     (FILENAME = ''' + rtrim(filename) + ''')'
from sysfiles Where fileid = 1 
Set nocount on select '   , (FILENAME = ''' + rtrim(filename) + ''')'
from sysfiles Where fileid <> 1 order by fileid 
Set nocount on Select 'FOR ATTACH' 
Set nocount on Select 'go' go


USE [master]
GO
ALTER DATABASE [BIP] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'BIP'
GO


