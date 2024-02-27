create database Lb02_normalise;
#drop database Lb02_normalise;
use Lb02_normalise;
set sql_safe_updates=0;

-- 2.1 --
# интересные функции для работы со строками

SELECT SOUNDEX('string') AS soundex_result;

# ELT() - возврат n-ного элемента из списка
SELECT ELT(2, 'Apple', 'Banana', 'Orange') AS selected_fruit;

SELECT QUOTE(3);

SELECT REPEAT("KM5", 3);

SELECT last_name
FROM Students
WHERE REGEXP_LIKE (last_name, 'М(ы|у|а)ртынов');


# по-другому нормализовать книги

DROP TABLE Sell;
CREATE TABLE Sell (
    author1 VARCHAR(50),
    author2 VARCHAR(50),
    title VARCHAR(50),
    ISBN INT,
    price FLOAT,
    cust_name VARCHAR(50),
    cust_address VARCHAR(100),
    purch_date DATE
);

insert into Sell
values
('David Sklar', 'Adam Trachtenberg', 'PHP Cookbook', "0515", 44.99, 'Emma Brown', 'Leaf st', '2021-10-20'),
('Danny Goodman', '', 'Dynamic HTML', "0503", 59.99, 'Daren Ryder', 'mmmm st', '2022-09-19'),
('Hugh Ewad', 'David Lane', 'PHP and mySQL', "0536", 44.95, 'Earl. B', 'Mumbai st', '1999-11-05'),
('David Sklar', 'Adam Trachtenberg', 'PHP Cookbook', "0515", 44.99, 'Daren Ryder', 'mmmm st', '2022-09-19'),
('Rasmus Lerdorf', 'Kevin Tatroe & Peter MacIntyre', 'Programming PHP', "056815", 39.99, 'David Miller', 'llssr st', '2023-09-19');

SELECT * FROM Sell;

ALTER TABLE Sell ADD COLUMN author3 VARCHAR(50);
UPDATE Sell
SET author3 = (
    SELECT
        CASE
            WHEN LOCATE('&', author2) > 0 THEN SUBSTRING_INDEX(author2, '&', -1)
            ELSE NULL
        END
);

UPDATE Sell
SET author2 = (
    SELECT
        CASE
            WHEN LOCATE('&', author2) > 0 THEN SUBSTRING_INDEX(author2, '&', 1)
            ELSE author2
        END
);

SELECT * FROM Sell;

DROP TABLE Authors;
CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    author_name VARCHAR(50) NOT NULL
);

DROP TABLE Books;
CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(50) NOT NULL,
    ISBN INT NOT NULL,
    price FLOAT NOT NULL
);

