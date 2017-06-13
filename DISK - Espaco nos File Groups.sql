SET NOCOUNT ON

DECLARE @cmdSQL AS VARCHAR(1000)

CREATE TABLE ##tbFileStats (
[fileId] SMALLINT PRIMARY KEY,
[fileGroup] SMALLINT NOT NULL,
[totalExtents] INT NOT NULL,
[usedExtents] NUMERIC(12,0) NOT NULL,
[name] VARCHAR(256) NOT NULL,
[fileName] VARCHAR(256) NOT NULL)

SET @cmdSQL = 'INSERT INTO ##tbFileStats EXEC (''USE PRD  DBCC SHOWFILESTATS'')'
EXEC (@cmdSQL)

IF EXISTS (SELECT 1
		FROM ##tbFileStats a
			INNER JOIN PRD.dbo.sysfilegroups b
				ON a.[fileGroup] = b.[groupid]
		GROUP BY b.[groupname]
		HAVING 	SUM((([totalExtents]-[usedExtents])*64)/1024.0) < 50000 )


	EXEC msdb..sp_send_dbmail 	@profile_name = 'DBA',
					@recipients = 'grpDBA@marisa.com.br;',
					@body = 'Verificar espaço livre nos FILEGROUPs abaixo:
		
	',
					@query = 'SET NOCOUNT ON 
				SELECT  CAST(b.[groupname] AS VARCHAR(10)) AS [FILEGROUP], 
					CAST(SUM(([totalExtents]*64)/1024.0) AS NUMERIC(10,2)) AS [SPACE_TOTAL (MB)],  
					CAST(SUM((([totalExtents]-[usedExtents])*64)/1024.0) AS NUMERIC(10,2)) AS [FREE_SPACE (MB)], 
					CAST(SUM((([totalExtents]-[usedExtents])*64)/1024.0)/SUM(([totalExtents]*64)/1024.0)*100  AS NUMERIC(3,2)) AS [PERCENT_FREE]
				FROM ##tbFileStats a
					INNER JOIN PRD..sysfilegroups b
						ON a.[fileGroup] = b.[groupid]
				GROUP BY CAST(b.[groupname] AS VARCHAR(10))
				HAVING 	SUM((([totalExtents]-[usedExtents])*64)/1024.0) < 50000',
					@subject = 'FILEGROUP FREE SPACE < 50 Gb!'

DROP TABLE ##tbFileStats