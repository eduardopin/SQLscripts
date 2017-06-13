SET NOCOUNT ON
DECLARE @last_backup NVARCHAR(19)
       ,@last_backup_file NVARCHAR(250)
       ,@last_restored NVARCHAR(19)
	   ,@last_restored_file NVARCHAR(250)


SELECT  SUBSTRING (LSMP.last_backup_file,8,30)
FROM   msdb.dbo.log_shipping_monitor_primary LSMP

SELECT  SUBSTRING (LSMP.last_restored_file,16,30)
FROM   CREDI032.msdb.dbo.log_shipping_monitor_secondary LSMP