DROP TABLE Authors_Books;
CREATE TABLE Authors_Books (
    author_id INT,
    book_id INT,
    PRIMARY KEY (author_id, book_id),
    FOREIGN KEY (author_id) REFERENCES Authors(author_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

DROP TABLE customers;
CREATE TABLE Customers (
    cust_id INT PRIMARY KEY AUTO_INCREMENT,
    cust_name VARCHAR(50) NOT NULL,
    cust_address VARCHAR(100) NOT NULL
);


DROP TABLE Sales;
CREATE TABLE Sales (
    sell_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    cust_id INT,
    purch_date DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (cust_id) REFERENCES Customers(cust_id)
);


INSERT INTO Authors (author_name)
SELECT DISTINCT author1 FROM Sell WHERE length(author1) > 0 
UNION
SELECT DISTINCT author2 FROM Sell WHERE length(author2) > 0 
UNION
SELECT DISTINCT author3 FROM Sell WHERE length(author2) > 0 AND author3 IS NOT NULL;

INSERT INTO Books (title, ISBN, price)
SELECT DISTINCT title, ISBN, price FROM Sell;

INSERT INTO Customers (cust_name, cust_address)
SELECT DISTINCT cust_name, cust_address FROM Sell;

SELECT * FROM Authors;
SELECT * FROM Books;

SELECT * FROM Customers;
SELECT * FROM Sales;
SELECT * FROM Authors_Books;


INSERT INTO Sales (book_id, cust_id, purch_date)
SELECT
    B.book_id,
    C.cust_id,
    S.purch_date
FROM
    Sell S
    JOIN Books B ON S.title = B.title AND S.ISBN = B.ISBN AND S.price = B.price
    JOIN Customers C ON S.cust_name = C.cust_name AND S.cust_address = C.cust_address;

INSERT INTO Authors_Books (author_id, book_id)
SELECT distinct
    A.author_id,
    B.book_id
FROM
    Sell S
    JOIN Authors A ON S.author1 = A.author_name OR S.author2 = A.author_name
    JOIN Books B ON S.title = B.title AND S.ISBN = B.ISBN AND S.price = B.price;
    
SELECT * FROM Authors_Books;
    
    

# НФБК
CREATE TABLE example_BCNF(
project_id INT,
branch VARCHAR(50),
employee VARCHAR(50)
);

INSERT INTO example_BCNF(project_id, branch, employee)
VALUES
(1, 'Разработка', 'Иванов И.И.'),
(1,"Бухгалтерия","Сергеев С.С."),
(2,"Разработка","Иванов И.И."),
(2,"Бухгалтерия","Петров П.П."), 
(2,'Реализация','John Smith'),
(3,'Разработка','Андреев А.А.');

SELECT * FROM example_BCNF;

DROP TABLE project_employee;
CREATE TABLE project_employee
(
project_id INT, 
employee_id INT,
FOREIGN KEY (employee_id) REFERENCES main(employee_id)
);

INSERT INTO project_employee (project_id, employee_id)
SELECT e.project_id, m.employee_id
FROM example_BCNF e
JOIN main m ON e.employee = m.employee_name AND e.branch = m.branch;


DROP TABLE main;
CREATE TABLE main
(
employee_id INT primary KEY auto_increment,
employee_name VARCHAR(50),
branch VARCHAR(50)
);

INSERT INTO main(employee_name, branch)
SELECT distinct  
employee,
branch
FROM example_BCNF;

SELECT * FROM main;
SELECT * FROM project_employee;




























DROP TABLE Sell;
CREATE TABLE Sell (
    author1 VARCHAR(50),
    author2 VARCHAR(50),
    title VARCHAR(50),
    ISBN INT,
    price FLOAT,
    cust_name VARCHAR(50),
    cust_address VARCHAR(100),
    purch_date DATE
);

insert into Sell
values
('David Sklar', 'Adam Trachtenberg', 'PHP Cookbook', "0515", 44.99, 'Emma Brown', 'Leaf st', '2021-10-20'),
('Danny Goodman', '', 'Dynamic HTML', "0503", 59.99, 'Daren Ryder', 'mmmm st', '2022-09-19'),
('Hugh Ewad', 'David Lane', 'PHP and mySQL', "0536", 44.95, 'Earl. B', 'Mumbai st', '1999-11-05'),
('David Sklar', 'Adam Trachtenberg', 'PHP Cookbook', "0515", 44.99, 'Daren Ryder', 'mmmm st', '2022-09-19'),
('Rasmus Lerdorf', 'Kevin Tatroe & Peter MacIntyre', 'Programming PHP', "056815", 39.99, 'David Miller', 'llssr st', '2023-09-19');

SELECT * FROM Sell;
-- -- -- 
CREATE TABLE BBooks (
    ISBN INT PRIMARY KEY,
    title VARCHAR(50),
    author1 VARCHAR(50),
    author2 VARCHAR(50),
    price FLOAT
);
INSERT INTO BBooks (ISBN, title, author1, author2, price)
SELECT DISTINCT ISBN, title, author1, author2, price FROM Sell;

SELECT * FROM BBooks;

DROP TABLE Customers;
CREATE TABLE Customers (
    cust_id INT AUTO_INCREMENT PRIMARY KEY,
    cust_name VARCHAR(50),
    cust_address VARCHAR(100)
);
INSERT INTO Customers (cust_name, cust_address)
SELECT DISTINCT cust_name, cust_address FROM Sell;

SELECT * FROM Customers;

DROP TABLE Sales;
CREATE TABLE Sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    ISBN INT,
    cust_id INT,
    purch_date DATE,
    FOREIGN KEY (ISBN) REFERENCES BBooks(ISBN),
    FOREIGN KEY (cust_id) REFERENCES Customers(cust_id)
);

INSERT INTO Sales (ISBN, cust_id, purch_date)
SELECT 
    Sell.ISBN, 
    Customers.cust_id, 
    Sell.purch_date 
FROM Sell
INNER JOIN Customers ON Sell.cust_name = Customers.cust_name AND Sell.cust_address = Customers.cust_address;

SELECT * FROM Sales;
SELECT * FROM Customers;
SELECT * FROM BBooks;

select * from Sell;
drop table Sell;


-- 2.2 --

DROP TABLE People;
CREATE TABLE People (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    childs_names VARCHAR(100),
    childs_bds VARCHAR(100)
);

INSERT INTO People(emp_id, first_name, last_name, childs_names, childs_bds)
VALUES
(1001, 'Jane', 'Doe', 'Mary,Sam', '1/1/92,5/15/94'),
(1002, 'John', 'Doe', 'Mary,Sam', '1/1/92,5/15/94'),
(1003, 'Jane', 'Smith', 'John,Pat,Lee,Mary', '10/5/94,10/12/90,6/6/96,8/21/94'),
(1004, 'John', 'Smith', 'Michael', '7/4/96'),
(1005, 'Jane', 'Jones', 'Edward,Martha', '10/21/95,10/15/89');

SELECT * FROM People;

----- ко 2 нф ----
DROP TABLE Children;
CREATE TABLE Children (
    child_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    child_name VARCHAR(50),
    child_bd VARCHAR(50),
    FOREIGN KEY (emp_id) REFERENCES People(emp_id)
);


INSERT INTO Children (emp_id, child_name, child_bd)
SELECT emp_id, 
       SUBSTRING_INDEX(childs_names, ',', 1),
       SUBSTRING_INDEX(childs_bds, ',', 1)
FROM People
WHERE LOCATE(',', childs_names) > 0;

SELECT * FROM Children;

INSERT INTO Children (emp_id, child_name, child_bd)
SELECT emp_id, 
       SUBSTRING_INDEX(SUBSTRING_INDEX(childs_names, ',', 2), ',', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(childs_bds, ',', 2), ',', -1)
FROM People
WHERE LOCATE(',', childs_names) > 0;

INSERT INTO Children (emp_id, child_name, child_bd)
SELECT emp_id, 
       SUBSTRING_INDEX(SUBSTRING_INDEX(childs_names, ',', 3), ',', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(childs_bds, ',', 3), ',', -1)
FROM People
WHERE LOCATE(',', childs_names) > 0;

INSERT INTO Children (emp_id, child_name, child_bd)
SELECT emp_id, 
       SUBSTRING_INDEX(SUBSTRING_INDEX(childs_names, ',', 4), ',', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(childs_bds, ',', 4), ',', -1)
FROM People
WHERE LOCATE(',', childs_names) > 0;

SELECT * FROM Children;

DELETE FROM Children
WHERE emp_id IN (
    SELECT emp_id
    FROM (
        SELECT t1.emp_id
        FROM Children AS t1
        INNER JOIN Children AS t2
        ON t1.child_name = t2.child_name AND t1.child_bd = t2.child_bd AND t1.emp_id <> t2.emp_id
        LIMIT 1
    ) AS temp
);


SELECT * FROM People;

ALTER TABLE People
DROP COLUMN childs_names, 
DROP COLUMN childs_bds; 

----- к 3 нф ----
DROP TABLE Birthdays;
CREATE TABLE Birthdays (
    child_id INT auto_increment,
    child_bd VARCHAR(50),
    FOREIGN KEY (child_id) REFERENCES Children(child_id)
);

SELECT * FROM Birthdays;

INSERT INTO Birthdays (child_id, child_bd)
SELECT child_id, child_bd FROM Children;

ALTER TABLE Children
DROP COLUMN child_bd;

SELECT * FROM People;
SELECT * FROM Children;
SELECT * FROM Birthdays;


-- 3.1 -- 

CREATE TABLE Auto
(
	car_number VARCHAR(50) PRIMARY KEY ,
    car_model VARCHAR(50),
    car_year INT,
    car_price INT,
    other VARCHAR(50)
);

INSERT INTO Auto
VALUES
('АФ 1233 ФА', 'Mercedes-Benz G-400', 2002, 28000, 'Автомат, дизель, 4.0 л.'),
('FG 67 SPV', 'Mercedes-Benz G-400 AMG', 2002, 38500, 'Типтроник, дизель, 4.0 л.'),
('АО 1234 ОА', 'Toyota Sequoira', 2012, 32500, 'Автомат, бензин, 5.7 л.'),
('АО 4254 АО', 'Toyota Avalon', 2015, 21000, 'Автомат, бензин, 3.5 л.'),
('ТТ 777 МН', 'Subaru Forester', 2016, 18800, 'Автомат, бензин, 2.5 л.'),
('SS 908 KLV', 'Suzuki SX4', 2020, 19000, 'Механическая, бензин, 1.6 л.');


ALTER TABLE Auto
ADD COLUMN brand VARCHAR(50) AFTER car_number,
ADD COLUMN gear VARCHAR(50) AFTER car_price,
ADD COLUMN fuel VARCHAR(50) AFTER gear,
ADD COLUMN volume VARCHAR(50) AFTER fuel;

UPDATE Auto
SET
brand = SUBSTRING_INDEX(car_model, ' ', 1),
car_model = replace(car_model, SUBSTRING_INDEX(other, ' ', 1), ''),
gear = SUBSTRING_INDEX(other, ',', 1),
fuel = SUBSTRING_INDEX(SUBSTRING_INDEX(other, ',', -2), ',' , 1),
volume = SUBSTRING_INDEX(other, ',', -1);

ALTER TABLE Auto
DROP COLUMN other;

SELECT * FROM Auto;
UPDATE AUTO
SET car_model = right(car_model, length(car_model) - length(brand)-1);

UPDATE AUTO
SET car_model = trim(car_model);

-- 3.2 -- 

CREATE TABLE Movie
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(50),
    star VARCHAR(50),
    producer VARCHAR(50)
);

