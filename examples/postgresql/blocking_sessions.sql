select blocked_locks.pid as blocked_pid,
       blocking_locks.pid as blocking_pid,
       blocked_activity.query as blocked_query
from pg_catalog.pg_locks blocked_locks
join pg_catalog.pg_stat_activity blocked_activity on blocked_activity.pid = blocked_locks.pid
join pg_catalog.pg_locks blocking_locks on blocking_locks.locktype = blocked_locks.locktype
where not blocked_locks.granted;
