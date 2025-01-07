WITH Ranks AS(
  SELECT 
    DENSE_RANK() OVER (ORDER BY SUM(tran_sum) DESC) AS rank,
    SUM(tran_sum),
    TO_CHAR(tran_dttm, 'MM.YYYY') AS month
  FROM
    tran_table
  GROUP BY month
)
SELECT sum, month FROM Ranks
WHERE rank <= 3;