SELECT company_id, TO_CHAR(tran_dttm, 'MM.YYYY') AS month, SUM(tran_sum)
FROM tran_table
GROUP BY company_id, month
ORDER BY company_id, month;