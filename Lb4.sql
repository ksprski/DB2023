create database mmf2020;
use mmf2020;
set sql_safe_updates=0;
# сделать номера студаков студентам
SELECT * FROM studs;
SELECT * FROM subjects;
SELECT * FROM st_group;
SELECT * FROM group_subjects;

SELECT * FROM attendance;
SELECT * FROM activities;

SELECT * FROM attendance
WHERE student_id = 37;

INSERT INTO st_group(enroll_year, num, course, speciality)
VALUES
(2023, 11, 1, "Пед");

INSERT INTO studs (st_name, st_surname, st_group_id, st_form, st_birthdate)
VALUES
('Федор', 'Иванченко', 14, 'budget', '2004-11-12');

INSERT INTO group_subjects (st_group_id, sub_id, sub_teacher_practice, sub_teacher_lecture, credit, exam)
VALUES
(14, 1, 'Васильев', 'Алексеев', TRUE, TRUE),
(14, 3, 'Сидоров', 'Евгеньев', TRUE, TRUE),
(14, 5, 'Калантай', 'Калантай', TRUE, FALSE),
(14, 7, 'Ильин', 'Ильин', FALSE, TRUE),
(14, 9, 'Васильев', 'Морозов', TRUE, FALSE),
(14, 12, 'Игнатенко', 'Морозов', FALSE, TRUE),
(14, 13, 'Алексеев', 'Алексеев', FALSE, TRUE);

# экзамены нашего Юрия
SELECT subjects.sub_id, subjects.sub_name, group_subjects.sub_teacher_lecture
FROM group_subjects
JOIN subjects ON group_subjects.sub_id = subjects.sub_id
WHERE group_subjects.st_group_id IN (
    SELECT st_group_id
    FROM studs
    WHERE st_id = 39
) AND group_subjects.exam = TRUE;

# зачеты нашего Юрия
SELECT subjects.sub_id, subjects.sub_name, group_subjects.sub_teacher_lecture
FROM group_subjects
JOIN subjects ON group_subjects.sub_id = subjects.sub_id
WHERE group_subjects.st_group_id IN (
    SELECT st_group_id
    FROM studs
    WHERE st_id = 39
) AND group_subjects.credit = TRUE;

# сдаем зачеты
INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2023-12-15', 2, 39, 0); #нельзя вставить не тот предмет

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2023-12-15', 1, 37, 0); #незачет у Юры

SELECT * FROM credits
WHERE ref_st_id = 37;

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2023-12-16', 5, 37, 0); #незачет по физре

SELECT * FROM studs
WHERE st_id = 37;

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2023-12-15', 9, 37, 0); # второй незачет (не считая физкультуру)

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2023-12-15', 3, 37, 1); # последний предмет сдал


# Попытаемся сдать экзамены
SELECT subjects.sub_id, subjects.sub_name, group_subjects.sub_teacher_lecture
FROM group_subjects
JOIN subjects ON group_subjects.sub_id = subjects.sub_id
WHERE group_subjects.st_group_id IN (
    SELECT st_group_id
    FROM studs
    WHERE st_id = 37
) AND group_subjects.exam = TRUE;

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 1, 37, 3, 0.5); #  не получается

# пересдадим зачеты кроме физкультуры

UPDATE credits
SET result = 1
WHERE ref_st_id = 37 AND ref_sub_id = 1; 

SELECT * FROM studs
WHERE st_id = 37;

SELECT * FROM credits
WHERE ref_st_id = 37;

UPDATE credits
SET result = 0
WHERE ref_st_id = 37 AND ref_sub_id = 9; # вторая пересдача

UPDATE credits
SET result = 1
WHERE ref_st_id = 37 AND ref_sub_id = 9; # теперь получилось

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 2, 37, 4, 0.5); # пытались вставить не тот экзамен

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 1, 37, 4, 0.5); 

