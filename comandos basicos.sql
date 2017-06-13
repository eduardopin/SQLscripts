select * from sysdatabases order by 1
sp_lock
sp_updatestats
sp_who2 active
kill  113
dbcc Showcontig ([PRD.prd.LIPS])
checkpoint
dbcc shrinkfile(2,25000)
sp_cycle_errorlog
sp_whoisactive  order by 13
select * from sys.databases order by 1
dbcc opentran ()
sp_helpdb tempdb
kill 130
kill 60
kill 318
select * from sys.databases order by 1
sp_configure 'max degree of parallelism',8
RECONFIGURE WITH OVERRIDE

-- super Sp_who2 com bloqueios comando e etc, somente para conexoes ativas.
Select session_id, database_id, [user_id], [text], command,  blocking_session_id, wait_type, [last_wait_type], 
wait_resource, [status], start_time, [sql_handle], [plan_handle], reads, writes, row_count, granted_query_memory
 From sys.dm_exec_requests
cross apply sys.dm_exec_sql_text(sql_handle)-- order by 1
where database_id = 16 and
  session_id = 340


 
(@P1 varchar(18),@P2 varchar(4),@P3 varchar(10),@P4 varchar(1),@P5 varchar(1),@P6 varchar(16),@P7 varchar(3),@P8 varchar(10),@P9 varchar(2),@P10 varchar(1),@P11 varchar(1),@P12 varchar(1),@P13 varchar(1),@P14 varchar(1),@P15 varchar(1),@P16 varchar(10),@P17 varchar(8),@P18 varchar(6),@P19 varchar(10),@P20 varchar(4),@P21 varchar(8),@P22 varchar(6),@P23 varchar(8),@P24 varchar(6),@P25 varchar(8),@P26 varchar(8),@P27 varchar(10),@P28 varchar(4),@P29 varchar(3),@P30 varchar(3),@P31 decimal(13,3),@P32 decimal(13,3),@P33 decimal(13,3),@P34 decimal(13,3),@P35 decimal(11,3),@P36 varchar(3),@P37 varchar(10),@P38 varchar(10),@P39 varchar(4),@P40 varchar(1),@P41 varchar(10),@P42 varchar(20),@P43 varchar(12),@P44 varchar(8),@P45 decimal(11,3),@P46 varchar(3),@P47 varchar(4),@P48 varchar(1),@P49 decimal(13,3),@P50 varchar(1),@P51 varchar(10),@P52 varchar(6),@P53 varchar(8),@P54 varbinary(16),@P55 varchar(3),@P56 varchar(3),@P57 varchar(10))UPDATE "LQUA" SET "MATNR" = @P1 ,"WERKS" = @P2 ,"CHARG" = @P3 ,"BESTQ" = @P4 ,"SOBKZ" = @P5 ,"SONUM" = @P6 ,"LGTYP" = @P7 ,"LGPLA" = @P8 ,"PLPOS" = @P9 ,"SKZUE" = @P10 ,"SKZUA" = @P11 ,"SKZSE" = @P12 ,"SKZSA" = @P13 ,"SKZSI" = @P14 ,"SPGRU" = @P15 ,"ZEUGN" = @P16 ,"BDATU" = @P17 ,"BZEIT" = @P18 ,"BTANR" = @P19 ,"BTAPS" = @P20 ,"EDATU" = @P21 ,"EZEIT" = @P22 ,"ADATU" = @P23 ,"AZEIT" = @P24 ,"ZDATU" = @P25 ,"WDATU" = @P26 ,"WENUM" = @P27 ,"WEPOS" = @P28 ,"LETYP" = @P29 ,"MEINS" = @P30 ,"GESME" = @P31 ,"VERME" = @P32 ,"EINME" = @P33 ,"AUSME" = @P34 ,"MGEWI" = @P35 ,"GEWEI" = @P36 ,"TBNUM" = @P37 ,"IVNUM" = @P38 ,"IVPOS" = @P39 ,"BETYP" = @P40 ,"BENUM" = @P41 ,"LENUM" = @P42 ,"QPLOS" = @P43 ,"VFDAT" = @P44 ,"QKAPV" = @P45 ,"KOBER" = @P46 ,"LGORT" = @P47 ,"VIRGO" = @P48 ,"TRAME" = @P49 ,"KZHUQ" = @P50 ,"VBELN" = @P51 ,"POSNR" = @P52 ,"IDATU" = @P53 ,"MSR_INSP_GUID" = @P54 WHERE "MANDT" = @P55 AND "LGNUM" = @P56 AND "LQNUM" = @P57 
/* R3:RTAB:0 T:LQUA */

select s.*, w.*, t.*
from sys.dm_os_schedulers as s
inner join sys.dm_os_workers as w on w.scheduler_address = s.scheduler_address
inner join sys.dm_os_threads as t on t.worker_address = w.worker_address



-- Mostra os SPIDs, suas threads e respectivas informações
dbcc sqlperf(threads)



