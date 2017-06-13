 
 
 
SELECT 'Drop table ' + Ltrim('[' + TABLE_SCHEMA + '].'), + Ltrim(Rtrim('['+ TABLE_NAME + ']')) + CHAR(10) + 'go'
 FROM INFORMATION_SCHEMA.tables
 WHERE TABLE_TYPE = 'BASE TABLE' and TABLE_NAME  
 in (
'periodo_safra',
'periodo_inatividade$',
'periodo_cartao',
'perfil_status_plastico',
'perfil_status_credito',
'perfil_status_cliente',
'perfil_sexo',
'perfil_residencia',
'perfil_ocupacao',
'perfil_faixa_renda',
'perfil_faixa_inativos_safra',
'perfil_faixa_inativos',
'perfil_faixa_idade',
'perfil_faixa_compras',
'perfil_estado_civil',
'perfil_classe_profissional',
'perfil_base',
'longitude_lojas',
'infantil_10',
'infantil_09',
'dias_manaus$',
'cupons_natasha',
'cupons_hora_staging',
'CRM_PerfilConsumo',
'CRM_Cliente',
'CRM_ClasseEconomica',
'cpfs_serasa',
'clientes_serasa',
'clientes_sax',
'cessao_cart',
'amostra_serasa',
'CRM_lk_grp_campanha',
'CRM_lk_cliente_campanha',
'CRM_lk_campanha',
'CRM_ft_custo_campanha')
  