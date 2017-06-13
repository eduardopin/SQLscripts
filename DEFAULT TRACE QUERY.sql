SELECT * FROM sys.configurations WHERE configuration_id = 1568
SELECT * FROM ::fn_trace_getinfo(0)

SELECT 
     loginname,
     loginsid,
     spid,
     hostname,
     applicationname,
     servername,
     databasename,
     objectName,
     e.category_id,
     cat.name as [CategoryName],
     textdata,
     starttime,
     eventclass,
     eventsubclass,--0=begin,1=commit
     e.name as EventName
FROM ::fn_trace_gettable('D:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\LOG\log_1347.trc',0)
     INNER JOIN sys.trace_events e
          ON eventclass = trace_event_id
     INNER JOIN sys.trace_categories AS cat
          ON e.category_id = cat.category_id
WHERE databasename = 'DW_PRD_MARISA' 
      AND objectname IS NULL AND --filter by objectname
      e.category_id = 5--category 5 is objects
      AND  e.trace_event_id in (46,47,164) 
     -- trace_event_id: 46=Create Obj,47=Drop Obj,164=Alter Obj

