
United States 	Change 	| 	All Microsoft Sites
Microsoft Help and Support
 

powered byLive Search

    * Help and Support Home
    *  
    * Select a Product
    *  
    * Advanced Search

Article ID: 171224 - Last Review: October 28, 2003 - Revision: 3.0
INF: Understanding How the Transact-SQL KILL Command Works
Retired KB ArticleRetired KB Content Disclaimer
View products that this article applies to.
This article was previously published under Q171224
On This Page

    * SUMMARY
    * MORE INFORMATION
          o Spid Is Waiting on a Network I/O
          o The Spid Is Rolling Back (Also Called Being "in Backout")
          o Spid 1 Has a Status of 0000 (Running Recovery)
          o Server Has Intentionally Delayed Honoring KILL
          o Code Path Does Not Check for KILL
          o Other Information

Expand all | Collapse all
SUMMARY
The Transact-SQL KILL command is used to abruptly end a SQL Server process. Eac...
The Transact-SQL KILL command is used to abruptly end a SQL Server process. Each process is often called a System Process ID (spid). The SQL Enterprise Manager Kill Process button under Current Activity merely sends a Transact-SQL KILL command to the server, so the server-side KILL mechanism is the same in this case.

A spid may respond to the KILL command immediately, or after a delay, or not at all. A delayed or non-responsive KILL command can be normal under some conditions. This article discusses how the KILL command works, what these delayed or non-response conditions are, and how to identify them.
NOTE: This article discusses a DBCC command (DBCC PSS) that is unsupported, and may cause unexpected behavior. Microsoft cannot guarantee that you can solve problems that result from the incorrect use of this DBCC command. Use this DBCC command at your own risk. This DBCC command may not be available in future versions of SQL Server. For a list of the supported DBCC commands, see the "DBCC" topic in the Transact-SQL Reference section of SQL Server Books Online.
Back to the top
MORE INFORMATION
Each database connection forms a row in sysprocesses, sometimes called a spid o...
Each database connection forms a row in sysprocesses, sometimes called a spid or System Process ID. In SQL Server terminology, each connection is also called a "process," but this does not imply a separate process context in the usual sense. In SQL Server 6.0 and 6.5, each process is roughly analogous to and serviced by a separate operating system thread. Each database connection also consists of server data structures that keep track of process status, transaction state, locks held, and so on. One of these structures is called the Process Status Structure (PSS), of which there is one per connection. The server scans the list of PSSs to materialize the sysprocesses virtual table. The CPU and physical_io columns from sysprocesses are derived from the equivalent values in each PSS.

The Transact-SQL KILL command posts a "kill yourself" message to the spid's Process Slot Structure. It appears there as a status bit, which the spid periodically interrogates. If the spid is executing a code path that does not interrogate the PSS status field, the KILL is not honored. Some known conditions where this situation can occur are given below. Most of these are considered expected behavior, and are not considered bugs.
Back to the top
Spid Is Waiting on a Network I/O
If the client does not fetch all result rows, the server will eventually be forced to wait when writing to the client. This is seen as a sysprocesses.waittype of 0x0800. While waiting on the network, no SQL Server code is being run that can interrogate the PSS and detect a KILL command. If the spid holds locks prior to waiting on the network I/O, it may block other processes.

If the network connection times out or is manually canceled, the SQL thread waiting on the network I/O will take an error return, thus being freed up to scan its PSS and respond to a KILL. You can manually close a named pipes connection with the NET SESSION or NET FILES command, or equivalent Server Manager command. Other IPC sessions such as TCP/IP and SPX/IPX cannot be manually closed, and the only option in this case is adjusting the session timeout for the particular IPC to a shorter value. For more information, see the following article in the Microsoft Knowledge Base:
137983  (http://support.microsoft.com/kb/137983/EN-US/ ) : How to Troubleshoot Orphaned Connections in SQL Server


Back to the top
The Spid Is Rolling Back (Also Called Being "in Backout")
If the transaction aborts for any reason, it must roll back. If it is a long-running transaction, it may take as long to roll back as to apply the transaction. This includes long-running implicit transactions such as single SELECT INTO, DELETE, or UPDATE statements. While it is rolling back it cannot be killed; otherwise, the transactional changes would not be backed out consistently.

The unkillable rollback scenario can often be identified by observing the sp_who output, which may indicate the ROLLBACK command. On SQL Server version 6.5 Service Pack 2 or later, a ROLLBACK status has been added to sysprocesses.status, which will also appear in sp_who output or the SQL Enterprise Manager "current activity" screen. However, the most reliable way to get this information is to inspect the DBCC PSS of the blocking SPID in question, and observing the pstat value. For example:

dbcc traceon(3604) /* Return subsequent DBCC output to the client rather
                      than to the errorlog. */ 
go
SELECT SUID FROM SYSPROCESSES WHERE SPID=<unkillable SPID number>
go
DBCC PSS (suid, spid, 0) /* Where suid is from above, and spid is the
                           unkillable SPID number. */ 
go
				


The first line of returned information will contain the pstat value.

For example, it may be something like the following:
pstat=0x4000, 0x800, 0x100, 0x1

Meaning of pstat bits:

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
If you have eliminated each of the above scenarios, it is possible that the current code path simply is not checking for KILL. For example, before SQL Server version 6.5 Service Pack 3, DBCC CHECKDB did not reliably respond to KILL because certain code paths did not check it. If all of the above situations have been excluded (that is, the user process is not waiting on I/O and not in rollback, the database is not in recovery, and SQL Server is not intentionally deferring KILL) yet KILL is not being honored, it may be possible to enhance the server so that KILL works. To make this determination, each case must be individually examined by your primary support provider.
Back to the top
Other Information
The fact that the message "Process id 10 killed by Hostname JOE" is written to the errorlog does not confirm the KILL has actually taken place. This message is written immediately following making the kill request, but does not signify that the KILL has been honored.

Back to the top
APPLIES TO

    * Microsoft SQL Server 6.0 Standard Edition
    * Microsoft SQL Server 6.5 Standard Edition

Back to the top
Keywords: 
	kbinfo kbusage KB171224
Back to the top
Retired KB ArticleRetired KB Content Disclaimer
This article was written about products for which Microsoft no longer offers support. Therefore, this article is offered "as is" and will no longer be updated.
Back to the top
 
Provide feedback on this article
Did this article help you solve your problem?
	Yes
	No
	Partially
	I do not know yet
	
Strongly Agree								Strongly Disagree
	9	8	7	6	5	4	3	2	1
The article is easy to understand
									
The article is accurate
									
Additional Comments:
To protect your privacy, do not include contact information in your feedback.
		
Thank you! Your feedback is used to help us improve our support content. For more assistance options, please visit the Help and Support Home Page.
		
	
	
Get Help Now
Contact a support professional by E-mail, Online, or Phone
Article Translations
	 	
Page Tools

    * Print this page
    * E-mail this page

	
Get Help Now
Contact a support professional by E-mail, Online, or Phone
Help and Support
Services Agreement
Contact Us	|	Terms of Use	|	Trademarks	|	Privacy Statement
	
Microsoft Microsoft
©2009 Microsoft
