SELECT 
	asof,
	fideid,
	players.country,
	sex = 'M' ismale,
	games,
	asof - CAST((CAST(birthyear AS CHAR) || '-07-01') AS DATE) age,
	RANK() OVER(PARTITION BY asof ORDER BY rating desc) ranking,
	rating - LAG(rating, 6, NULL) OVER(PARTITION BY fideid ORDER BY asof desc) rating_chg_six_mon,
	rating - LAG(rating, 3, NULL) OVER(PARTITION BY fideid ORDER BY asof desc) rating_chg_thr_mon,
	rating - LAG(rating, 1, NULL) OVER(PARTITION BY fideid ORDER BY asof desc) rating_chg_one_mon--,
	utcoffset
FROM players 
LEFT JOIN avg_timezone tz ON
	players.country = tz.country_code
WHERE
	inactive = 'false' AND
	gametype = 'standard' AND 
	utcoffset IS NULL
QUALIFY rating_chg_six_mon IS NOT NULL