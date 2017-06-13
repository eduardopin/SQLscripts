use DW_CARGA
-- Consulta andamento da carga de estoque
select id_loja,id_dia_ref,id_dia_exp,status from carga_estoque_dwh
 where id_dia_exp >= '2010-12-28 19:10:00' 
 -- and id_dia_exp <= '2010-11-27 23:00:00'
