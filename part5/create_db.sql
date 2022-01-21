DROP TABLE IF EXISTS qolstats;
DROP TABLE IF EXISTS country;
CREATE TABLE country (
    id SERIAL PRIMARY KEY,
    country varchar(55),
    region varchar(55)
);


/*
    Quality of Life stats of a country
*/
CREATE TABLE qolstats(
    country INT,
    happiness_rank INT,
    happiness_core REAL,
    lower_confidence_interval REAL,
    upper_confidence_interval REAL,
    gdp_per_cap REAL,
    family REAL,
    life_expectancy REAL,
    freedom REAL,
    gov_corruption REAL,
    generosity REAL,
    dystopia_residual REAL,
    CONSTRAINT fk_country FOREIGN KEY (country) REFERENCES country(id) 
);