#забыла вставить текущие для Юрия, сейчас сделаем
INSERT INTO attendance(attendance_date, student_id, subject_id, attendance_TF, grade)
VALUES 
('2023-09-11', 37, 3, TRUE, 8),
('2023-09-12', 37, 3, TRUE, 9),
('2023-09-15', 37, 3, TRUE, 10),
('2023-09-11', 37, 7, TRUE, 7),
('2023-09-13', 37, 7, TRUE, 6),
('2023-10-14', 37, 7, FALSE, NULL),
('2023-10-15', 37, 7, TRUE, 9),
('2023-10-11', 37, 12, TRUE, NULL),
('2023-10-12', 37, 12, TRUE, NULL),
('2023-10-13', 37, 12, TRUE, 5),
('2023-10-14', 37, 12, FALSE, NULL),
('2023-10-15', 37, 12, TRUE, 7),
('2023-10-16', 37, 12, TRUE, 6),
('2023-11-11', 37, 13, TRUE, 8),
('2023-11-14', 37, 13, TRUE, NULL),
('2023-11-15', 37, 13, FALSE, NULL),
('2023-11-16', 37, 13, FALSE, NULL),
('2023-11-17', 37, 13, TRUE, 8);

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 3, 37, 8, 0.5);

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 7, 37, 7, 0.6);

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 12, 37, 7, 0.6);

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 13, 37, 9, 0.6);

SELECT * FROM exam;
DELETE FROM exam WHERE exam_id = 24;


# результаты
SELECT
	subjects.sub_id,
    subjects.sub_name,
    exam.exam_mark,
    exam.cur_mark,
    exam.final_grade
FROM
    subjects
JOIN
    group_subjects ON subjects.sub_id = group_subjects.sub_id 
    AND group_subjects.st_group_id = (SELECT st_group_id FROM studs WHERE st_id = 37) AND group_subjects.exam = TRUE
LEFT JOIN
    exam ON subjects.sub_id = exam.ref_sub_id AND exam.ref_st_id = 37;


SELECT * FROM studs
WHERE st_id = 37;


INSERT INTO attendance(attendance_date, student_id, subject_id, attendance_TF, grade)
VALUES 
('2023-09-11', 38, 3, TRUE, 8),
('2023-09-12', 38, 3, TRUE, 9),
('2023-09-15', 38, 3, TRUE, 10),
('2023-09-11', 38, 7, TRUE, 7),
('2023-09-13', 38, 7, TRUE, 6),
('2023-10-14', 38, 7, FALSE, NULL),
('2023-10-15', 38, 7, TRUE, 9),
('2023-10-11', 38, 12, TRUE, NULL),
('2023-10-12', 38, 12, TRUE, NULL),
('2023-10-13', 38, 12, TRUE, 5),
('2023-10-14', 38, 12, FALSE, NULL),
('2023-10-15', 38, 12, TRUE, 7),
('2023-10-16', 38, 12, TRUE, 6),
('2023-11-11', 38, 13, TRUE, 8),
('2023-11-14', 38, 13, TRUE, NULL),
('2023-11-15', 38, 13, FALSE, NULL),
('2023-11-16', 38, 13, FALSE, NULL),
('2023-11-17', 38, 13, TRUE, 8);





INSERT INTO studs (st_name, st_surname, st_group_id, st_form, st_birthdate)
VALUES
('Иван', 'Иванченко', 14, 'budget', '2004-11-12');

SELECT subjects.sub_id, subjects.sub_name, group_subjects.sub_teacher_lecture
FROM group_subjects
JOIN subjects ON group_subjects.sub_id = subjects.sub_id
WHERE group_subjects.st_group_id IN (
    SELECT st_group_id
    FROM studs
    WHERE st_id = 38
) AND group_subjects.credit = TRUE;

SELECT * FROM studs
WHERE st_id = 38;

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2023-12-15', 1, 38, 0),
('2023-12-15', 3, 38, 0),
('2023-12-15', 9, 38, 0); 



# _____________________________ДОПЫ ____________________

DROP FUNCTION Censorship;
DELIMITER //

CREATE FUNCTION Censorship(input_str VARCHAR(50)) RETURNS VARCHAR(50)
BEGIN
    DECLARE output_str VARCHAR(50);
    SET output_str = LOWER(input_str);
    SET output_str = REPLACE(output_str, 'жоп', 'ж*п');
    SET output_str = REPLACE(output_str, 'хер', 'х*р');
    SET output_str = REPLACE(output_str, 'хрен', 'хр*н');
    SET output_str = REPLACE(output_str, 'пидо', 'п*до');
    SET output_str = REPLACE(output_str, 'пидр', 'п*др');
    SET output_str = REPLACE(output_str, 'фиг', 'ф*г');
	SET output_str = REPLACE(output_str, 'говн', 'г*вн');
    SET output_str = REPLACE(output_str, 'гавн', 'г*вн');
    SET output_str = CONCAT(UPPER(SUBSTRING(output_str, 1, 1)), SUBSTRING(output_str, 2));
    
    RETURN output_str;
