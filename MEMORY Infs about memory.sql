set nocount on
go
sp_configure 'awe'
go
sp_configure 'min server'
go
sp_configure 'max server'
go
SELECT cpu_count,hyperthread_ratio,physical_memory_in_bytes,virtual_memory_in_bytes
from sys.dm_os_sys_info
go
select cntr_value,cntr_type from sys.dm_os_performance_counters
where counter_name='Target Server Memory (KB)' 
or counter_name='Total Server Memory (KB)'
go
dbcc memorystatus