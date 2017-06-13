
-- [‎15/‎12/‎2015 15:57] Bruno Mota Pereira: 
--select 'exec sp_change_users_login ''Update_One'','''+name+''','''+name+'''' from sysusers where issqluser = 1 




SELECT
--/*
-- prin.name AS UserName,
-- objsch.name SchemaName,
-- perm.class,
-- perm.state_desc + ' ' + perm.permission_name AS Permission,
  CASE 
    WHEN perm.class = 1 AND perm.minor_id <> 0 THEN 'COLUMN'
    WHEN perm.class = 1 THEN obj.type_desc
    ELSE perm.class_desc
  END AS ObjectType,
  CASE
    WHEN perm.class = 3 THEN sch.name
    WHEN cols.object_id IS NOT NULL THEN obj.name + '.' + cols.name
    WHEN perm.class = 0 THEN DB_NAME()
    ELSE ISNULL(obj.name, 'n/a')
  END AS ObjectName,
--*/
perm.state_desc + ' ' + perm.permission_name collate SQL_Latin1_General_CP1_CI_AS + 
CASE WHEN perm.class <> 0 -- don't do this part for databases
  THEN
    ' ON ' +
    CASE
        WHEN perm.class = 3 THEN 'SCHEMA::[' + sch.name + ']'
        WHEN cols.object_id IS NOT NULL THEN '[' + objsch.name + '].[' + obj.name + '](' + cols.name + ')'
        WHEN perm.class = 0 THEN DB_NAME()
        ELSE ISNULL('[' + objsch.name + '].[' + obj.name + ']', 'n/a')
    END --AS ObjectName--,
    ELSE ''
END
+ ' TO ['
+   prin.name 
+ ']' AS cmd
FROM 
sys.database_permissions perm
JOIN
sys.database_principals prin on perm.grantee_principal_id = prin.principal_id
LEFT JOIN
sys.all_objects obj ON perm.major_id = obj.object_id
LEFT JOIN
sys.all_columns cols ON perm.major_id = cols.object_id and perm.minor_id = cols.column_id
LEFT JOIN
sys.schemas objsch ON obj.schema_id = objsch.schema_id
LEFT JOIN
sys.schemas sch ON perm.major_id = sch.schema_id
WHERE prin.name <> 'public'
AND prin.name <> 'dbo'
AND obj.type = 'V'
--AND perm.major_id >= 0
--AND perm.class_desc <> 'DATABASE'
ORDER BY 
  prin.name, 
  perm.class,
  ObjectType,
CASE
    WHEN perm.class = 3 THEN '[' + sch.name + ']'
    WHEN cols.object_id IS NOT NULL THEN '[' + objsch.name + '].[' + obj.name + '](' + cols.name + ')'
    WHEN perm.class = 0 THEN DB_NAME()
    ELSE ISNULL('[' + objsch.name + '].[' + obj.name + ']', 'n/a')
END


--select * from sys.all_objects 