END //

DELIMITER ;

SET @res = Censorship('Жопин');
SELECT @res;

SET @res = Censorship('Хренчук');
SELECT @res;

DELIMITER //

CREATE FUNCTION ContainsProfanity(str VARCHAR(50)) RETURNS BOOLEAN
BEGIN
    DECLARE profanity_found BOOLEAN DEFAULT FALSE;

    IF str LIKE '%хуй%' OR str LIKE '%пизд%' OR str LIKE '%бля%' OR str LIKE '%хуе%' OR str LIKE '%пизд%' OR str LIKE '%ебат%'  OR str LIKE '%ебн%' OR str LIKE '%ебан%' OR str LIKE '%пезд%' THEN
        SET profanity_found = TRUE;
    END IF;

    RETURN profanity_found;
END //

DELIMITER ;
DROP TRIGGER before_insert_studs5;
DELIMITER //

CREATE TRIGGER before_insert_studs5
BEFORE INSERT ON studs
FOR EACH ROW
BEGIN
    DECLARE first_name_censored VARCHAR(50);
    DECLARE last_name_censored VARCHAR(50);

    IF ContainsProfanity(NEW.st_name) OR ContainsProfanity(NEW.st_surname) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: Запрещено использование матных слов в имени или фамилии.';
    END IF;

    SET first_name_censored = Censorship(NEW.st_name);
    SET last_name_censored = Censorship(NEW.st_surname);

    SET NEW.st_name = first_name_censored;
    SET NEW.st_surname = last_name_censored;
END //

DELIMITER ;

SELECT * FROM studs;

INSERT INTO studs(st_name, st_surname, st_group_id)
VALUES
('Хуй', 'Херов', 1);

INSERT INTO studs(st_name, st_surname, st_group_id)
VALUES
('Хер','Жопин', 1);

INSERT INTO studs(st_name, st_surname, st_group_id)
VALUES
('Евгений','Распиздяев',1);

INSERT INTO studs(st_name, st_surname, st_group_id)
VALUES
('Гавнарь','Пидорасенко', 1);
SELECT * FROM studs;



#_________________ДОП__________________-
SELECT * FROM studs;
DROP TRIGGER before_insert_studs6;
DELIMITER //
CREATE TRIGGER before_insert_studs6
BEFORE INSERT ON studs
FOR EACH ROW
BEGIN
    DECLARE year INT;
    DECLARE order_number INT;

    SELECT enroll_year INTO year
    FROM st_group
    WHERE group_id = NEW.st_group_id;

    SELECT COUNT(*) + 1 INTO order_number
    FROM studs s
    JOIN st_group sg ON s.st_group_id = sg.group_id
    WHERE sg.enroll_year = enroll_year;

    SET NEW.st_id = CONCAT(year, LPAD(order_number, 3, '0'));
END //

DELIMITER ;

SELECT * FROM studs;


# _____________________ДОП ___________________________

DROP TABLE departed_students;
CREATE TABLE departed_students (
    st_id INT PRIMARY KEY,
    destination_university VARCHAR(100), 
    departure_date DATE,
    return_date DATE,
	FOREIGN KEY (st_id) REFERENCES studs(st_id)
);

CREATE TABLE arrived_students (
    st_id INT PRIMARY KEY AUTO_INCREMENT,
    st_name varchar(50),
	st_surname varchar(50), 
    arrival_date DATE,
    departure_date DATE
);


CREATE TABLE exchange_exam (
    exam_date DATE,
    subject VARCHAR(50),
    ref_st_id INT,
    exam_mark INT,
    coef FLOAT,
    cur_mark FLOAT,
    final_grade INT,
    FOREIGN KEY (ref_st_id) REFERENCES arrived_students(st_id)
);