INSERT INTO Movie(title, star, producer)
VALUES
('Great Film', 'Lovely Lady', 'Money Bags'),
('Great Film', 'Handsome Man', 'Money Bags'),
('Great Film', 'Lovely Lady', 'Helen Pursestrings'),
('Great Film', 'Handsome Man', 'Helen Pursestrings'),
('Boring Movie', 'Lovely Lady', 'Helen Pursestrings'),
('Boring Movie', 'Precocious Child', 'Helen Pursestrings');

DROP TABLE Film;
CREATE TABLE Star
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    star_name VARCHAR(50)
);

CREATE TABLE Producer
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    producer_name VARCHAR(50)
);

CREATE TABLE Film
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    film_name VARCHAR(50)
);

Select * from Film;

INSERT INTO Star(star_name)
SELECT DISTINCT star FROM Movie;

INSERT INTO Film(film_name)
SELECT DISTINCT title FROM Movie;

INSERT INTO Producer(producer_name)
SELECT DISTINCT producer FROM Movie;

CREATE TABLE film_star
(
	film_id INT,
    star_id INT,
    PRIMARY KEY (film_id, star_id),
    FOREIGN KEY (film_id) REFERENCES Film(id),
    FOREIGN KEY (star_id) REFERENCES Star(id)
);

