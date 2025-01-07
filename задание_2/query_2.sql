-- Промежуточные суммы долга на каждой выплате
WITH RunningTotalDebt AS (
  SELECT 
  	deal,
  	date,
  	sum,
  	SUM(sum) OVER (PARTITION BY deal ORDER BY date) debt
  FROM PDCL
),
-- Дата начала текущей просрочки
CurrentDebtStartDate AS (
  SELECT deal, MIN(date) min
  FROM RunningTotalDebt cw
  WHERE
    NOT EXISTS (
      SELECT * FROM RunningTotalDebt cc 
      WHERE cc.deal = cw.deal 
      AND cc.date > cw.date AND cc.debt = 0 
    ) 
    AND cw.sum > 0
  GROUP BY deal
)
-- Вывод результатов для отфильтрованных списка кредитов
SELECT 
	dm.deal,
  	debt,
  	DATEDIFF("day", min, NOW()) days,
  	min current_debt_start
FROM (
  SELECT deal, SUM(sum) debt FROM PDCL
  WHERE deal in (SELECT deal FROM PDCL GROUP BY deal HAVING SUM(sum) > 0)
  GROUP BY deal
) dm JOIN CurrentDebtStartDate cdbs ON dm.deal = cdbs.deal; 