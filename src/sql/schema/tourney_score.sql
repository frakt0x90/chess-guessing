DROP VIEW tourney_score;

CREATE VIEW tourney_score AS
SELECT 
	fideid,
	EventDate,
	event,
	RoundNum,
	SUM(Score) OVER(PARTITION BY fideid, eventdate, event ORDER BY RoundNum) Score,
	SUM(max_score) OVER(PARTITION BY fideid, eventdate, event ORDER BY RoundNum) outof,
	LAG(Moves, 1, 0) OVER(PARTITION BY fideid, eventdate, event ORDER BY RoundNum) movesLastGame
FROM game_scores
ORDER BY fideid, EventDate, Event, RoundNum;