CREATE TABLE countries (
	country_code CHAR(3) NOT NULL,
	country VARCHAR(50) NOT NULL
)

COPY countries FROM 'C:/Users/batte/programming/chess/data/countries.csv' (HEADER)