-- Traz iformações detalhadas de uma thread
Select * From sys.dm_os_threads
where os_thread_id = 6244


-- Mostra o wait type corrente no SQL Server, mais atual que a sys.processes que traz informação mais antiga
Select *, (wait_time_ms/waiting_tasks_count) As avg_wait_time From sys.dm_os_wait_stats
Where waiting_tasks_count > 0
Order By wait_time_ms desc

-- Mostra o wait para uma determinada sessão
select * From sys.dm_os_waiting_tasks
where session_id = 78


--Select * From sys.dm_os_workers order by context_switch_count desc


-- Pega os detalhes dos recursos que uma thread está esperando
select * from sys.dm_io_pending_io_requests  as i
inner join sys.dm_os_threads as t on t.scheduler_address = i.scheduler_address
where os_thread_id = 6244


-- Mede consumo de memoria por sessões, Muito util para o mari35
select * From sys.dm_exec_query_memory_grants
cross apply sys.dm_exec_sql_text(sql_handle)
cross apply sys.dm_exec_query_plan(plan_handle)
where session_id = 78

  
select * from sys.dm_os_threads as t
left join sys.dm_os_workers as w on w.worker_address = t.worker_address
left join sys.dm_os_schedulers as s on t.scheduler_address = s.scheduler_address
where os_thread_id = 78


-- Tipo de SP_LOCK porem é possivel saber o que está bloqueando uma determinada tabela em especial... Sensacional
select * from sys.dm_tran_locks
where --request_session_id = and 
request_mode  in ('X', 'IX')
and resource_associated_entity_id = 1241875591

/*Select * From sys.dm_exec_sessions
where session_id = 78*/

select * from sys.dm_os_memory_clerks
Order by single_pages_kb desc

Select Top 25 [sql_handle], plan_generation_num, execution_count, total_worker_time, 
(total_worker_time/execution_count) as avg_cpu_cost, [text]
From sys.dm_exec_query_stats
cross apply sys.dm_exec_sql_text(sql_handle)
Where execution_count > 0
Order By avg_cpu_cost desc

Select * From sys.dm_db_index_usage_stats
where database_id = db_id('dbahd') 
--and [object_id] = object_id('dia_item_loja_i_final_new')
order by user_seeks desc

select object_id('dia_item_loja_i_final_new')

select * 
from sys.dm_db_index_operational_stats (db_id('PRD'), object_id('PRD.prd.LIPS'), 0, null)

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID('PRD'),1290136037, 0, NULL , 'DETAILED');
SELECT * FROM sys.dm_db_index_physical_stats(DB_ID('PRD'),1290136037)
SELECT * FROM sys.dm_db_index_physical_stats(5,1290136037,null,null,null)

select object_id('PRD.prd.LIPS')


--select object_name(1529772507)
sp_who2 77
select @@version
dbcc inputbuffer (72)
sp_monitor
select * from master..sysprocesses where spid = 77
select * from master..sysprocesses where waittype <> 0x0000
select * from master..sysprocesses where blocked <> 0
select * from sys.objects where object_id = 1241875591 
select * from sys.dm_exec_sql_text(0x010009009EF3711DE0A4A41E0300000000000000)
kill 75
DBCC FREEPROCCACHE WITH NO_INFOMSGS;
DBCC FREESESSIONCACHE WITH NO_INFOMSGS;
checkpoint
          

SELECT scheduler_id, current_tasks_count, runnable_tasks_count
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255
select * FROM sys.dm_os_schedulers
                                                                                                                                                                                                                                

DBCC SQLPERF (WAITSTATS)
-- Script abaixo sumariza contadores verificando a falta de processadores
select round(((convert(float, ws.wait_time_ms) / ws.waiting_tasks_count) / (convert(float, si.os_quantum) / si.cpu_ticks_in_ms) * cpu_count), 2) as Additional_CPUs_Necessary,
round((((convert(float, ws.wait_time_ms) / ws.waiting_tasks_count) / (convert(float, si.os_quantum) / si.cpu_ticks_in_ms) * cpu_count) / hyperthread_ratio), 2) as Additional_Sockets_Necessary
from sys.dm_os_wait_stats ws cross apply sys.dm_os_sys_info si where ws.wait_type = 'SOS_SCHEDULER_YIELD'


select max_workers_count From sys.dm_os_sys_info -- Mostra quantas threads estão configuradas para o SQL
select count(*) from sys.dm_os_threads -- mostra quantas threads estão sendo utilizadas pelo SQL


select * from sys.dm_exec_sql_text(0x03000B0042A6C9794573EF00BD9C00000100000000000000)
select * from sys.dm_exec_requests
select * from sys.dm_exec_query_stats  a
inner join sys.dm_exec_requests b on a.sql_handle = b.sql_handle
and b.session_id = 98
select object_name(4571551)
select object_id ('dia_item_loja_i_final_new')

sp_configure 'show advanced options', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO
