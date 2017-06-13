select a.session_id, b.os_thread_id, b.usermode_time, a.task_state from sys.dm_os_tasks a 
inner join sys.dm_os_threads b on a.worker_address = b.worker_address
--where session_id is not null 
order by usermode_time desc

sp_who2 34


-- link SQL ID com SO ID

SELECT STasks.session_id, SThreads.os_thread_id
    FROM sys.dm_os_tasks AS STasks
    INNER JOIN sys.dm_os_threads AS SThreads
        ON STasks.worker_address = SThreads.worker_address
    WHERE STasks.session_id IS NOT NULL
    ORDER BY STasks.session_id;
    
    
    

