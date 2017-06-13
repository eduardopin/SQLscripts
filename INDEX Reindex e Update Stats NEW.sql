select 'alter index all on [bip].[' +name+ '] rebuild' + CHAR(10) + 'go' + CHAR(10) +
'Update statistics [bip].[' + name + '] with resample ' + CHAR(10) + 'go'
  from sys.objects where type = 'U'


