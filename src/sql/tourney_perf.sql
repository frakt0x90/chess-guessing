SELECT
	fideid,
	LAG(score/outof, 1, 0) OVER(PARTITION BY fideid ORDER BY EventDate) score_last_tourney,
	AVG(score/outof) OVER(PARTITION BY fideid ORDER BY EventDate) -- moving avg of last couple tournaments
FROM (
	SELECT
		fideid,
		EventDate,
		MAX(Score) score,
		MAX(max_score) outof
	FROM tourney_score
	GROUP BY fideid, EventDate 
)
