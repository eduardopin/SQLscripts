create table #DB_size_hist (
DB_name varchar(50),
database_size int,
remarks varchar(30),
date smalldatetime default getdate() )

insert into #DB_size_hist (DB_name,database_size,remarks)
EXEC sp_databases

select * from #DB_size_hist

drop table #DB_size_hist