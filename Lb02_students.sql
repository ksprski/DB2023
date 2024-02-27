CREATE DATABASE db_students;
USE db_students;
SET SQL_SAFE_UPDATES = 0;

CREATE TABLE Students2 (
    student_ID INT AUTO_INCREMENT PRIMARY KEY
    );
    

ALTER TABLE Students2
DROP PRIMARY KEY;

ALTER TABLE Students2
ADD PRIMARY KEY (student_ID);

# найти применения альтеру

#добавление индексов
ALTER TABLE Students
ADD UNIQUE INDEX index_stud (last_name);
# добавление документации
-- Добавление комментария к таблице
ALTER TABLE Students
COMMENT 'Студенты КМ 5';

ALTER TABLE Students
MODIFY COLUMN gender INT COMMENT 'Other не используем!!!!';

-- Просмотр комментария к таблице
SELECT TABLE_COMMENT
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'db_students' AND TABLE_NAME = 'Students';

SELECT COLUMN_NAME, COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'db_students'
  AND TABLE_NAME = 'Students'
  AND COLUMN_NAME = 'gender';





DROP TABLE Students;
CREATE TABLE Students (
    student_ID INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other'),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    tax ENUM("free", "paid"),
    address TEXT,
    birth_place VARCHAR(255),
    GPA DECIMAL(3,2),
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    faculty VARCHAR(50), 
    speciality VARCHAR(50), 
    EnrollYear INT, 
    GraduationYear INT 
);

-------------------- 1.1 -----------------
ALTER TABLE Students 
MODIFY COLUMN GPA DECIMAL(4, 2); 

INSERT INTO Students 
    (first_name, last_name, date_of_birth, gender, email, phone, tax, address, birth_place, GPA, faculty, speciality, EnrollYear, GraduationYear) 
VALUES 
    ('Алексей', 'Янушкевич', '2003-01-01', 'Male', 'alex1209yan@gmail.com', '1234567890',"free", '123 Street', 'Минск', 9.71, 'ММФ', 'КМиСА', 2021, 2025),
    ('Андрей', 'Шпак', '2000-02-02', 'Male', 'anshpak.by@gmail.com', '2345678901',"free", '234 Street', 'Витебск', 9.23, 'ММФ', 'КМиСА', 2021, 2025),
    ('Артур', 'Мартынов', '2000-03-03', 'Male', 'jek20031218@gmail.com', '3456789012', "free",'345 Street', 'Мозырь', 9.2, 'ММФ', 'КМиСА', 2021, 2025),
    ('Екатерина', 'Калуга', '2000-04-04', 'Female', 'katek1804@gmail.com', '4567890123',"paid", '456 Street', 'Орша', 9.31, 'ММФ', 'КМиСА', 2021, 2025),
    ('Вэй', 'Шо', '2000-05-05', 'Male', 'sanhuaqianshi@gmail.com', '5678901234', "paid", '567 Street','Ухань', 9.45, 'ММФ', 'КМиСА', 2021, 2025),
    ('Александра', 'Кольке', '2000-06-06', 'Female', 'sashka.kolke@gmail.com', '6789012345',"paid", '678 Street', 'Солигорск', 9.5, 'ММФ', 'КМиСА', 2021, 2025),
    ('Даниил', 'Мамуль', '2000-07-07', 'Male', 'onlyfufik@gmail.com', '7890123456', "free",'789 Street', 'Минск', 9.6, 'ММФ', 'КМиСА', 2021, 2025),
    ('Варвара', 'Ковалевская', '2000-08-08', 'Female', 'varvajonok@gmail.com', '8901234567', "free",'890 Street', 'Минск', 9.77, 'ММФ', 'КМиСА', 2021, 2025),
    ('Ярослав', 'Сахечидзе', '2000-09-09', 'Male', 'yaroslav.sahechidze@gmail.com', '9012345678',"free", '901 Street', 'Минск', 9.83, 'ММФ', 'КМиСА', 2021, 2025),
    ('Григорий', 'Плисюк', '2000-10-10', 'Male', 'gplisiuk@gmail.com', '0123456789', "free",'012 Street', 'Гомель', 10,'ММФ', 'КМиСА', 2021, 2025);

