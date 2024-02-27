use world;

# Cписок стран и их среднее население, а также количество городов в каждой стране.
SELECT c.name,
IF(COUNT(ci.id) > 0, SUM(ci.population) / COUNT(ci.id), 0) AS avgPopulation, 
COUNT(ci.id) AS numOfCities
FROM country AS c
LEFT JOIN city as ci
ON c.Code = ci.countryCode
GROUP BY c.name;

# Список стран, в которых официальными языками являются как минимум два языка, среди которых должен быть испанский.
# + количество городов в каждой такой стране.
SELECT c.name, count(ci.id) AS numOfCities
FROM country AS c
LEFT JOIN city AS ci ON c.Code = ci.CountryCode
WHERE c.Code IN 
(SELECT cl.CountryCode FROM countrylanguage AS cl WHERE cl.language = 'Spanish' AND cl.isOfficial = 'T')
AND c.Code IN 
(SELECT cl.CountryCode FROM countrylanguage AS cl WHERE cl.isOfficial = 'T' GROUP BY CountryCode HAVING COUNT(cl.language)>= 2)
GROUP BY c.name;

SELECT c.name AS country_name, 
       cl.Language AS official_language, 
       COUNT(cl2.Language) AS num_official_languages
FROM country AS c
JOIN countrylanguage AS cl ON c.Code = cl.CountryCode
LEFT JOIN countrylanguage AS cl2 ON c.Code = cl2.CountryCode AND cl2.IsOfficial = 'T'
WHERE cl.Language = 'Spanish' AND cl.IsOfficial = 'T'
GROUP BY c.name, cl.Language;




SELECT * FROM countrylanguage;



# 1. Выведите страны, в которых ВНП превышает 20000.
SELECT name FROM country WHERE GNP > 20000;

# 2. Сколько стран мира используют русский язык?
SELECT c.name FROM country AS c
JOIN countrylanguage AS cl ON  cl.countrycode  = c.code 
WHERE Language = 'Russian';

# 3. Найдите страны, по площади превышающие территорию самой большой страны в Африке.
SELECT Name
FROM country
WHERE SurfaceArea > (
    SELECT MAX(SurfaceArea)
    FROM country
    WHERE Continent = 'Africa'
);


# 4. Найдите города, которые по населению превышают ровно 3 европейских государства.
SELECT ci.name FROM city AS ci
WHERE ci.population between 
(SELECT c.population FROM country AS c 
WHERE c.continent = "Europe"
ORDER BY population LIMIT 1 OFFSET 2)
 AND
(SELECT c.population FROM country AS c 
WHERE c.continent = "Europe"
ORDER BY population LIMIT 1 OFFSET 3);


# ДОП Вывести страны в которых суммарное население первых десяти городов (по населению) делится на суммарное население 10 самых маленьких.
SELECT c.Name AS Country
FROM country c
WHERE (
    SELECT SUM(top_cities.Population)
    FROM (
        SELECT city.Population
        FROM city
        JOIN country ON city.CountryCode = country.Code
        WHERE country.Code = c.Code
        ORDER BY city.Population DESC
        LIMIT 10
    ) AS top_cities
) % (
    SELECT SUM(bottom_cities.Population)
    FROM (
        SELECT city.Population
        FROM city
        JOIN country ON city.CountryCode = country.Code
        WHERE country.Code = c.Code
        ORDER BY city.Population ASC
        LIMIT 10
    ) AS bottom_cities
) = 0;













SELECT country.Name AS Country, SUM(top_cities.Population) AS TopCitiesPopulation
FROM country
LEFT JOIN city AS top_cities
    ON country.Code = top_cities.CountryCode
WHERE top_cities.Population IS NOT NULL
GROUP BY country.Code
ORDER BY country.Name;


SELECT country.Name AS Country, SUM(bottom_cities.Population) AS BottomCitiesPopulation
FROM country
LEFT JOIN city AS bottom_cities
    ON country.Code = bottom_cities.CountryCode
WHERE bottom_cities.Population IS NOT NULL
GROUP BY country.Code
ORDER BY country.Name;

SELECT 
    c.Name AS Country,
    (
        SELECT SUM(top_cities.Population)
        FROM (
            SELECT city.Population
            FROM city
            JOIN country ON city.CountryCode = country.Code
            WHERE country.Code = c.Code
            ORDER BY city.Population DESC
            LIMIT 10
        ) AS top_cities
    ) AS TopCitiesPopulation,
    (
        SELECT SUM(bottom_cities.Population)
        FROM (
            SELECT city.Population
            FROM city
            JOIN country ON city.CountryCode = country.Code
            WHERE country.Code = c.Code
            ORDER BY city.Population ASC
            LIMIT 10
        ) AS bottom_cities
    ) AS BottomCitiesPopulation
FROM country c
WHERE (
    SELECT SUM(top_cities.Population)
    FROM (
        SELECT city.Population
        FROM city
        JOIN country ON city.CountryCode = country.Code
        WHERE country.Code = c.Code
        ORDER BY city.Population DESC
        LIMIT 10
    ) AS top_cities
) % (
    SELECT SUM(bottom_cities.Population)
    FROM (
        SELECT city.Population
        FROM city
        JOIN country ON city.CountryCode = country.Code
        WHERE country.Code = c.Code
        ORDER BY city.Population ASC
        LIMIT 10
    ) AS bottom_cities
) = 0;


# для каждой страны вывести количество городов с пробелами в названии
SELECT c.name, count(city.id) AS numOfCities
FROM country AS c
LEFT JOIN city ON c.Code = city.countryCode
WHERE city.name like "% %" 
GROUP BY c.name;



SELECT c.name, IF(COUNT(city.id) > 0, COUNT(city.id), 0) AS numOfCities
FROM country AS c
LEFT JOIN city ON c.Code = city.countryCode
WHERE city.name like "% %" 
GROUP BY c.name;






# 5. Выведите страны, среднее население в городах которой превышает население в столице.
SELECT c.name FROM country AS c
LEFT JOIN city AS ci ON c.capital = ci.id
WHERE ci.population IS NULL OR ci.population < (SELECT AVG(population) FROM city WHERE countrycode = c.code);

# сохраняю в файл
SELECT c.name FROM country AS c
JOIN city AS ci ON c.capital = ci.id
WHERE ci.population < (SELECT AVG(population) FROM city WHERE countrycode = c.code)
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.1\\Uploads\\save.csv';

#SELECT @@secure_file_priv;


