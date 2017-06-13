select con_dssNome, Con_dtdAdmissao, CON_Vlnsalario,Con_VlnRemuneracao Con_VlnFGTSSalAtual from contratados
where con_dssNome like '%' and CON_Vlnsalario > '12000' order by CON_Vlnsalario desc

select con_dssNome, Con_dtdAdmissao, CON_Vlnsalario,Con_VlnRemuneracao Con_VlnFGTSSalAtual from contratados
where con_dssNome like '%satin%' and CON_Vlnsalario > '6000' order by Con_VlnFGTSSalAtual desc


select con_dssNome, Con_dtdAdmissao, CON_Vlnsalario,Con_VlnRemuneracao Con_VlnFGTSSalAtual from contratados
where con_dssNome like '%' order by CON_Vlnsalario desc

select * from contratados where con_dssNome like '%Pin' and CON_Vlnsalario > '6000'

select * from contratados where con_dtdnascimentodata > '1980-01-01' and con_dtdnascimentodata < '1982-12-31'
order by CON_Vlnsalario desc

12914568772


select * from contratados where con_dssNome like '%pin'
