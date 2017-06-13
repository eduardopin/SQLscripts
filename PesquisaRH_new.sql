Use RH_PRD
GO
Select 
      CON_DssNome NOME,
       CON_DtdNascimentoData, 
       CON_Vlnsalario, 
       CON_CdiCargo Cod_cargo,
       CAR_D1sCargo Desc_Cargo,
       SIT_D1sSituacao Desc_situacao,
       CON_DtdAdmissao Data_Admissao,
       CON_NusCICNumero CPF, 
       CON_cosNumeroRG RG,
       CON_DtdInicioSituacao Data_ini_situacao, 
       CON_DtdRescisao Data_Demissao, 
       CON_DssNomePai Nome_Pai,
       CON_DssNomeMae Nome_Mae,
       CON_DssEnderecoBase Endereco,
       CON_NusCep CEP,
       e.EMP_CdiEmpresa Cod_Empresa,
       e.EMP_DssEmpresa Nome_Empresa ,
       LOC_D1sLocal Local_,
       CON_CdiSituacao Cod_situacao,
       CON_CdiContratado Cod_Contratado , 
       CEX_CosCrachaBase Num_Cracha ,
       CCU_CosEstruturaMontada CR,
       CCU_D1sCentroCusto CR_Desc
           
     From Contratados CON inner join folhas f with (nolock) on CON_CdiFolha = FOL_CdiFolha 
					   inner join situacoes with (nolock) on SIT_CdiSituacao = CON_Cdisituacao 
					   inner join ContratadosExtras COE with (nolock) on CON_CdiContratado = COE_CdiContratado
					   inner join Crachasextras CEX with (nolock) on COE_CdiCrachaExtra = CEX_CdiCrachaExtra
                       inner join locais l with (nolock) on FOL_CdiLocal = LOC_CdiLocal
                       inner join empresas e with (nolock) on l.LOC_CdiEmpresa = e.EMP_CdiEmpresa
                       Inner Join Centroscustos Ce with (nolock) on CCU_CdiCentrocusto = Con_CdiCentrocusto 
                       Inner Join Cargos c with (nolock) on Car_CdiCargo = Con_CdiCargo 
   WHERE 
    --CON_DssNome LIKE '%'-- AND
    --CAR_D1sCargo LIKE '%RECURSOS%'
	-- CAR_D1sCargo LIKE '%gerente%'
	 SIT_D1sSituacao = 'Em Atividade Normal'
      ORDER BY 3 DESC
  
  --select * from contratados where CON_DssNome LIKE 'Eduardo Jose%'-- AND