ALTER TABLE Students RENAME COLUMN faculty TO department; 
ALTER TABLE Students MODIFY COLUMN department VARCHAR(50) AFTER email; 

SELECT * from Students;
----------------------------------------
-------------------- 1.2 ---------------
ALTER TABLE Students
ADD COLUMN scholarship DECIMAL(8, 2),
ADD COLUMN fee DECIMAL(8, 2);
    
UPDATE Students SET scholarship = 100 WHERE tax = "free";
UPDATE Students SET fee = 1000 WHERE tax = "paid";
    
SELECT * from Students;

UPDATE Students SET scholarship = scholarship * 1.10, fee = fee * 1.15;
----------------------------------------
-------------------- 1.3 ---------------

INSERT INTO Students 
    (first_name, last_name, date_of_birth, gender, email, phone, tax, address, birth_place, GPA, department, speciality, EnrollYear, GraduationYear, scholarship) 
VALUES 
    ('Алексей', 'Яюшеич', '2003-01-01', 'Male', 'alex@gmail.com', '1234567890',"free", '123 Street', 'Минск', 9.71, 'ММФ', 'КМиСА', 2021, 2025, 110);

UPDATE Students
SET scholarship = scholarship * 1.2
WHERE LENGTH(last_name) - LENGTH(REGEXP_REPLACE(LOWER(last_name), '[-\'аеёийоуюяэ]', '')) >
    LENGTH(last_name) - LENGTH(REGEXP_REPLACE(LOWER(last_name), '[^-\'аеёийоуюяэ]', ''));


#SELECT REGEXP_REPLACE('А-АS''АА', '[^аеёийоуюяэ]', '');
#SELECT REGEXP_REPLACE('А-АSБб''ААыауЦц-', '[^бвгджзфхцчшщъь]', '');
SELECT * from Students;
#SELECT 1+ DATEDIFF(CONCAT(YEAR(CURDATE()), '-12-31'), CURDATE())/100;
#SELECT CHAR_LENGTH(REGEXP_REPLACE('ЯЮШЕИЧ', '[^бвгджзфхцчшщъьБВГДЖЗФЧЦХЧШЩЪЬ]', ''));
#SELECT REGEXP_REPLACE('ЯЮШЕИЧ', '[^бвгджзфхцчшщъьБВГДЖЗФЧЦХЧШЩЪЬ]', '');
#SELECT CHAR_LENGTH(REGEXP_REPLACE('ЯЮШЕИЧ', '[^аеёиоуяюэы]', ''));

UPDATE Students
SET Scholarship = Scholarship * (1 + (DATEDIFF(CONCAT(YEAR(CURDATE()), '-12-31'), CURDATE()) / 100));
----------------------------------------
-------------------- 1.4 ---------------
DROP TABLE Boys;
CREATE TABLE Boys (
    student_ID INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    GPA DECIMAL(4, 2)
);

INSERT INTO Boys (first_name, last_name, GPA)
SELECT first_name, last_name, GPA
FROM Students
WHERE gender = 'Male';

SELECT * FROM Boys; 

DROP TABLE Girls;
CREATE TABLE Girls (
    student_ID INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    GPA DECIMAL(4, 2)
);

INSERT INTO Girls (first_name, last_name, GPA)
SELECT first_name, last_name, GPA
FROM Students
WHERE gender = 'Female';

SELECT * FROM Girls; 
----------------------------------------
-------------------- 1.5 ---------------
USE db_chweapon;
ALTER TABLE customers RENAME TO clients; 
ALTER TABLE products ADD COLUMN licensed set("yes", "no");
ALTER TABLE products MODIFY product_description VARCHAR(100) AFTER product_category;

SELECT * FROM products;
INSERT INTO products(product_description, product_category, licensed)
VALUES 
("очень хароший", "яд", "yes"), 
("просто бомба", "взрывчатое вещество", 'no'), 
('так себе','парализующий газ','no');

UPDATE products
SET product_category = "яд"
WHERE product_id < 4;

