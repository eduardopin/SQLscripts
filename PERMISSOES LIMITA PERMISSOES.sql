SET NOCOUNT ON;
DECLARE @NewRole varchar(100), @SourceRole varchar(100);

-- Change as needed
SELECT @SourceRole = 'r', @NewRole = 'Taker';

SELECT
    state_desc + ' ' + permission_name + ' ON ' + OBJECT_NAME(major_id) + ' TO ' + @NewRole
FROM
    sys.database_permissions
WHERE
    grantee_principal_id = DATABASE_PRINCIPAL_ID(@SourceRole) AND
    -- 0 = DB,  1 = object/column, 3 = schema. 1 is normally enough
    class <= 3


	select * from sys.database_permissions where grantee_principal_id = 31
	select USER_ID('usrGCF')


select 'grant select, update, delete, insert on ' + name + ' to LK_SAP' from sysobjects where type = 'U' and name like '_DELETAR%'
select 'revoke select, update, delete, insert on ' + name + ' to LK_SAP' from sysobjects where type = 'U' and name like '_DELETAR%'
DENY SELECT, UPDATE, DELETE ON schema::[DSS] TO [LK_SAP]
DENY Execute ON schema::[DSS] TO [LK_SAP]
DENY Execute ON schema::[dbo] TO [LK_SAP]


grant select on 
DENY SELECT ON schema::[other_schema] TO [user_name]
GRANT SELECT ON schema::[safe_schema] TO [user_name]

use [Desenv_DW_PRD_MARISA]
GO
DENY ALTER ON SCHEMA::[DSS] TO [LK_SAP]
GO
use [Desenv_DW_PRD_MARISA]
GO
DENY CONTROL ON SCHEMA::[DSS] TO [LK_SAP]
GO
use [Desenv_DW_PRD_MARISA]
GO
DENY DELETE ON SCHEMA::[DSS] TO [LK_SAP]
GO
use [Desenv_DW_PRD_MARISA]
GO
DENY EXECUTE ON SCHEMA::[DSS] TO [LK_SAP]
GO
use [Desenv_DW_PRD_MARISA]
GO
DENY INSERT ON SCHEMA::[DSS] TO [LK_SAP]
GO
use [Desenv_DW_PRD_MARISA]
GO
DENY REFERENCES ON SCHEMA::[DSS] TO [LK_SAP]
GO
use [Desenv_DW_PRD_MARISA]
GO
DENY SELECT ON SCHEMA::[DSS] TO [LK_SAP]
GO
use [Desenv_DW_PRD_MARISA]
GO
DENY TAKE OWNERSHIP ON SCHEMA::[DSS] TO [LK_SAP]
GO
use [Desenv_DW_PRD_MARISA]
GO
DENY UPDATE ON SCHEMA::[DSS] TO [LK_SAP]
GO
use [Desenv_DW_PRD_MARISA]
GO
DENY VIEW CHANGE TRACKING ON SCHEMA::[DSS] TO [LK_SAP]
GO
use [Desenv_DW_PRD_MARISA]
GO
DENY VIEW DEFINITION ON SCHEMA::[DSS] TO [LK_SAP]
GO
