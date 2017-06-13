select tapename Nome_da_Fita, seqnum Sequencia, serialnum Numero_Serial,
 convert(varchar(12),lastwrite,103) Ultima_Gravacao,
 ttlkbwritten TotalKBGravados  from astape
 where lastwrite > '01/01/2008'
 order by convert(varchar(12),lastwrite,103)