CREATE TABLE film_producer
(
	film_id INT,
    producer_id INT,
    PRIMARY KEY (film_id, producer_id),
    FOREIGN KEY (film_id) REFERENCES Film(id),
    FOREIGN KEY (producer_id) REFERENCES Producer(id)
);

INSERT INTO film_star
SELECT DISTINCT (SELECT id FROM Film WHERE film_name = Movie.title), (SELECT id FROM Star WHERE star_name = Movie.star) from Movie;

INSERT INTO film_producer
SELECT DISTINCT (SELECT id FROM Film WHERE film_name = Movie.title), (SELECT id FROM Producer WHERE producer_name = Movie.producer) from Movie;

SELECT * FROM film_producer;
SELECT * FROM film_star;
SELECT * FROM Film;

-- 3.3 -- 

CREATE TABLE Course (
    id INT PRIMARY KEY AUTO_INCREMENT,
    surname VARCHAR(50),
    course VARCHAR(50),
    book VARCHAR(50)
);

INSERT INTO Course(surname, course, book)
VALUES
('А', 'Информатика', 'Информатика'),
('А', 'Сети ЭВМ', 'Информатика'),
('А', 'Информатика', 'Сети ЭВМ'),
('А', 'Сети ЭВМ', 'Сети ЭВМ'),
('В', 'Программирование', 'Программирование'),
('В', 'Программирование', 'Теория алгоритмов');

