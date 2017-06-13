--This is a follow-on article from two posts:

/*Corruption: Last resorts that people try first... where I discussed the two worst things you can do (in my opinion) to a database - rebuilding the transaction log and running REPAIR_ALLOW_DATA_LOSS. 
Search Engine Q&A #4: Using EMERGENCY mode to access a RECOVERY PENDING or SUSPECT database where I introduced EMERGENCY mode and walked through an example script showing its use.
People get themselves into situations where they have no backups (or damaged backups) and the data or log files are damaged such that the only way to access the database is with EMERGENCY mode. In these situations, prior to SQL Server 2005, there was no documented or supported way to fix a database while in EMERGENCY mode - the only guidance could be found on the Internet or from calling Product Support and paying for help. The sequence of events was:

Hack the system tables to get the database into 'emergency' mode. 
Use the undocumented and unsupported DBCC REBUILD_LOG command to build a new transaction log. 
Run DBCC CHECKDB with the REPAIR_ALLOW_DATA_LOSS option to fix up corruptions in the data files - both those that may have caused the issue, and those caused by rebuilding the transaction log (e.g. because an active transaction altering the database structure was lost). 
Figure out what data was lost or is transactionally inconsistent (e.g. because a transaction altering multiple tables was lost) as far as your business logic is concerned 
Take the database out of emergency mode 
And then all the other stuff like root-cause analysis and getting a better backup strategy
I decided to add a new feature to SQL Server 2005 called EMERGENCY mode repair that will do steps 2 and 3 as an atomic operation. The reasons for this were:

Much of the advice of how to do this on the Internet missed steps out (particularly missing step 3!) 
The DBCC REBUILD_LOG command was unsupported and undocumented and we didn't like advising customers to use it 
Adding a documented last-resort method of recovering from this situation would reduce calls to Product Support - saving time and money for customers and Microsoft.
So, when in EMERGENCY mode, you can use DBCC CHECKDB to bring the database back online again. The only repair option allowed in EMERGENCY mode is REPAIR_ALLOW_DATA_LOSS and it does a lot more than usual:

Forces recovery to run on the transaction log (if it exists). You can think of this as 'recovery with CONTINUE_AFTER_ERROR' - see this post for more details on the real CONTINUE_AFTER_ERROR option for BACKUP and RESTORE. The idea behind this is that the database is already inconsistent because either the transaction log is corrupt or something in the database is corrupt in such a way that recovery cannot complete. So, given that the database is inconsistent and we're about to rebuild the transaction log, it makes sense to salvage as much transactional information as possible from the log before we throw it away and build a new one. 
Rebuild the transaction log - but only if the transaction log is corrupt. 
Run DBCC CHECKDB with the REPAIR_ALLOW_DATA_LOSS option. 
Set the database state to ONLINE.
It's a one-way operation and can't be rolled back. I always advise taking a copy of the database files before doing this in case something goes wrong or there are unrepairable errors. And if it does? Probably time to update your resume for not having a water-tight backup and disaster-recovery strategies in place. Saying that, I've never seen it fail. I can think of some pathalogical cases where it would fail though (involving the file system itself having problems) but that's really unlikely.

Let's walk-through an example of using it. I'm assuming there's a database called emergencydemo that's in the same state as at the end of the Search Engine Q&A #4 blog post - the database has no log file, is in EMERGENCY mode and the salaries table is corrupt.

First off I'll try bringing the database online, just to see what happens:*/

ALTER DATABASE emergencydemo SET ONLINE;
GO

/*File activation failure. The physical file name "C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\emergencydemo_log.LDF" may be incorrect.
The log cannot be rebuilt because the database was not cleanly shut down.
Msg 945, Level 14, State 2, Line 1
Database 'emergencydemo' cannot be opened due to inaccessible files or insufficient memory or disk space. See the SQL Server errorlog for details.
Failed to restart the current database. The current database is switched to master.
Msg 5069, Level 16, State 1, Line 1
ALTER DATABASE statement failed.

The first message makes sense - the database knows it needs to be recovered because it wasn't cleanly shut down, but the log file simply isn't there. The second message is from the new feature in 2005 that will automatically create a log file if one is missing on startup or attach - as long as the database was cleanly shut down. The 945 and 5069 errors are self-explanatory but notice that the database gets switched to master underneath us. This has bitten me several times in the past.

Well, I expected that not to work. Let's run emergency-mode repair:*/

DBCC CHECKDB (DW_PRD_CRED21, REPAIR_ALLOW_DATA_LOSS) WITH NO_INFOMSGS;
GO

--Msg 945, Level 14, State 2, Line 1
--Database 'emergencydemo' cannot be opened due to inaccessible files or insufficient memory or disk space. See the SQL Server errorlog for details.

--Hmm - looks like the failed ALTER DATABASE statement did change the state - but what to?

