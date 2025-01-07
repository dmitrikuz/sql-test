SELECT
  g.date,
  val,
  SUM(val) OVER (ORDER BY g.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) RunningTotal
FROM
 (SELECT generate_series::DATE date FROM generate_series('2018-01-01'::date, NOW(), '1 day')) g 
 LEFT JOIN 
 (SELECT SUM(val) val, date FROM table1 GROUP BY date) t -- просуммируем значения для строк с одинаковой датой
 ON g.date = t.date
ORDER BY g.date