CREATE TABLE exchange_credits (
    credit_date DATE,
    ref_st_id INT,
    subject VARCHAR(50),
    result BOOLEAN,
    FOREIGN KEY (ref_st_id) REFERENCES arrived_students(st_id)
);


CREATE TABLE exchange_attendance (
    attendance_date DATE,
    student_id INT,
    subject VARCHAR(50),
    attendance_TF BOOLEAN,
    grade INT CHECK (grade >= 0 AND grade <= 10),
    FOREIGN KEY (student_id) REFERENCES arrived_students(st_id)
);

DROP FUNCTION calculate_student_average_grade2;
DELIMITER //
CREATE FUNCTION calculate_student_average_grade2(
    student_id INT,
    subject VARCHAR(50)
)
RETURNS FLOAT
BEGIN
    DECLARE total_grade FLOAT;
    DECLARE grade_count INT;
    DECLARE average_grade FLOAT;

    SET total_grade = 0;
    SET grade_count = 0;
    SET average_grade = 0;

    SELECT SUM(grade), COUNT(grade)
    INTO total_grade, grade_count
    FROM exchange_attendance
    WHERE exchange_attendance.student_id = student_id
        AND exchange_attendance.subject = subject;

    IF grade_count > 0 THEN
        SET average_grade = total_grade / grade_count;
    ELSE
        SET average_grade = 4;
    END IF;

    RETURN average_grade;
END //

DELIMITER ;

DROP TRIGGER before_insert_exam_ex;
DELIMITER //
CREATE TRIGGER before_insert_exam_ex
BEFORE INSERT ON exchange_exam
FOR EACH ROW
BEGIN
    DECLARE average_grade FLOAT;

    SET average_grade = calculate_student_average_grade2(
        NEW.ref_st_id,
        NEW.subject
    );

    SET NEW.cur_mark = average_grade;
    SET NEW.final_grade = ROUND(NEW.coef * NEW.exam_mark + (1 - NEW.coef) * average_grade + 0.1);
END //

DELIMITER ;

SELECT * FROM studs;

INSERT INTO departed_students (st_id, destination_university, departure_date, return_date)
VALUES
    (2021002, 'University A', '2023-01-01', '2023-06-01'),
    (2021003, 'University A', '2023-02-01', '2023-07-01'),
    (2021008, 'University A', '2023-03-01', '2023-07-01'),
    (2021009, 'University A', '2023-04-01', '2023-07-01'),
    (2021010, 'University A', '2023-05-01', '2023-07-01');

SELECT * FROM arrived_students;
INSERT INTO arrived_students (st_name, st_surname, arrival_date, departure_date)
VALUES
    ('Алексей', 'Соколов','2023-01-01', '2023-06-01'),
    ('Елена', 'Кузнецова', '2023-02-01', '2023-07-01'),
    ('Сергей', 'Иванов', '2023-03-01', '2023-07-01'),
    ('Анна', 'Петрова', '2023-04-01', '2023-07-01'),
    ('Игорь', 'Козлов', '2023-05-01', '2023-07-01');

INSERT INTO exchange_attendance (attendance_date, student_id, subject, attendance_TF, grade)
VALUES
    ('2023-05-15', 1, 'English', true, 9),
    ('2023-03-01', 2, 'Алгебра', false, NULL),
    ('2023-03-15', 3, 'Алгебра', true, 9),
    ('2023-04-01', 2, 'Алгебра', true, 8),
    ('2023-05-15', 5, 'English', true, NULL),
    ('2023-03-01', 5, 'Алгебра', true, 10),
    ('2023-03-15', 3, 'Геометрия', true, 9),
    ('2023-04-01', 2, 'Геометрия', true, 8),
    ('2023-04-01', 2, 'Алгебра', true, 8),
    ('2023-05-15', 4, 'Теория чисел', true, 7),
    ('2023-03-01', 4, 'Алгебра', true, 10),
    ('2023-03-15', 1, 'Теория чисел', true, 6),
    ('2023-04-01', 1, 'Геометрия', true, 8),
    ('2023-04-01', 2, 'Алгебра', true, 8),
    ('2023-04-16', 5, 'Теория чисел', true, 7),
    ('2023-03-17', 4, 'Алгебра', true, 10),
    ('2023-03-18', 1, 'Теория чисел', true, 6),
    ('2023-04-11', 1, 'Геометрия', true, 8),
    ('2023-05-15', 4, 'Теория чисел', true, 7),
    ('2023-03-01', 5, 'Алгебра', true, 8),
    ('2023-05-15', 5, 'Теория чисел', true, 6),
    ('2023-04-13', 5, 'Геометрия', true, 5),
    ('2023-04-11', 2, 'Алгебра', true, 8);

