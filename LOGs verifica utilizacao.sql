--******---- Bom usarlog_reuse_wait and log_reuse_wait_desc columns of the sys.databases 
select name,log_reuse_wait, log_reuse_wait_desc from sys.databases 
Go
-- verifica o que está impedindo o Log de ser ciclado

dbcc opentran
Go

kill 246

Checkpoint 
Go

sp_who2 active
Go
sp_who2 246
Go


--dbcc inputbuffer (90)
--kill 90

select * from sys.dm_tran_database_transactions
select database_transaction_log_bytes_used, database_transaction_log_bytes_used_system,
database_transaction_log_bytes_reserved  from sys.dm_tran_database_transactions
-- pega as transações que estão consumindo mais dados, logo pode se ver quem está consumindo mais disco e log
Go

select * from sys.dm_tran_database_transactions
-- Returns information about transactions at the database level.
Go

select * from sys.dm_exec_requests  
--Returns information about each request that is executing within SQL Server. 
Go

-- Se o motivo do Log Cheio for replicação tente isso
EXEC sp_repldone @xactid = NULL, @xact_segno = NULL, @numtrans = 0,     @time = 0, @reset = 1


backup log "nome da base" with no log



