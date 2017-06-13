sp_monitor
select * from sysprocesses where waittype != 0x0000
and lastwaittype like 'PAGEIOLATCH%'
AND waitresource LIKE '5:%'

SELECT @@TOTAL_READ [Total Reads]
     , @@TOTAL_WRITE as [Total Writes]
     , CAST(@@IO_BUSY as FLOAT) * @@TIMETICKS / 1000000.0 as [IO Sec]
Select * from ::fn_virtualfilestats(5,null)
ORDER BY Byteswritten desc

SELECT * FROM sys.dm_io_virtual_file_stats(5, Null)
order by num_of_reads desc;
GO


sp_helpdb PRD
