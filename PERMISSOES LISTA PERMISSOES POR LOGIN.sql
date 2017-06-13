sp_helpsrvrolemember 'sysadmin'

DECLARE @command varchar(1500)
SELECT @command = 'USE ? SELECT SERVERPROPERTY(''ServerName''),DB_NAME(), DbRole = g.name, MemberName = u.name, MemberSID = u.sid
			from sys.database_principals u, sys.database_principals g, sys.database_role_members m
			where   g.principal_id = m.role_principal_id
				and u.principal_id = m.member_principal_id
				and g.name = ''db_owner''
				
			order by 1, 2'
EXEC sp_MSforeachdb @command 	



EXECUTE AS user = 'CENTRAL\usr_ged'
GO
SELECT has_perms_by_name(db_name(), 'DATABASE', 'ANY')
GO
REVERT
GO
EXECUTE AS user = 'usrINTRANET'
GO
SELECT has_perms_by_name('RH_PRD', 'OBJECT', 'ANY')

			


SELECT name,
-- user_name('dbMarisa') as grantee,
 --user_name('dbmarisa') as grantor ,
 Permission_name ,
 State_desc,
 o.Type_desc
FROM sys.database_permissions dp JOIN sys.objects o on dp.major_id = o.object_id
WHERE class = 1 
AND o.type in ('U','P') -- U -USER_TABLE, P-SQL_STORED_PROCEDURE , V-- View, Fn-- Functions
AND dp.type in ('SL','IN','UP','EX') -- SL- Select, IN - Insert, Up - Update ,'Ex - Execute
ORDER BY name


SELECT prin.[name] [User], sec.state_desc + ' ' + sec.permission_name [Permission]
FROM [sys].[database_permissions] sec
  JOIN [sys].[database_principals] prin
    ON sec.[grantee_principal_id] = prin.[principal_id]
WHERE sec.class = 0
ORDER BY [User], [Permission]; 


SELECT
dp.Class,
dps1.Name As Grantee,
dps2.Name As Grantor,
so.Name,
so.Type,
dp.Permission_Name,
dp.State_Desc
FROM sys.database_permissions AS dp
JOIN Sys.Database_Principals dps1
ON dp.grantee_Principal_ID = dps1.Principal_ID
JOIN Sys.Database_Principals dps2
ON dp.grantor_Principal_ID = dps2.Principal_ID
    JOIN sys.objects AS so
    ON dp.major_id = so.object_id
    
select o.name, u.name, permission_name, state, state_desc from sys.database_permissions p
inner join sys.all_objects o on p.major_id = o.object_id
inner join sys.database_principals u on p.grantee_principal_id = u.principal_id

sp_helprotect


--
DECLARE @command varchar(1500)
SELECT @command = 'USE ? SELECT SERVERPROPERTY(''ServerName''),DB_NAME(), DbRole = g.name, MemberName = u.name, MemberSID = u.sid
			from sys.database_principals u, sys.database_principals g, sys.database_role_members m
			where   g.principal_id = m.role_principal_id
				and u.principal_id = m.member_principal_id
				and g.name = ''db_owner''
				
			order by 1, 2'
EXEC sp_MSforeachdb @command 


;with ServerPermsAndRoles as
(
    select
        spr.name as principal_name,
        spr.type_desc as principal_type,
        spm.permission_name collate SQL_Latin1_General_CP1_CI_AS as security_entity,
        'permission' as security_type,
        spm.state_desc
    from sys.server_principals spr
    inner join sys.server_permissions spm
    on spr.principal_id = spm.grantee_principal_id
    where spr.type in ('s', 'u')

    union all

    select
        sp.name as principal_name,
        sp.type_desc as principal_type,
        spr.name as security_entity,
        'role membership' as security_type,
        null as state_desc
    from sys.server_principals sp
    inner join sys.server_role_members srm
    on sp.principal_id = srm.member_principal_id
    inner join sys.server_principals spr
    on srm.role_principal_id = spr.principal_id
    where sp.type in ('s', 'u')
)
select *
from ServerPermsAndRoles
order by principal_name

