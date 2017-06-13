create procedure ssplock
as
(
select resource_type,
name, resource_database_id,
request_mode, request_type,
request_status, request_session_id ,
request_owner_type,
resource_associated_entity_id
from sys.dm_tran_locks inner join
sys.databases on  
sys.dm_tran_locks.resource_database_id = 
sys.databases.database_id
where resource_database_id > 3
)
go

create procedure sspwho
as 
(
SELECT 
A.Session_ID SPID, 
DB_NAME(B.Database_ID) DBName,
ISNULL(B.status,A.status) Status,
C.BlkBy, 
A.login_name Login,
A.host_name HostName,
D.text SQLStatement,
B.command,
ISNULL(B.cpu_time, A.cpu_time) CPUTime,
ISNULL((B.reads + B.writes),
(A.reads + A.writes)) DiskIO, 
A.last_request_start_time LastBatch,
A.program_name
FROM
 sys.dm_exec_sessions A 
 LEFT JOIN
 sys.dm_exec_requests B
 ON A.session_id = B.session_id
 LEFT JOIN
       (
        SELECT 
                A.request_session_id SPID,
                B.blocking_session_id BlkBy
           FROM sys.dm_tran_locks as A
             INNER JOIN sys.dm_os_waiting_tasks as B
            ON A.lock_owner_address = B.resource_address
        ) C
    ON A.Session_ID = C.SPID
   OUTER APPLY sys.dm_exec_sql_text(sql_handle) D
)