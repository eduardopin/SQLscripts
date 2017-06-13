
EXEC sp_addlinkedserver
   @server = 'CCMPROD',
   @srvproduct = 'Oracle',
   @provider = 'OraOLEDB.Oracle',
   @datasrc = 'CCMPROD'
GO

EXEC sp_addlinkedserver
   @server = 'SITEF',
   @srvproduct = 'Oracle',
   @provider = 'MSDAORA',
   @datasrc = 'CCMPROD'
GO

EXEC sp_addlinkedserver
   @server = 'SITEF',
   @srvproduct = 'Oracle',
   @provider = 'OraOLEDB.Oracle',
   @datasrc = 'SITEF'
GO

EXEC sp_addlinkedserver 
   @server = 'NCR_MARISA', 
   @srvproduct = 'SQL7',
   @provider = 'MSDASQL', 
   @datasrc = 'NCR_MARISA_32bit'
GO

EXEC sp_addlinkedserver   -- Cria Linked server do Marisa07 (2000) para SQL 2008 R2, precisa criar um DSN ODBC antes. Não apagar!
   @server='Mari056', 
   @srvproduct='SQL7',
   @provider='SQLOLEDB', 
   @datasrc='Mari056'


EXEC sp_addlinkedserver   
   @server='DADOSADV', 
   @srvproduct='MARI079',
   @provider='SQLNCLI', 
   @datasrc='MARI079',
   @catalog=N'dadosadv'


EXEC sp_addlinkedsrvlogin 'Marisa07', 'false', null, 'dss','ibieta'
EXEC sp_addlinkedsrvlogin 'CCMPROD', 'false', 'DSS', 'CCM_DW','sql@ybyeta10g'
EXEC sp_addlinkedsrvlogin 'CCMPROD', 'false', 'DSS', 'CCM_DW','sql@ybyeta10g'
EXEC sp_addlinkedsrvlogin 'CCMPROD', 'false', 'DSS', 'CCM_DW','sql@ybyeta10g'
EXEC sp_addlinkedsrvlogin 'CCMPROD', 'false', 'central\eduardo.pin', 'system','dbaclr'
EXEC sp_addlinkedsrvlogin 'CCMPROD', 'false', 'central\eduardo.pin', 'system','dbaclr'
EXEC sp_addlinkedsrvlogin 'MARISA07', 'false', 'central\eduardo.pin', 'sa','db@manager.net'



OraOLEDB.Oracle
LS_CCMPROD

EXEC sp_addlinkedserver 
   @server = 'PEGE', 
   @provider = 'Microsoft.Jet.OLEDB.4.0', 
   @srvproduct = 'OLE DB Provider for Jet',
   @datasrc = '\\marisa01\users\planejamento\Douglas\LB_DW\Real_Civil\1_09_LB.xls'
GO