ALTER TABLE products
MODIFY licensed bool;

ALTER TABLE products
MODIFY licensed set ("-", "+");

SELECT * FROM products;

UPDATE products
SET licensed = "-,+"
WHERE warehouse_id = 2;

UPDATE products
SET licensed = "+,-"
WHERE warehouse_id = 1;
#---------четверг

INSERT INTO orders(order_date)
VALUES 
('2023-12-30');

UPDATE orders
SET order_date = CASE 
   WHEN DAY(order_date + INTERVAL (7 - DAYOFWEEK(order_date)) % 7 + 5 DAY) % 2 = 0 THEN order_date + INTERVAL (7 - DAYOFWEEK(order_date)) % 7 + 5 DAY
   ELSE order_date + INTERVAL (7 - DAYOFWEEK(order_date)) % 7 + 12 DAY
END;

SELECT * FROM orders;
----------------------------------------
-------------------- 1.6 ---------------
USE db_students;
ALTER TABLE Students
ADD COLUMN city_id INT;

INSERT INTO Students(city_id)
VALUES 
(1),
(4),
(3), 
(1), 
(5), 
(8),
(10), 
(8),
(9),
(9);


DROP TABLE Cities;
 CREATE TABLE Cities (
    id INT PRIMARY KEY,
    city VARCHAR(255) NOT NULL
);

ALTER TABLE  Students
ADD CONSTRAINT StudCities
FOREIGN KEY (city_id)
REFERENCES Cities(id);

INSERT INTO Cities (id, city)
VALUES
    (1, 'Минск'),
    (2, 'Гродно'),
    (3, 'Могилев'),
    (4, 'Брест'),
    (5, 'Витебск'),
    (6, 'Гомель'),
    (7, 'Барановичи'),
    (8, 'Полоцк'),
    (9, 'Мозырь'),
    (10, 'Орша');
 
 select * from Cities;
 
UPDATE Students AS s
JOIN Cities AS c ON s.city_id = c.id
SET s.first_name = CONCAT(s.first_name, '.', c.city);

SELECT * FROM Students;

































#------------------ШИФР ВИЖИНЕРА-----------

CREATE TABLE vigenere_square (
  id INT PRIMARY KEY AUTO_INCREMENT,
  Vrow CHAR(32),
  a CHAR(32),
  b CHAR(32),
  c CHAR(32),
  d CHAR(32),
  e CHAR(32),
  f CHAR(32),
  g CHAR(32),
  h CHAR(32),
  i CHAR(32),
  j CHAR(32),
  k CHAR(32),
  l CHAR(32),
  m CHAR(32),
  n CHAR(32),
  o CHAR(32),
  p CHAR(32),
  q CHAR(32),
  r CHAR(32),
  s CHAR(32),
  t CHAR(32),
  u CHAR(32),
  v CHAR(32),
  w CHAR(32),
  x CHAR(32),
  y CHAR(32),
  z CHAR(32),
  y1 CHAR(32),
  z1 CHAR(32),
  y2 CHAR(32),
  z2 CHAR(32)
);

INSERT INTO vigenere_square (Vrow, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z, y1, z1, y2, z2)
VALUES
  ('а', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я'),
  ('б', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а'),
  ('в', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б'),
  ('г', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в'),
  ('д', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г'),
  ('е', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д'),
  ('ж', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е'),
  ('з', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж'),
  ('и', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з'),
  ('й', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и'),
  ('к', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й'),
  ('л', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к'),
  ('м', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л'),
  ('н', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м'),
  ('о', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н'),
  ('п', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о'),
  ('р', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п'),
  ('с', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р'),
  ('т', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с'),
  ('у', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т'),
  ('ф', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у'),
  ('х', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф'),
  ('ц', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х'),
  ('ч', 'ч', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц'),
  ('ш', 'ш', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч'),
  ('щ', 'щ', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш'),
  ('ь', 'ь', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ'),
  ('э', 'э', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь'),
  ('ю', 'ю', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э'),
  ('я', 'я', 'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ь', 'э', 'ю');

SELECT * FROM vigenere_square;
