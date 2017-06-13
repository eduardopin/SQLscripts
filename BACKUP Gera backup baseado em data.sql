-- executa log 
declare @backupdev varchar (300)
declare @cmd varchar (500)
set @backupdev = 'PRD_'+(select replace(convert(varchar (300),GETDATE(),102),'.','') )
set @backupdev = @backupdev + (select replace(convert(varchar (300),GETDATE(),108),':','')+'.trn''')
set @cmd = 'backup Log PRD to disk = ''' + @backupdev 
select @cmd
exec (@cmd )