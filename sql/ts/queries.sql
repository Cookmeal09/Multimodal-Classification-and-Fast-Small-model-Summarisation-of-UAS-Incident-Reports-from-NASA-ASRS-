
-- Q1: mean and spread of the target per unit and per calendar period
SELECT unit, month(ts) AS mon, AVG(y) AS mean_target, STDDEV(y) AS sd_target, COUNT(*) AS n FROM clean GROUP BY 1, 2 ORDER BY 1, 2;
-- Q2: share of event steps (target above the 90% quantile) per unit
WITH thr AS (SELECT quantile_cont(y, 0.9) AS q FROM clean)
SELECT unit, AVG((y > q)::INT) AS event_share FROM clean, thr GROUP BY 1 ORDER BY 2 DESC;
-- Q3: target by number of findings of the first covariate (0, 1, 2, 3+)
SELECT LEAST(exog_human_factors, 3)::INT AS findings, AVG(y) AS mean_target, COUNT(*) AS n FROM clean GROUP BY 1 ORDER BY 1;
-- Q4: seasonal-naive skill check within units: correlation of the target and its value SEASON steps earlier, after removing each unit mean
WITH t AS (SELECT y AS y_, LAG(y, 4) OVER (PARTITION BY unit ORDER BY ts) AS lagged, AVG(y) OVER (PARTITION BY unit) AS mu FROM clean)
SELECT corr(y_ - mu, lagged - mu) AS r_season_within FROM t;
