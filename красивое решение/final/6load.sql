DROP TABLE IF EXISTS tmp_countries;

CREATE TABLE tmp_countries (
    id INT NOT NULL,
    country NVARCHAR(255),
    PRIMARY KEY (id)
);

LOAD DATA LOCAL INFILE 'countries_translated.csv' 
INTO TABLE tmp_countries 
FIELDS
    TERMINATED BY ';' 
    ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
(id, country);

-- warning here
-- это норм, говорит что из файла берутся не все столбцы


DROP TABLE IF EXISTS tmp_cities;

CREATE TABLE tmp_cities (
    id INT NOT NULL,
    city NVARCHAR(255),
    PRIMARY KEY (id)
);

LOAD DATA LOCAL INFILE 'cities_translated.csv' 
INTO TABLE tmp_cities 
FIELDS
    TERMINATED BY ';' 
    ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
(id, city);