SELECT * FROM exchange_attendance;

INSERT INTO exchange_exam (exam_date, subject, ref_st_id, exam_mark, coef)
VALUES
    ('2023-06-01', 'English', 1, 8, 0.6),
    ('2023-06-01', 'Алгебра', 1, 7, 0.7),
    ('2023-06-01', 'Геометрия', 1, 10, 0.5),
    ('2023-06-01', 'Теория чисел', 1, 9, 0.5),
    ('2023-06-01', 'English', 2, 8, 0.6),
    ('2023-06-01', 'Алгебра', 2, 10, 0.7),
    ('2023-06-01', 'Геометрия', 2, 10, 0.5),
    ('2023-06-01', 'Теория чисел', 2, 10, 0.5),
    ('2023-06-01', 'English', 3, 7, 0.6),
    ('2023-06-01', 'Алгебра', 3, 8, 0.7),
    ('2023-06-01', 'Геометрия', 3, 8, 0.5),
    ('2023-06-01', 'Теория чисел', 3, 8, 0.5),
    ('2023-06-01', 'English', 4, 7, 0.6),
    ('2023-06-01', 'Алгебра', 4, 8, 0.7),
    ('2023-06-01', 'Геометрия', 4, 8, 0.5),
    ('2023-06-01', 'Теория чисел', 4, 8, 0.5),
    ('2023-06-01', 'English', 5, 10, 0.6),
    ('2023-06-01', 'Алгебра', 5, 9, 0.7),
    ('2023-06-01', 'Геометрия', 5, 9, 0.5),
    ('2023-06-01', 'Теория чисел', 3, 5, 0.5);

SELECT * FROM exchange_exam;

INSERT INTO exchange_credits (credit_date, subject, ref_st_id, result)
VALUES
('2023-06-01', 'English', 1, 0),
    ('2023-06-01', 'Алгебра', 1, 1),
    ('2023-06-01', 'Геометрия', 1, 1),
    ('2023-06-01', 'Теория чисел', 1, 0),
    ('2023-06-01', 'English', 2, 0),
    ('2023-06-01', 'Алгебра', 2, 1),
    ('2023-06-01', 'Геометрия', 2, 1),
    ('2023-06-01', 'Теория чисел', 2, 1),
    ('2023-06-01', 'English', 3, 1),
    ('2023-06-01', 'Алгебра', 3, 1),
    ('2023-06-01', 'Геометрия', 3, 1),
    ('2023-06-01', 'Теория чисел', 3, 0),
    ('2023-06-01', 'English', 4, 0),
    ('2023-06-01', 'Алгебра', 4, 1),
    ('2023-06-01', 'Геометрия', 4, 1),
    ('2023-06-01', 'Теория чисел', 4, 1),
    ('2023-06-01', 'English', 5, 1),
    ('2023-06-01', 'Алгебра', 5, 1),
    ('2023-06-01', 'Геометрия', 5, 1),
    ('2023-06-01', 'Теория чисел', 3, 1);

SELECT * FROM exchange_credits;

SELECT subjects.sub_id, subjects.sub_name, group_subjects.sub_teacher_lecture
FROM group_subjects
JOIN subjects ON group_subjects.sub_id = subjects.sub_id
WHERE group_subjects.st_group_id IN (
    SELECT st_group_id
    FROM studs
    WHERE st_id = 2021009
) AND group_subjects.exam = TRUE;

SELECT subjects.sub_id, subjects.sub_name, group_subjects.sub_teacher_lecture
FROM group_subjects
JOIN subjects ON group_subjects.sub_id = subjects.sub_id
WHERE group_subjects.st_group_id IN (
    SELECT st_group_id
    FROM studs
    WHERE st_id = 2021008
) AND group_subjects.credit = TRUE;


