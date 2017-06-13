select * from sys.dm_io_pending_io_requests 
-- retorna o consumo de IO por cada datafile do banco de dados, o primeiro parametro é a base de dados
-- e o segundo é o datafile que se deseja verificar
SELECT * FROM sys.dm_io_virtual_file_stats(Null, Null)
order by num_of_reads desc;
GO
--For monitoring I/O the most interesting numbers are @@IO_BUSY, @@Total_READ 
and @@TOTAL_WRITE. Here is a simple query that shows the raw statistics:
-- Take a look at raw I/O Statistics
SELECT @@TOTAL_READ [Total Reads]
     , @@TOTAL_WRITE as [Total Writes]
     , CAST(@@IO_BUSY as FLOAT) * @@TIMETICKS / 1000000.0 as [IO Sec]
GO
/*(Results) 
Total Reads Total Writes IO Sec  
----------- ------------ ----------- 
      85336       322109      25.375

When using the functions @@IO_BUSY, @@CPU_BUSY, and @@IDLE, the function returns clock ticks. To convert ticks to seconds, multiply by @@TIMERTICKS and then divide by one million. Be sure to convert the quantities to floating point, numeric, or bigint to avoid integer overflow during intermediate calculations. 
*/


/*Using fn_virtualfilestats to Get I/O Statistics
fn_virtualfilestats returns a table of I/O statistics at the file level. It takes two parameters: the Db_ID of a database to retrieve information for and the file_id of the file to retrieve information for. Supplying -1 to either of the parameters asks for all information about the dimension. For example, executing this query:
*/
     select * from ::fn_virtualfilestats(-1, -1)

--asks for information about all files in all databases.  Executing 

     select * from ::fn_virtualfilestats(-1, 2)

-- asks for information about file number 2, usually the first log file, for all databases. 
--Table 2 lists the output columns for fn_virtualfilestasts. All measurements are "since the instance started."




