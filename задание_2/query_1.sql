-- Список кредитов, имеющих непогашенную задолженность
SELECT deal FROM PDCL GROUP BY deal HAVING SUM(sum) > 0;