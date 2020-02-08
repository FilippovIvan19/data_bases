CREATE DATABASE fc;
CREATE USER 'user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON * . * TO 'user'@'localhost';

sudo mysql -u user -p
password

--##################################

USE fc;

DROP TABLE countries_cities;
DROP TABLE countries;
DROP TABLE people;
DROP TABLE cities;


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
    cities MEDIUMTEXT,
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

SET session group_concat_max_len = 1000000;

--##################################

LOAD DATA LOCAL INFILE 'data.csv' 
INTO TABLE people 
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
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

UPDATE countries SET
cities = (
    SELECT GROUP_CONCAT(city SEPARATOR ', ') FROM cities INNER JOIN countries_cities ON
        countries_cities.city_id = cities.id
    WHERE countries_cities.country_id = countries.id
),
n_people = (SELECT COUNT(*) FROM people WHERE country = countries.country),
n_cities = (SELECT COUNT(*) FROM countries_cities WHERE country_id = countries.id);

--##################################

SELECT * FROM countries INTO OUTFILE '/var/lib/mysql-files/new_data.csv'
FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\r\n';

sudo mv /var/lib/mysql-files/new_data.csv .

--##################################
