DROP FUNCTION IF EXISTS MergeCountries;

DELIMITER $$
CREATE FUNCTION MergeCountries (
    first NVARCHAR(255),
    second NVARCHAR(255)
)
RETURNS INT
BEGIN
    DECLARE first_id, second_id INT;

    SELECT id FROM countries WHERE country = first INTO first_id;
    SELECT id FROM countries WHERE country = second INTO second_id;

    -- пересичтывает людей и города
    UPDATE countries SET
        n_people = (SELECT * FROM (
            SELECT SUM(n_people) FROM countries
            WHERE country = first OR country = second
        ) AS tmp_t1),
        n_cities = (SELECT * FROM (
            SELECT SUM(n_cities) FROM countries
            WHERE country = first OR country = second
        ) AS tmp_t2)
    WHERE country = first;

    -- удвляет записи об одном городе в двух странах
    DELETE FROM countries_cities WHERE id IN ( SELECT * FROM (
        SELECT B.id
        FROM countries_cities A, countries_cities B
            WHERE A.country_id = first_id AND
                B.country_id = second_id AND
                A.city_id = B.city_id
    ) AS tmp_t1);

    -- передаёт неповторяющиеся города
    UPDATE countries_cities SET
        country_id = first_id
    WHERE country_id = second_id;

    -- переписывает строку с городами
    UPDATE countries SET
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
    )
    WHERE countries.id = first_id;

    -- удаляет упоминание второй страны
    DELETE FROM countries WHERE country = second;
    RETURN first_id;
END$$
DELIMITER ;



DROP FUNCTION IF EXISTS MergeCities;

DELIMITER $$
CREATE FUNCTION MergeCities (
    first NVARCHAR(255),
    second NVARCHAR(255)
)
RETURNS INT
BEGIN
    DECLARE first_id, second_id INT;

    SELECT id FROM cities WHERE city = first INTO first_id;
    SELECT id FROM cities WHERE city = second INTO second_id;

    -- удаляет записи о об одной стране с двумя городами
    DELETE FROM countries_cities WHERE id IN ( SELECT * FROM (
        SELECT B.id
        FROM countries_cities A, countries_cities B
            WHERE A.city_id = first_id AND
                B.city_id = second_id AND
                A.country_id = B.country_id
    ) AS tmp_t1);

    -- передаёт неповторяющиеся страны
    UPDATE countries_cities SET
        city_id = first_id
    WHERE city_id = second_id;

    -- переписывает строку с городами и пересчитывает города
    UPDATE countries SET
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
    ),
    n_cities = (SELECT COUNT(*) FROM countries_cities WHERE country_id = countries.id);

    -- удаляет упоминания второго города
    DELETE FROM cities WHERE city = second;
    RETURN first_id;
END$$
DELIMITER ;

--##################################

DROP PROCEDURE IF EXISTS MakeLongCountries;

DELIMITER $$
CREATE PROCEDURE MakeLongCountries()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE name NVARCHAR(255);

    DECLARE cur CURSOR FOR
    SELECT country
    FROM countries
    WHERE n_cities >= 100;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;


    DROP TABLE IF EXISTS long_countries;
    CREATE TABLE long_countries (
        id INT NOT NULL AUTO_INCREMENT,
        PRIMARY KEY (id)
    );

    DROP TABLE IF EXISTS long_titles;
    CREATE TABLE long_titles (
        id INT,
        PRIMARY KEY (id)
    );
    INSERT INTO long_titles VALUES (0);

    DROP TABLE IF EXISTS long_tmp;
    CREATE TABLE long_tmp (
        id INT NOT NULL AUTO_INCREMENT,
        cities NVARCHAR(255),
        PRIMARY KEY (id)
    );


    OPEN cur;

    looop: LOOP
        FETCH cur INTO name;
        IF done THEN
            LEAVE looop;
        END IF;

        SET @str = CONCAT('ALTER TABLE long_copy ADD ', name, ' VARCHAR(255)');

        SET @str01 = CONCAT('ALTER TABLE long_titles ADD ', name, ' VARCHAR(255)');
        SET @str02 = CONCAT('UPDATE long_titles SET ', name, ' = "', name, '" WHERE id = 0');
        
        SET @str1 = CONCAT('
            INSERT INTO long_tmp (cities)
            SELECT city
            FROM cities INNER JOIN countries_cities
            ON countries_cities.city_id = cities.id
            WHERE countries_cities.country_id = 
            (
                SELECT id
                FROM countries
                WHERE country = "', name, '"
            );'
        );
        
        SET @str2 = CONCAT('
            INSERT INTO long_copy (id, ', name, ')
            SELECT *
            FROM long_tmp
            WHERE id > (SELECT COUNT(*) FROM long_countries);'
        );
        
        
        DROP TABLE IF EXISTS long_copy;
        CREATE TABLE long_copy
        LIKE long_countries;
        
        PREPARE add_col FROM @str;
        EXECUTE add_col;
        DEALLOCATE PREPARE add_col;
        
        PREPARE add_tit FROM @str01;
        EXECUTE add_tit;
        DEALLOCATE PREPARE add_tit;
        
        PREPARE upd_tit FROM @str02;
        EXECUTE upd_tit;
        DEALLOCATE PREPARE upd_tit;

        PREPARE read_tbl FROM @str1;
        EXECUTE read_tbl;
        DEALLOCATE PREPARE read_tbl;


        INSERT INTO long_copy
        SELECT long_countries.*, long_tmp.cities
        FROM long_countries LEFT JOIN long_tmp
        USING (id);

        IF ((SELECT COUNT(*) FROM long_countries) < (SELECT COUNT(*) FROM long_tmp)) THEN
            PREPARE fill_tbl FROM @str2;
            EXECUTE fill_tbl;
            DEALLOCATE PREPARE fill_tbl;
        END IF;


        DROP TABLE long_countries;
        CREATE TABLE long_countries
        SELECT *
        FROM long_copy;

        TRUNCATE TABLE long_tmp;
    END LOOP;

    CLOSE cur;

    DROP TABLE long_copy;
    DROP TABLE long_tmp;
END$$
DELIMITER ;

