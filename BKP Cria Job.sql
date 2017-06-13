



-- executa differential
declare @backupdev varchar (300)
declare @cmd varchar (500)
set @backupdev = (select '''Z:\Database\PRD'+replace(replace(convert(varchar (300),GETDATE(),100),' ',''),':','')+'.bak''')
select @backupdev
set @cmd = 'backup database PRD to disk =' + @backupdev + ' with stats = 1, compression'
select @cmd
exec (@cmd )


-- executa log 
declare @backupdev varchar (300)
declare @cmd varchar (500)
set @backupdev = (select '''Z:\Database\PRD'+replace(replace(convert(varchar (300),GETDATE(),100),' ',''),':','')+'.trn''')
select @backupdev
set @cmd = 'backup Log PRD to disk =' + @backupdev 
select @cmd
exec (@cmd )




