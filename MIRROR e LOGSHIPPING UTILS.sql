-- startar o SQL com a opção -f assim ele carrega com as minimal configurations e permite alteração da base em mirror

 select * from sysdatabases 

select * from sysaltfiles -- consulta todos os arquivos das bases de dados 

-- *** Comando para alterar os arquivos de lugar
alter database PRD 
MODIFY FILE ( NAME = PRDDATA19, FILENAME = 'S:\PRD\PRDDATA019.NDF') -- H:\PRD\PRDDATA004.NDF

-- Depois basta subir o SQL em estado normal



---- PARA LOG SHIPPING MODIFICAR OS ARQUIVOS DE LUGAR SEM TER QUE PARAR A BASE...

-- Após erro de restore de log devido a novo datafile, executar o comando abaixo:
RESTORE LOG [PRD] 
FROM DISK = 'G:\Standby\PRD_200YMMDDHHMMSS.trn' 
WITH FILE = 1, 
MOVE 'DATA_FILE_LOGICALNAME' TO 'CAMINHO_+_FILENAME',
NORECOVERY,
STATS=1




RESTORE LOG [PRD] 
FROM DISK = 'G:\Standby\PRD_20081113201501.trn' 
WITH FILE = 1, 
MOVE 'PRDDATA25' TO 'U:\DADOS\PRD\PRDDATA25.ndf',
MOVE 'PRDDATA26' TO 'V:\DADOS\PRD\PRDDATA26.ndf',
MOVE 'PRDDATA27' TO 'W:\DADOS\PRD\PRDDATA27.ndf',
NORECOVERY,
STATS=1