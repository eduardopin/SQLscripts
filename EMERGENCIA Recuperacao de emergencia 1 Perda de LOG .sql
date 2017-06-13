/****************************************************************************
Descri��o: Este scripts utiliza o DBCC n�o documentado DBCC REBUILD_LOG
para "TENTAR" recuperar um banco em SUSPECT ou que esteja sem o arquivo .LOG 
Ou seja,voc� tem apenas o arquivo .mdf.

Como Executar : Colocar o script no Query Analyzer e executar passo-a-passo
Selecione o passo 1 e execute, depois selecione o passo 2 e execute e assim
sucessivamente.

OBS: Altere "MyDatabase" pelo nome do banco a ser recuperado.
*****************************************************************************/

--ORIENTA��ES ANTES DE INICIAR 
	--Caso o seu banco j� estava no SQL Server e voltou com o status de SUSPECT siga para o PASSO 1

	-- Caso voc� possua apenas o arquivo .mdf que pode por exmplo ter vindo de outro servidor, siga estes passos:
		-- 1)Crie um banco no SQL Server, tendo o arquivo de dados (Data file) o mesmo tamanho que o 
		--   seu arquivo .mdf
		--   Ex: Para um arquivo MyDatabase.mdf, crie o banco MyDatabase.			     
		-- 2)Efetue um STOP nos servi�os do SQL Server
		-- 3)Localize os arquivos .mdf e .ldf do banco criado no �tem 1
		-- 4)Renomeie o arquivo .ldf para .old e substitua o arquivo .mdf criado pelo seu arquivo .mdf
		--   ELES PRECISAM TER O MESMO NOME
		-- 5)Reinicie os servi�os do SQL Server. Isto far� com que a base volte com o status SUSPECT,
		--  a partir deste ponto, siga para o PASSO 1 abaixo. 	


-- PASSO 1: Coloca o banco em Emergency Mode. O Status atual provavelmente ser� SUSPECT !
Alter database DW_PRD_CRED21 set EMERGENCY

USE MASTER
GO

EXEC sp_configure 'allow updates', 1
RECONFIGURE WITH OVERRIDE
GO

BEGIN TRAN

-- Altera o Status da base para Emergency mode
UPDATE master..sysdatabases SET status = status | 32768 WHERE name = 'DW_PRD_CRED21'

IF @@ROWCOUNT = 1
   BEGIN
       COMMIT TRAN
       RAISERROR('emergency mode set', 0, 1)
   END
ELSE
   BEGIN
       ROLLBACK
       RAISERROR('unable to set emergency mode', 16, 1)
END

GO


EXEC sp_configure 'allow updates', 0
RECONFIGURE WITH OVERRIDE
GO
-- Fim do PASSO 1

-- PASSO 2: TENTA reconstruir o log para o banco. Pode ser preciso reiniciar o SQL Server.
dbcc traceon(3604)
DBCC REBUILD_LOG('DW_PRD_CRED21')

	-- PASSO 2.1
	-- Se der erro no comando acima informando que j� existe um arquivo de log para o banco, 
	-- execute o comando abaixo informando um caminho para o arquivo de log. APENAS SE DER ESTE ERRO !!!
	dbcc traceon(3604)
	DBCC REBUILD_LOG('MyDatabase','C:\MyDatabase.ldf')

---- Fim do PASSO 2

-- PASSO 3: Execute uma checagem de integridade neste ponto.
DBCC CHECKDB ('MyDatabase')
---- Fim do PASSO 3

-- PASSO 4: Coloca o banco Operacional. (Isto � claro, caso tenha sido recuperado com sucesso.)
ALTER DATABASE MyDatabase SET MULTI_USER
GO
--- Fim do PASSO 4