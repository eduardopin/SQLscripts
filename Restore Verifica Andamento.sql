SELECT start_time,
       (total_elapsed_time/1000/60) AS MinutesRunning,
       percent_complete,
       command,
       b.name AS DatabaseName,
      DATEADD(ms,estimated_completion_time,GETDATE()) AS StimatedCompletionTime,
      (estimated_completion_time/1000/60) AS MinutesToFinish
FROM  sys.dm_exec_requests a
INNER JOIN sys.databases b ON a.database_id = b.database_id
WHERE command LIKE '%RESTORE%'
OR command LIKE '%backup%'
AND estimated_completion_time > 0
