CREATE OR REPLACE VIEW avg_timezone AS 
SELECT
	code,
	AVG(utcoffset) utcoffset
FROM timezones tz
LEFT JOIN ioc_country_codes ioc ON
	tz.Country = ioc.country
GROUP BY code
	