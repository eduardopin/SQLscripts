-- owner de tabelas
select 'sp_changeobjectowner ''svm.' + name + '''' + ', ''dbo''' + char(13) + char(10) + 'GO' from Sysobjects where xtype = 'u'
-- owner de views
select 'sp_changeobjectowner ''svm.' + name + '''' + ', ''dbo''' + char(13) + char(10) + 'GO' from Sysobjects where xtype = 'V'

sp_change_users_login 'update_one', 'apdata', 'apdata'
go