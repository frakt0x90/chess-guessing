CREATE TABLE ioc_country_codes(code CHAR(3) NOT NULL PRIMARY KEY, country VARCHAR(100) NOT NULL)

COPY ioc_country_codes FROM 'C:/Users/batte/programming/chess/data/ioc_country_codes.csv' (HEADER);