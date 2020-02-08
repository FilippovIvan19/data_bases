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
