-- Queries para resolver problemas de IO maiores que 15 segundos...

--mostra todos IOs pendentes pra toda uma instancia
SELECT SUM(pending_disk_io_count) AS [Number of pending I/Os] FROM sys.dm_os_schedulers 


-- detalha o IO pendente que vimos na query acima
-- coluna IO pending = 1 então é IO pendente no Windows
-- coluna IO pending = 0 então é o SQL que está segurando o IO
SELECT *  FROM sys.dm_io_pending_io_requests order by 3 desc

--

SELECT DB_NAME(5) AS [Database],[file_id], [io_stall_read_ms],[io_stall_write_ms],[io_stall] FROM sys.dm_io_virtual_file_stats(NULL,NULL) order by 3 desc

--Collect data from sys.dm_io_virtual_file_stats and sys.dm_io_pending_io_requests