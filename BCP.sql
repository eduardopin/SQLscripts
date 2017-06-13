select 'BCP DW_PRD_MARISA.rpcuser.'+TABLE_NAME + ' OUT D:\BCP\OUT\' + TABLE_NAME+'.DAT -T -c'  from information_schema.tables where table_type = 'BASE TABLE' AND 
TABLE_NAME LIKE '%deletar%'
order by table_name