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
