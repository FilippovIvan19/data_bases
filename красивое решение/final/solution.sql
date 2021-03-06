DROP DATABASE IF EXISTS fc;
CREATE DATABASE fc;
USE fc;

DROP TABLE IF EXISTS countries_cities;
DROP TABLE IF EXISTS countries;
DROP TABLE IF EXISTS people;
DROP TABLE IF EXISTS cities;

CREATE TABLE people (
    id INT NOT NULL,
    country NVARCHAR(255),
    city NVARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE countries (
    id INT NOT NULL AUTO_INCREMENT,
    country NVARCHAR(255),
    n_cities INT,
    cities TEXT,/* CHANGED */
    n_people INT,
    PRIMARY KEY (id)
);

CREATE TABLE cities (
    id INT NOT NULL AUTO_INCREMENT,
    city NVARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE countries_cities (
    id INT NOT NULL AUTO_INCREMENT,
    country_id INT,
    city_id INT,
    PRIMARY KEY (id),
    FOREIGN KEY (country_id) REFERENCES countries(id), 
    FOREIGN KEY (city_id) REFERENCES cities(id),
    UNIQUE (country_id, city_id)
);

CREATE INDEX people_country_index ON people (country);
CREATE INDEX people_city_index ON people (city);
CREATE UNIQUE INDEX countries_country_index ON countries (country);
CREATE UNIQUE INDEX cities_city_index ON cities (city);

SET session group_concat_max_len = 10000;/* CHANGED */

--##################################

LOAD DATA LOCAL INFILE 'data.csv' 
INTO TABLE people 
FIELDS
    TERMINATED BY ';' 
    ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

--##################################

INSERT INTO countries (country) SELECT DISTINCT(country) FROM people ORDER BY country;
INSERT INTO cities (city) SELECT DISTINCT(city) FROM people ORDER BY city;

INSERT INTO countries_cities (country_id, city_id)
SELECT cur_country_id, cities.id
FROM cities INNER JOIN (
    SELECT DISTINCT countries.id AS cur_country_id, people.city AS cur_city
    FROM countries INNER JOIN people
    ON countries.country = people.country ) AS sub_table
ON cities.city = cur_city;

UPDATE countries SET/* CHANGED */
n_people = (SELECT COUNT(*) FROM people WHERE country = countries.country),
n_cities = (SELECT COUNT(*) FROM countries_cities WHERE country_id = countries.id),
cities = (
    IF (
        n_cities < 100,
        (
            SELECT GROUP_CONCAT(city SEPARATOR ', ')
            FROM cities INNER JOIN countries_cities
            ON countries_cities.city_id = cities.id
            WHERE countries_cities.country_id = countries.id
        ),
        'TO MANY CITIES'
    )
);

--##################################

SELECT * FROM countries INTO OUTFILE '/var/lib/mysql-files/countries.csv'
FIELDS
    TERMINATED BY ';' 
    ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\r\n';

SELECT * FROM cities INTO OUTFILE '/var/lib/mysql-files/cities.csv'
FIELDS
    TERMINATED BY ';' 
    ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\r\n';

sudo mv /var/lib/mysql-files/countries.csv .
sudo mv /var/lib/mysql-files/cities.csv .

python3 translate.py countries.csv contries_translated.csv 1
python3 translate.py cities.csv cities_translated.csv 1

--##################################

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

--##################################

UPDATE cities SET
cities.city = (
    SELECT tmp_cities.city
    FROM tmp_cities
    WHERE tmp_cities.id = cities.id
);

UPDATE countries SET
countries.country = (
    SELECT tmp_countries.country
    FROM tmp_countries
    WHERE tmp_countries.id = countries.id
),
cities = (
    IF (
        n_cities < 100,
        (
            SELECT GROUP_CONCAT(city SEPARATOR ', ')
            FROM cities INNER JOIN countries_cities
            ON countries_cities.city_id = cities.id
            WHERE countries_cities.country_id = countries.id
        ),
        'TO MANY CITIES'
    )
);

DROP TABLE IF EXISTS tmp_countries;
DROP TABLE IF EXISTS tmp_cities;

--##################################

--FUNCTIONS

--##################################

DROP TABLE IF EXISTS cities_for_merge;

CREATE TABLE cities_for_merge (
    id INT NOT NULL AUTO_INCREMENT,
    first NVARCHAR(255),
    second NVARCHAR(255),
    PRIMARY KEY (id)
);

INSERT INTO cities_for_merge (first, second)
SELECT A.city, B.city
FROM cities A, cities B
WHERE B.city LIKE CONCAT(A.city, '__TRANSLATED_%');

SELECT COUNT(MergeCities(first, second))
AS merged_city_pairs
FROM cities_for_merge;

DROP TABLE IF EXISTS cities_for_merge;


DROP TABLE IF EXISTS countries_for_merge;

CREATE TABLE countries_for_merge (
    id INT NOT NULL AUTO_INCREMENT,
    first NVARCHAR(255),
    second NVARCHAR(255),
    PRIMARY KEY (id)
);

INSERT INTO countries_for_merge (first, second)
SELECT A.country, B.country
FROM countries A, countries B
WHERE B.country LIKE CONCAT(A.country, '__TRANSLATED_%');

SELECT COUNT(MergeCountries(first, second))
AS merged_countries_pairs
FROM countries_for_merge;

DROP TABLE IF EXISTS countries_for_merge;

--##################################

--здесь можно ещё что-то помёржить

--##################################

CALL MakeLongCountries();

--##################################

SELECT * FROM countries INTO OUTFILE
'/var/lib/mysql-files/countries_final.csv'
FIELDS
    TERMINATED BY ';' 
    ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\r\n';

SELECT * FROM cities INTO OUTFILE
'/var/lib/mysql-files/cities_final.csv'
FIELDS
    TERMINATED BY ';' 
    ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\r\n';

SELECT * FROM long_titles
UNION
SELECT * FROM long_countries
INTO OUTFILE
'/var/lib/mysql-files/long_countries.csv'
FIELDS
    TERMINATED BY ';' 
    ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\r\n';


sudo mv /var/lib/mysql-files/countries_final.csv .
sudo mv /var/lib/mysql-files/cities_final.csv .
sudo mv /var/lib/mysql-files/long_countries.csv .


--##################################