DROP PROCEDURE transfer_exam_results;
DELIMITER //
CREATE PROCEDURE transfer_exam_results(
    IN student_id INT
)
BEGIN
    DECLARE group_id_val INT;
    DECLARE arrived_st_id INT;

    SELECT st_group_id INTO group_id_val
    FROM studs
    WHERE st_id = student_id;

    SELECT st_id INTO arrived_st_id
    FROM arrived_students
    WHERE st_name = (SELECT st_name FROM studs WHERE st_id = student_id)
        AND st_surname = (SELECT st_surname FROM studs WHERE st_id = student_id);

    CREATE TEMPORARY TABLE session_subjects AS
    SELECT subjects.sub_id, subjects.sub_name
    FROM group_subjects
    JOIN subjects ON group_subjects.sub_id = subjects.sub_id
    WHERE group_subjects.st_group_id = group_id_val AND group_subjects.exam = TRUE;

    CREATE TEMPORARY TABLE student_exam_results AS
    SELECT *
    FROM exchange_exam
    WHERE ref_st_id = arrived_st_id;

    INSERT INTO exam (ref_sub_id, ref_st_id, exam_date, exam_mark, coef, cur_mark, final_grade)
    SELECT
        subjects.sub_id,
        student_id,
        student_exam_results.exam_date,
        student_exam_results.exam_mark,
        student_exam_results.coef,
        student_exam_results.cur_mark,
        student_exam_results.final_grade
    FROM student_exam_results
    JOIN subjects ON student_exam_results.subject = subjects.sub_name
    WHERE subjects.sub_id IN (SELECT sub_id FROM session_subjects) AND student_exam_results.final_grade >= 4;

    DROP TEMPORARY TABLE IF EXISTS session_subjects, student_exam_results;
END //
DELIMITER ;

CALL transfer_exam_results(2021010);

SELECT * FROM exam;

DROP PROCEDURE transfer_credit_results;
DELIMITER //
CREATE PROCEDURE transfer_credit_results(
    IN student_id INT
)
BEGIN
    DECLARE group_id_val INT;
    DECLARE arrived_st_id INT;

 DROP TEMPORARY TABLE IF EXISTS session_subjects, student_credit_results;

    SELECT st_group_id INTO group_id_val
    FROM studs
    WHERE st_id = student_id;

    SELECT st_id INTO arrived_st_id
    FROM arrived_students
    WHERE st_name = (SELECT st_name FROM studs WHERE st_id = student_id)
        AND st_surname = (SELECT st_surname FROM studs WHERE st_id = student_id);

    CREATE TEMPORARY TABLE session_subjects AS
    SELECT subjects.sub_id, subjects.sub_name
    FROM group_subjects
    JOIN subjects ON group_subjects.sub_id = subjects.sub_id
    WHERE group_subjects.st_group_id = group_id_val AND group_subjects.credit = TRUE;

    CREATE TEMPORARY TABLE student_credit_results AS
    SELECT *
    FROM exchange_credits
    WHERE ref_st_id = arrived_st_id;

    INSERT INTO credits (ref_sub_id, ref_st_id, credit_date, result)
    SELECT
        subjects.sub_id,
        student_id,
        student_credit_results.credit_date,
        student_credit_results.result
    FROM student_credit_results
    JOIN subjects ON student_credit_results.subject = subjects.sub_name
    WHERE subjects.sub_id IN (SELECT sub_id FROM session_subjects) AND student_credit_results.result = 1;

    DROP TEMPORARY TABLE IF EXISTS session_subjects, student_credit_results;
END //
DELIMITER ;

CALL transfer_credit_results(2021003);

SELECT * FROM credits;


#__________________________________ДОП __________________________________

drop table tuition_payments;
CREATE TABLE tuition_payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    ref_st_id INT,
    amount_due DECIMAL(10,2),
    installment_number INT,
    payment_date DATE,
    due_date DATE,
    amount_paid DECIMAL(10,2),
    is_paid BOOLEAN DEFAULT 0,
    is_overdue BOOLEAN DEFAULT 0,
    FOREIGN KEY (ref_st_id) REFERENCES studs(st_id) ON DELETE RESTRICT 
);

