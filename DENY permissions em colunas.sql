DENY select (Con_dtdAdmissao, 
CON_Vlnsalario,
Con_VlnRemuneracao, 
CON_DssNomePai,
CON_DssNomeMae,
CON_DssEnderecoBase ,
CON_DssEnderecoNumero,
CON_DssEnderecoComplto ) on contratados to [lnk_prev_perdas]


grant select (CON_NusCICNumero ) on contratados to usrCMO

 

