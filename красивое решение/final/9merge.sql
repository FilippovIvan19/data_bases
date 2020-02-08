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
