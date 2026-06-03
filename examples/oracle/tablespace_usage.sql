select tablespace_name,
       round(used_percent, 2) as used_percent
from dba_tablespace_usage_metrics
order by used_percent desc;
