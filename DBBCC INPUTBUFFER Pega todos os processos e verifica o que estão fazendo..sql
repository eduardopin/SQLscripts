select top 100 * from sysprocesses

SELECT

p.spid AS [SPID]

,DB_NAME(p.dbid) AS [DBName]

,COALESCE(OBJECT_NAME(txt.objectID,txt.DBID),

CASE

WHEN txt.encrypted = 1

THEN 'Encrypted'

WHEN r.session_id IS NULL

THEN txt.text

ELSE LTRIM(SUBSTRING(txt.text, r.statement_start_offset / 2 + 1

,((CASE WHEN r.statement_end_offset = -1

THEN DATALENGTH(txt.text)

ELSE r.statement_end_offset

END) - r.statement_start_offset) / 2))

END) AS [Query]

,p.loginame AS [Login]

,p.hostname AS [Host Name]

,p.status AS [Status]

,p.blocked AS [BlkBy]

,ISNULL(t.trancount,0) AS [TranCount]

,ISNULL(l.lockcount,0) AS [LockCount]

,l.resource_type AS [LockType]

,l.request_mode AS [LockMode]

,l.request_status AS [LockStatus]

,r.wait_type AS [WaitType]

,r.percent_complete AS [PercentComplete]

,r.estimated_completion_time AS [EstCompTime]

,p.cpu AS [CPU]

,p.physical_io AS [IO]

,c.num_reads AS [Reads]

,c.num_writes AS [Writes]

,c.last_read AS [LastRead]

,c.last_write AS [LastWrite]

,p.login_time AS [StartTime]

,p.last_batch AS [LastBatch]

,p.PROGRAM_NAME AS [Program Name]

,p.spid AS [SPID2]

FROM sys.sysprocesses p

INNER JOIN sys.dm_exec_connections c (NOLOCK)

ON c.session_id = p.spid

CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) AS txt

LEFT JOIN sys.dm_exec_requests r

ON c.session_id = r.session_id

LEFT OUTER JOIN

(

SELECT

session_id

,database_id = MAX(database_id)

,trancount = COUNT(*)

FROM

sys.dm_tran_session_transactions t

INNER JOIN sys.dm_tran_database_transactions dt

ON t.transaction_id = dt.transaction_id

GROUP BY session_id

) t

ON t.session_id = p.spid

LEFT OUTER JOIN

(

SELECT

request_session_id

,database_id = MAX(resource_database_id)

,resource_type

,request_status

,request_mode

,lockcount = COUNT(*)

FROM

sys.dm_tran_locks (NOLOCK)

GROUP BY request_session_id, resource_type, request_mode, request_status

) l

ON p.spid = l.request_session_id

WHERE p.spid <> @@SPID

