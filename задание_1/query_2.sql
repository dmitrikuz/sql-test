SELECT company_id, SUM(tran_sum) sum
FROM tran_table
WHERE 
  tran_dttm > NOW() - INTERVAL '3 MONTH' 
  AND (
	  LOWER(tran_nazn) LIKE '%зп%' OR
	  LOWER(tran_nazn) LIKE '%зарплат%'
  )
GROUP BY company_id
ORDER BY sum DESC;