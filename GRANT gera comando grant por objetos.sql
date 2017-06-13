
--  da grant nas procedures
select 'grant execute on ' + name + ' to CRM_VIRTUAL' from sysobjects where type = 'P'

--  da grant nas funções
select 'grant execute on ' + name + ' to CRM_VIRTUAL' from sysobjects where type = 'FN'

--  da grant nas views
select 'grant select on ' + name + ' to CRM_VIRTUAL' from sysobjects where type = 'V'

-- da grant nas tabelas
select 'grant select, insert, update, delete on ' + name + ' to CRM_VIRTUAL' from sysobjects where type = 'U'




