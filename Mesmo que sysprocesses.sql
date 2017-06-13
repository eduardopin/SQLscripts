select * from sys.dm_os_waiting_tasks  
--praticamente o mesmo que a query da sysprocesses

select * from sys.dm_os_waiting_tasks where wait_duration_ms > 20
AND wait_type LIKE '%PAGEIOLATCH%'
  --seleciona se existe alguma fila para acesso a disco

-- Colocar no F4
--praticamente o mesmo que a query da sysprocesses
select * from sys.dm_os_waiting_tasks  
Go
--seleciona se existe alguma fila para acesso a disco
select * from sys.dm_os_waiting_tasks where wait_duration_ms > 20
--AND wait_type LIKE '%PAGEIOLATCH%'
Go




