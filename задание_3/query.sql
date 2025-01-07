
-- Функция для подсчета количества дней прошедших с начала месяца и до указанной в аргументе даты
CREATE OR REPLACE FUNCTION days_since_month(DATE date) RETURNS INTEGER AS $$
BEGIN
  RETURN (EXTRACT (DAY FROM (date - DATE_TRUNC('MONTH', date)))) + 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_monthly_sums() RETURNS TABLE(month_date TEXT, month_sum NUMERIC) AS $$
	BEGIN
		SET lc_time TO 'ru_RU.utf8';
		RETURN QUERY
	-- Подсчитаем  коэффициент, с которым текущая недельная сумма будет делать вклад в текущий месяц 
	-- Например 5 дней с начала месяца - коэфф 5/7, 20 дней с начала месяца - коэфф 1
		WITH Coeffs AS (
			SELECT
		    	date,
		    	sum,
		    	CASE
		      		WHEN days_since_month(date) < 7 THEN days_since_month(date) / 7.0
		     		ELSE 1
		    	END coeff
		  	FROM
		    	(SELECT * FROM WeeklySums UNION SELECT (MAX(date) + INTERVAL '1 MONTH')::DATE, 0.0 FROM WeeklySums)
		),
		-- Вычислим и сопоставим на каждую неделю текущую сумму + коэфф. и следующую сумму + коэфф.
		Future AS(
			SELECT
		    	date,
		    	sum,
		    	coeff,
		    	COALESCE(LEAD(sum) OVER (ORDER BY date), 0) AS next_sum,
		    	COALESCE(LEAD(1 - coeff) OVER (ORDER BY date), 0) AS next_coeff
		  	FROM 
		    	Coeffs
		),
		-- Аггрегация и вычисления сумм по месяцам
		Unformated AS (
			SELECT
				(DATE_TRUNC('MONTH', date) + INTERVAL '1 MONTH' -  INTERVAL '1 DAY')::DATE month_date,
			  	ROUND(SUM(sum * coeff + next_sum * next_coeff), 2) month_sum
			FROM 
				Future
			GROUP BY 
			  	month_date
			UNION SELECT NULL, SUM(sum) FROM WeeklySums
			ORDER BY month_date
		)
		-- Форматирование
		SELECT
			TO_CHAR(u.month_date, 'dd.TMmon.YY') month_date,
			u.month_sum
		FROM
			Unformated u;

	END;
$$ LANGUAGE plpgsql;


SELECT * FROM get_monthly_sums();