CREATE TABLE Surname
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    surname VARCHAR(50)
);

CREATE TABLE CCourse
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    course VARCHAR(50)
);

CREATE TABLE Book
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    book VARCHAR(50)
);

INSERT INTO Surname(surname)
SELECT DISTINCT surname FROM Course;

INSERT INTO CCourse(course)
SELECT DISTINCT course FROM Course;

INSERT INTO Book(book)
SELECT DISTINCT book FROM Course;

CREATE TABLE surname_course
(
	surname_id INT,
    course_id INT,
    PRIMARY KEY (surname_id, course_id),
    FOREIGN KEY (surname_id) REFERENCES Surname(id),
    FOREIGN KEY (course_id) REFERENCES CCourse(id)
);

CREATE TABLE book_course
(
	book_id INT,
    course_id INT,
    PRIMARY KEY (book_id, course_id),
    FOREIGN KEY (book_id) REFERENCES Book(id),
    FOREIGN KEY (course_id) REFERENCES CCourse(id)
);

INSERT INTO surname_course
SELECT DISTINCT (SELECT id FROM Surname WHERE surname = Course.surname), (SELECT id FROM CCourse WHERE course = Course.course) from Course;

INSERT INTO book_course
SELECT DISTINCT (SELECT id FROM Book WHERE book = Course.book), (SELECT id FROM CCourse WHERE course = Course.course) from Course;

SELECT * FROM surname_course;
SELECT * FROM book_course;
-- 3.4 -- 

CREATE TABLE Cart
(
	id INT  PRIMARY KEY AUTO_INCREMENT,
    cart_number INT,
    cart_start VARCHAR(50),
    cart_end VARCHAR(50),
    tariff VARCHAR(50)
);

INSERT INTO Cart(cart_number, cart_start, cart_end, tariff)
VALUES
(1, '9:30', '10:30', 'Бережливый'),
(1, '11:00', '12:00', 'Бережливый'),
(1, '14:00', '15:30', 'Стандарт'),
(2, '10:00', '11:30', 'Премиум-В'),
(2, '11:30', '13:30', 'Премиум-В'),
(2, '15:00', '16:30', 'Премиум-А');

DROP TABLE TariffCourt;
CREATE TABLE TariffCourt
(
	tariff_name VARCHAR(50) PRIMARY KEY,
    court_number INT
);

DROP TABLE TariffTime;
CREATE TABLE TariffTime
(
	tariff VARCHAR(50),
    tariff_start VARCHAR(50),
    tariff_end VARCHAR(50),
    PRIMARY KEY (tariff, tariff_start, tariff_end),
    FOREIGN KEY (tariff) REFERENCES TariffCourt(tariff_name)
);

INSERT INTO TariffCourt
SELECT DISTINCT tariff, cart_number from Cart;

INSERT INTO TariffTime
select tariff, cart_start, cart_end from Cart;

SELECT * FROM TariffTime;
SELECT * FROM TariffCourt;

