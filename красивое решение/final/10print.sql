SELECT * FROM countries ORDER BY country INTO OUTFILE
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
