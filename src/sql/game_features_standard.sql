COPY (SELECT
	COALESCE(BlackTitle, 'None') blacktitle,
	BlackElo blackelo,
	date_part('isodow', GameDate) gamedow,
	date_part('month', GameDate) gamemonth,
	date_part('year', GameDate) gameyear,
	GameDate - games.EventDate daysfromstart,
	CASE 
		WHEN EventType LIKE '%rapid%' THEN 'rapid'
		WHEN EventType LIKE '%blitz%' THEN 'blitz'
		ELSE 'standard'
	END timeformat,
	CASE 
		WHEN EventType LIKE '%match%' THEN 'match'
		WHEN EventType LIKE '%k.o.%' THEN 'ko'
		WHEN EventType LIKE '%swiss%' THEN 'swiss'
		WHEN EventType LIKE '%tourn%' THEN 'tourn'
		WHEN EventType LIKE '%schev%' THEN 'schev'
		WHEN Eventtype LIKE '%simul%' THEN 'simul'
		ELSE 'standard'
	END eventtype,
	GameResult gameresult,
	WhiteElo whiteelo,
	COALESCE(WhiteTitle, 'None') whitetitle,
	games.RoundNum round,
	WhiteElo - BlackElo elodiff,
	tourn_white.Score white_score,
	tourn_white.outof white_outof,
	tourn_white.movesLastGame white_moves_last_game,
	tourn_black.Score black_score,
	tourn_black.outof black_outof,
	tourn_black.movesLastGame black_moves_last_game
FROM games
JOIN tourney_score tourn_black ON
	tourn_black.fideid = games.Blackfideid AND 
	tourn_black.EventDate = games.EventDate AND 
	tourn_black.event = games.event AND 
	tourn_black.RoundNum = games.RoundNum
JOIN tourney_score tourn_white ON
	tourn_white.fideid = games.Whitefideid AND 
	tourn_white.EventDate = games.EventDate AND 
	tourn_white.event = games.event AND 
	tourn_white.RoundNum = games.RoundNum
WHERE 
	GameDate - games.EventDate < 60 AND
	BlackElo >= 2000 AND
	WhiteElo >= 2000 AND 
	Variant IS NULL AND
	timeformat = 'standard' AND
	EventType NOT LIKE '%simul%' AND
	EventType NOT LIKE '%schev%' AND 
	EventType NOT LIKE '%team%'
ORDER BY games.EventDate, whitefideid, games.RoundNum 
) TO 'C:/Users/batte/programming/chess/data/features/game_features.csv' (HEADER, DELIMITER ',');
	