SELECT * FROM tran_table WHERE
(tran_dttm, acc_numb) IN (
	SELECT MAX(tran_dttm), acc_numb FROM tran_table
	WHERE DATE_PART('MONTH', tran_dttm) = 5
	GROUP BY acc_numb
)
ORDER BY acc_numb;