DROP TRIGGER before_insert_tuition_payment;

DELIMITER //
CREATE TRIGGER before_insert_tuition_payment
BEFORE INSERT ON tuition_payments
FOR EACH ROW
BEGIN
    DECLARE student_expelled BOOLEAN;
    DECLARE student_form ENUM('budget', 'paid');

    SELECT expelled, st_form INTO student_expelled, student_form
    FROM studs
    WHERE st_id = NEW.ref_st_id;

    IF student_expelled THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Студент отчислен. Нельзя принимать платежи.';
    END IF;

    IF student_form != 'paid' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Студент не является платником. Нельзя принимать платежи.';
    END IF;
END //
DELIMITER ;



DROP PROCEDURE make_installment_payment;
DELIMITER //
CREATE PROCEDURE make_installment_payment(
    IN student_id INT,
    IN amount DECIMAL(10,2),
    IN installment_number INT,
    IN due_date DATE
)
BEGIN
    DECLARE total_due DECIMAL(10,2);
    DECLARE total_paid DECIMAL(10,2);

        SELECT COALESCE(SUM(amount_paid), 0) INTO total_paid
        FROM tuition_payments
        WHERE ref_st_id = student_id;

        IF (total_paid + amount) <= total_due THEN
            INSERT INTO tuition_payments (ref_st_id, amount_due, installment_number, due_date, amount_paid, is_paid)
            VALUES (student_id, amount, installment_number, due_date, amount, 1);
        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Некорректная сумма оплаты. Больше суммы долга.';
        END IF;

END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER set_overdue_flag
BEFORE INSERT ON tuition_payments
FOR EACH ROW
BEGIN
    IF NEW.due_date < CURDATE() THEN
        SET NEW.is_overdue = 1;
    ELSE
        SET NEW.is_overdue = 0;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE get_payment_history(
    IN student_id INT
)
BEGIN
    SELECT *
    FROM tuition_payments
    WHERE ref_st_id = student_id;
END //

DELIMITER ;




CREATE TABLE expelled_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP PROCEDURE handle_student_expelled;
DELIMITER //
CREATE PROCEDURE handle_student_expelled(
    IN student_id INT
)
BEGIN
    DECLARE last_payment_amount DECIMAL(10,2);
    DECLARE message_text VARCHAR(255);

    SELECT amount_paid INTO last_payment_amount
    FROM tuition_payments
    WHERE ref_st_id = student_id
    ORDER BY payment_date DESC
    LIMIT 1;

    IF last_payment_amount IS NOT NULL THEN
        SELECT CONCAT('Студенту ', st_name, ' ', st_surname, ' должно быть возвращено ', last_payment_amount)
        INTO message_text
        FROM studs
        WHERE st_id = student_id;

        INSERT INTO expelled_messages(message) VALUES (message_text);
    END IF;
END //
DELIMITER ;


DROP TRIGGER handle_expelled_trigger;
DELIMITER //
CREATE TRIGGER handle_expelled_trigger
AFTER UPDATE ON studs
FOR EACH ROW
BEGIN
    IF NEW.expelled = 1 AND OLD.st_form = 'paid' THEN
        CALL handle_student_expelled(NEW.st_id);
    END IF;
END //
DELIMITER ;


INSERT INTO studs (st_name, st_surname, st_group_id, st_form) VALUES ('Иван', 'Иванов', 6, 'paid');
SELECT * FROM studs;

INSERT INTO tuition_payments (ref_st_id, amount_due, payment_date, amount_paid, is_paid)
VALUES (2021017, 5000.00, '2023-01-01', 2000.00, true);

INSERT INTO tuition_payments (ref_st_id, amount_due, payment_date, amount_paid, is_paid)
VALUES (2021021, 5000.00, '2023-01-01', 2000.00, true);


CALL get_payment_history(2021017);
UPDATE studs SET expelled = 1 WHERE st_id = 2021021;
SELECT * FROM expelled_messages;
SELECT * FROM studs;

INSERT INTO tuition_payments (ref_st_id, amount_due, payment_date, amount_paid)
VALUES (2021017, 3000.00, '2023-06-01', 1500.00);

SELECT * FROM studs;



SELECT * FROM tuition_payments;