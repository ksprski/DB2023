CREATE DATABASE db_fff;
USE db_fff;

CREATE TABLE fff15
(
id INT PRIMARY KEY AUTO_INCREMENT,
fff_tinyint TINYINT,
fff_smallint SMALLINT,
fff_float FLOAT,
fff_char CHAR(20),
fff_varchar VARCHAR(20),
fff_decimal DECIMAL(5,2),
fff_bool BOOL,
fff_time TIME, 
fff_datetime DATETIME, 
fff_year YEAR, 
fff_date DATE,
fff_text TEXT,
fff_enum ENUM("hello", "bye")
);

INSERT INTO fff15 (fff_tinyint, fff_smallint, fff_float, fff_char, fff_varchar, fff_decimal, fff_bool, fff_time, fff_datetime, fff_year, fff_date, fff_text, fff_enum)
VALUES
(127, 32767, 36.6, "bbb", "ttt", 999.99, False, "10:37:22", "2022-12-05 10:37:22", "1999", '2023-12-31', "yyy", "hello");

select * from fff15;