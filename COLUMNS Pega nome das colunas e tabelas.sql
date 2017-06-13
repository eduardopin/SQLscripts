SELECT Distinct a.name Tabela, b.name Coluna FROM sysobjects a inner join syscolumns b 
on a.id = b.id
Where
 a.type ='u' and
 b.name like '%horario%' 