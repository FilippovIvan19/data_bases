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
