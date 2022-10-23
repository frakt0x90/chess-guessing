CREATE TABLE players (
	fideid VARCHAR(20) NOT NULL,
	name VARCHAR(100) NULL,
	country VARCHAR(100) NULL,
	sex CHAR(1) NULL,
	title VARCHAR(3) NULL,
	rating INT NULL,
	games INT NULL,
	k INT NULL,
	birthyear INT NULL,
	inactive VARCHAR(5) NULL,
	asof DATE NOT NULL,
	gametype VARCHAR(20)
)

COPY players FROM 'C:/Users/batte/programming/chess/data/players.csv' (HEADER, DATEFORMAT '%Y-%m-%d')