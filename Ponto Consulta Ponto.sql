select * from  
ConBatidasReais where 
--CBE_CdiConBatidaReal = 94439605 and
CBE_CdiDispositivoAcesso = 902 and
CBE_CdiContratado = 940707 and
CBE_DtdBatidaData = '20110212' and
CBE_HrdBatidaHoraMinuto = '18991230 10:27:00'

select * from  
ConBatidasReais where 
CBE_CdiContratado = 940707
order by CBE_CdiConBatidaReal desc


 CBE_CdiOrigemBatidaPonto, CBE_CdiFolha_Aprop, CBE_CdiCentroCusto_Aprop, 
   CBE_CdiVisitaxVisitante, CBE_OplValido, CBE_CdiMensagemAcesso_Ultima,
    CBE_CdiFuncaoDispositivo,   CBE_CdiOcorrenciaMarcacao, CBE_OplOffLine,
     CBE_CdiTipoMarcacao, CBE_CdiCrachaExtra, CBE_NuiLog,   CBE_CosEnderecoIP,
      CBE_NuiSequencialRegistroREP) values (  94439605, 902, 940707, '20110204',   '18991230 10:27:00', 2, 0, 0,   0, 1, 0, 0,   0, 0, 0, 0, 23572941,   '', 0) 