SELECT state_desc FROM sys.databases WHERE name='emergencydemo';
GO

state_desc
------------------------------------------------------------
RECOVERY_PENDING

--That makes sense I guess. Ok - back to emergency mode and run repair:

ALTER DATABASE emergencydemo SET EMERGENCY;
GO
DBCC CHECKDB (emergencydemo, REPAIR_ALLOW_DATA_LOSS) WITH NO_INFOMSGS;
GO

--Msg 7919, Level 16, State 3, Line 1
--Repair statement not processed. Database needs to be in single user mode.
--
--EMERGENCY mode is not SINGLE_USER mode - a database needs to be in SINGLE_USER mode for repair to run and EMERGENCY mode allows multiple connections from members of the sysadmin role. You can set SINGLE_USER mode as well as EMERGENCY mode - however, the sys.databases field state_desc will still just say EMERGENCY.

ALTER DATABASE emergencydemo SET SINGLE_USER;
GO
DBCC CHECKDB (emergencydemo, REPAIR_ALLOW_DATA_LOSS) WITH NO_INFOMSGS;
GO

--File activation failure. The physical file name "C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\emergencydemo_log.LDF" may be incorrect.
--The log cannot be rebuilt because the database was not cleanly shut down.
--Warning: The log for database 'emergencydemo' has been rebuilt. Transactional consistency has been lost. The RESTORE chain was broken, and the server no longer has context on the previous log files, so you will need to know what they were. You should run DBCC CHECKDB to validate physical consistency. The database has been put in dbo-only mode. When you are ready to make the database available for use, you will need to reset database options and delete any extra log files. 

--This time it worked. First of all we get the same error as if we tried to bring the database online - that's from the code that's trying to run 'recovery with CONTINUE_AFTER_ERROR' on the transaction log. Next we get a nice long warning that the transaction log has been rebuilt and the consequences of doing that (basically that you need to start a new log backup chain by taking a full backup). If there had been any corruptions we'd have seen the usual output from DBCC CHECKDB about what errors it found and fixed. There's also a bunch of stuff in the error log
--
--2007-10-02 17:21:20.95 spid51      Starting up database 'emergencydemo'.
--2007-10-02 17:21:20.96 spid51      Error: 17207, Severity: 16, State: 1.
--2007-10-02 17:21:20.96 spid51      FileMgr::StartLogFiles: Operating system error 2(The system cannot find the file specified.) occurred while creating or opening file 'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\emergencydemo_log.LDF'. Diagnose and correct the operating system error, and retry the operation.
--2007-10-02 17:21:20.96 spid51      Starting up database 'emergencydemo'.
--2007-10-02 17:21:21.10 spid51      Starting up database 'emergencydemo'.
--2007-10-02 17:21:21.18 spid51      Warning: The log for database 'emergencydemo' has been rebuilt. Transactional consistency has been lost. The RESTORE chain was broken, and the server no longer has context on the previous log files, so you will need to know what they were. You should run DBCC CHECKDB to validate physical consistency. The database has been put in dbo-only mode. When you are ready to make the database available for use, you will need to reset database options and delete any extra log files. 
--2007-10-02 17:21:21.18 spid51      Warning: The log for database 'emergencydemo' has been rebuilt. Transactional consistency has been lost. The RESTORE chain was broken, and the server no longer has context on the previous log files, so you will need to know what they were. You should run DBCC CHECKDB to validate physical consistency. The database has been put in dbo-only mode. When you are ready to make the database available for use, you will need to reset database options and delete any extra log files. 
--2007-10-02 17:21:21.99 spid51      EMERGENCY MODE DBCC CHECKDB (emergencydemo, repair_allow_data_loss) WITH no_infomsgs executed by ROADRUNNERPR\paul found 0 errors and repaired 0 errors. Elapsed time: 0 hours 0 minutes 1 seconds.
--
--
--Note that the usual error log entry from running DBCC CHECKDB is preceded by 'EMERGENCY MODE' this time.
--
--Checking the database state:

SELECT state_desc FROM sys.databases WHERE name='BIP';
GO

state_desc
------------------------------------------------------------
ONLINE
--
--we find that it's been brought back online again because everything worked. It's still SINGLE_USER though so let's make it MULTI_USER and see what happened to our table:

ALTER DATABASE emergencydemo SET MULTI_USER;
GO
USE EMERGENCYDEMO;
GO
SELECT * FROM salaries;
GO

FirstName            LastName             Salary
-------------------- -------------------- -----------
John                 Williamson           10000
Stephen              Brown                0
Jack                 Bauer                10000

(3 row(s) affected)

--And of course its still corrupt - because even though the transaction log was rebuilt and repaired, the original transaction that changed the salary to 0 never got a chance to rollback becuase I deleted the transaction log (in the previous post).
--
--Now remember, you should only use this as a last resort, but if you do get yourself into trouble, you know there's a command that should be able to help you
