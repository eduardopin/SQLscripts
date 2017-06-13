SELECT easycode, count(*)
FROM tbl_retorno_mailing
GROUP BY easycode
HAVING count(*) > 1
