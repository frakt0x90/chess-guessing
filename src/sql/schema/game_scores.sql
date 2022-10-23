DROP VIEW game_scores;

CREATE VIEW game_scores AS
SELECT DISTINCT 
	WhiteFideId fideid,
	EventDate,
	event,
	RoundNum,
	Moves,
	CASE GameResult
		WHEN '1-0' THEN 1.0
		WHEN '1/2-1/2' THEN .5
		ELSE 0.0
	END score,
	1 max_score
FROM games
WHERE
	fideid IS NOT NULL AND
	EventDate IS NOT NULL
UNION ALL
SELECT DISTINCT 
	BlackFideId fideid,
	EventDate,
	event,
	RoundNum,
	Moves,
	CASE GameResult
		WHEN '1-0' THEN 1.0
		WHEN '1/2-1/2' THEN .5
		ELSE 0.0
	END score,
	1 max_sscore
FROM games
WHERE
	fideid IS NOT NULL AND 
	EventDate IS NOT NULL;