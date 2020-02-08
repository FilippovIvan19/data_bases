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
