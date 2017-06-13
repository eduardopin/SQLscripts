Set NOCOUNT ON

IF exists (select * from tempdb.dbo.sysobjects where name like '%VolumeDados%')
	Drop table #VolumeDados

Create table #VolumeDados
	(
	 name 		varchar(128),
	 rows 		int,
	 reserved 	varchar(32),
	 data 		varchar(32),
	 index_size 	varchar(32),
	 unused		varchar(32)
	)

EXEC sp_MSforeachtable @command1='insert into #VolumeDados exec sp_spaceused ''?'''

--Maiores Registros
select 	[QtRegistros] = Rows,
	* 
from 	#VolumeDados
order 	by 1 desc

--Maiores Dados
select 	[Dados(KB)  ] = convert(decimal(20,0), replace(data,'KB','')),
	* 
from 	#VolumeDados
order 	by 1 desc

--Maiores Indices
select 	[Indices(KB)] = convert(decimal(20,0), replace(index_size,'KB','')),
	* 
from 	#VolumeDados
order 	by 1 desc
