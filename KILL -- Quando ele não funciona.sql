

kill 136 with statusonly
dbcc outputbuffer (66)
sp_who2 66
dbcc traceon(2520)
dbcc help ('?')
GO

dbcc traceon(3604) /* Return subsequent DBCC output to the client rather
                      than to the errorlog. */ 
go

SELECT SUSER_ID('CENTRAL\usrmssql')
SELECT SUSER_NAME(277)

SP_HELPDB dw_prd_marisa
select * from sys.dm_tran_locks where request_session_id = 136
select * from sysobjects where id = 960162616
DBCC PAGE (9,54,18867375,0)  -- (DBID,FILEID,PAGEID,PRINT OPTIONS)

select * from sysprocesses
SELECT spid,kpid, sid,uid FROM SYSPROCESSES WHERE SPID = 136 --<unkillable SPID number>
go
DBCC PSS (0)
DBCC PSS (1, 136,0) /* Where suid is from above, and spid is the
                           unkillable SPID number. */ 
go
				
select * from syslogins

--The first line of returned information will contain the pstat value.

--For example, it may be something like the following:
--pstat=0x4000, 0x800, 0x100, 0x1
--Meaning of pstat bits:

0x4000 -- Delay KILL and ATTENTION signals if inside a critical section
0x2000 -- Process is being killed
0x800  -- Process is in backout, thus cannot be chosen as deadlock victim
0x400  -- Process has received an ATTENTION signal, and has responded by
          raising an internal exception
0x100  -- Process in the middle of a single statement transaction
0x80   -- Process is involved in multi-database transaction
0x8    -- Process is currently executing a trigger
0x2    -- Process has received KILL command
0x1    -- Process has received an ATTENTION signal
				

The pstat value above would be a typical situation if a long-running data modification was canceled (for example, by clicking the Cancel Query button on a GUI application), and then the SPID was found (for a time) to block users, yet be unkillable. This situation is normal; the transaction must be backed out. It can be identified by the bits, as noted above.
Back to the top
Spid 1 Has a Status of 0000 (Running Recovery)
When starting (or restarting) SQL Server, each database must complete startup recovery before it can be used. This is seen as the first spid in sp_who having a status of 0000. It cannot be killed, and recovery should be allowed to run to completion without restarting the server. Only user spids can be killed, not system spids such as lazywriter, checkpoint, RA Manager, and so on. You also cannot kill your own spid. You can find which is your spid by doing SELECT @@SPID.


Back to the top
Server Has Intentionally Delayed Honoring KILL
In a few situations, the server intentionally defers acting on a KILL command or ATTENTION signal (a query cancellation request). An example of this is while in a critical section. These intervals are usually brief. This situation can be seen as a pstat value of 0x4000.
Back to the top
Code Path Does Not Check for KILL
If you have eliminated each of the above scenarios, it is possible that the current code path
simply is not checking for KILL. For example, before SQL Server version 6.5 Service Pack 3,
DBCC CHECKDB did not reliably respond to KILL because certain code paths did not check it. 
If all of the above situations have been excluded (that is, the user process is not waiting on I/O and not in rollback, the database is not in recovery, and
SQL Server is not intentionally deferring KILL) yet KILL is not being honored, it may be possible to enhance the server so that KILL works. To make this determination, each case must be individually examined by your primary support provider.
Back to the top
Other Information
The fact that the message "Process id 10 killed by Hostname JOE" is written to the errorlog does not confirm the KILL has actually taken place. This message is written immediately following making the kill request, but does not signify that the KILL has been honored. 
