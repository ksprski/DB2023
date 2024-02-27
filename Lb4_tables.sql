create database mmf2020;
use mmf2020;
set sql_safe_updates=0;

drop table st_group;
create table st_group(
group_id INT PRIMARY KEY AUTO_INCREMENT,
enroll_year year,
num int,
course int,
speciality enum('КМ', 'Эконом', "Пед", "Механик", "Веб")
);

SELECT * FROM st_group;

drop table studs;
create table studs(
st_id int primary key,
st_name varchar(50),
st_surname varchar(50),
st_birthdate date,
st_group_id int,
st_form enum('budget', 'paid'),
scholarship DECIMAL(8, 2),
fee DECIMAL(8, 2),
st_value float,
CHECK (st_value >= 0 AND st_value <= 10),
FOREIGN KEY (st_group_id) REFERENCES st_group(group_id)
);


SELECT * FROM studs;

drop table subjects;
create table subjects(
sub_id int primary key auto_increment,
sub_name varchar(50),
sub_teacher varchar(20),
sub_hours int
);

SELECT * FROM subjects;

DROP TABLE group_subjects;
CREATE TABLE group_subjects (
    st_group_id INT,
    sub_id INT,
    sub_teacher_practice VARCHAR(50),
    sub_teacher_lecture VARCHAR(50),
    credit BOOLEAN,
    exam BOOLEAN, 
    PRIMARY KEY (st_group_id, sub_id),
    FOREIGN KEY (st_group_id) REFERENCES st_group(group_id),
    FOREIGN KEY (sub_id) REFERENCES subjects(sub_id)
);
SELECT * FROM group_subjects;


#______________________2______________________
# 2.1, 2.2 Хранение информации о посещаемости и оценках студента
drop table attendance;
create table attendance(
attendance_date date,
student_id int,
subject_id int,
attendance_TF boolean,
grade INT CHECK (grade >= 0 AND grade <= 10),
constraint ref_students_to_attendance foreign key (student_id) references studs (st_id) ON DELETE CASCADE,
constraint ref_lessons_to_attendance foreign key (subject_id) references subjects (sub_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

SELECT * FROM attendance;

ALTER TABLE attendance
DROP FOREIGN KEY ref_students_to_attendance ;

ALTER TABLE attendance
ADD CONSTRAINT ref_students_to_attendance 
foreign key (ref_st_id) REFERENCES studs (st_id) ON DELETE NO ACTION;

ALTER TABLE attendance
DROP FOREIGN KEY ref_lessons_to_attendance;
ALTER TABLE attendance
ADD CONSTRAINT ref_lessons_to_attendance
foreign key (subject_id) references subjects (sub_id) ON DELETE NO ACTION;
        
# 2.3. Хранение информации об общественной нагрузке и активности студента 
drop table activities;
CREATE TABLE activities (
    activity_id INT PRIMARY KEY AUTO_INCREMENT,
    ref_st_id INT,
    activity_type VARCHAR(50),
    activity_description TEXT,
    activity_date DATE,
    FOREIGN KEY (ref_st_id) REFERENCES studs(st_id) ON DELETE CASCADE
);

SELECT * FROM activities;

# 2.4. Хранение информации об оплате за обучение для платников, с возможностью рассрочки
drop table tuition_payments;
CREATE TABLE tuition_payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    ref_st_id INT,
    amount_due DECIMAL(10,2),
    payment_date DATE,
    amount_paid DECIMAL(10,2),
    is_paid BOOLEAN DEFAULT 0,
    FOREIGN KEY (ref_st_id) REFERENCES studs(st_id) ON DELETE RESTRICT 
);

SELECT * FROM tuition_payments;

# 2.5. Хранение информации о здоровье студента.
DROP TABLE health_info;
CREATE TABLE health_info (
    health_id INT PRIMARY KEY AUTO_INCREMENT,
    ref_st_id INT,
    height DECIMAL(5,2),
    weight DECIMAL(5,2),
    allergies TEXT,
    chronic_conditions TEXT,
    blood_type VARCHAR(5),
    CONSTRAINT ref_students_to_health FOREIGN KEY (ref_st_id) REFERENCES studs(st_id) ON DELETE RESTRICT
);
# сделать историю для оплаты
# вернуть оплату отчисленному
# командировки по обмену
ALTER TABLE health_info 
ADD COLUMN is_well BOOLEAN DEFAULT TRUE; 

SELECT * FROM  health_info;

#______________________3______________________
ALTER TABLE studs
ADD COLUMN st_re_exam INT DEFAULT 0,
ADD COLUMN otchislen BOOLEAN DEFAULT 0;

ALTER TABLE studs
DROP COLUMN otchislen;

ALTER TABLE studs
ADD COLUMN st_re_credit INT DEFAULT 0;

ALTER TABLE studs 
ADD COLUMN expelled BOOLEAN DEFAULT 0;

ALTER TABLE studs
ADD COLUMN st_re_credit_fk INT DEFAULT 0 AFTER st_re_credit;


SET @semester_start_date = '2023-09-01';
SET @semester_end_date = '2023-12-31';

drop table exam;
create table exam(
exam_id int primary key auto_increment,
ref_sub_id int,
ref_st_id int,
exam_date date,
exam_mark int,

coef float,
cur_mark float,
final_grade int,
re1 enum("пересдал", "не пересдал", "в процессе"),
re2 enum("пересдал", "не пересдал", "в процессе") ,
comission enum("пересдал", "не пересдал", "в процессе"),
constraint ref_studs_to_exam foreign key (ref_st_id) REFERENCES studs (st_id) ON DELETE RESTRICT,
constraint ref_subjects_to_exam foreign key (ref_sub_id) REFERENCES subjects (sub_id) ON UPDATE CASCADE 
);

ALTER TABLE exam
DROP FOREIGN KEY ref_studs_to_exam;

ALTER TABLE exam
ADD CONSTRAINT ref_studs_to_exam
foreign key (ref_st_id) REFERENCES studs (st_id) ON DELETE NO ACTION;

SET GLOBAL log_bin_trust_function_creators = 1;

DROP FUNCTION calculate_student_average_grade;
DELIMITER //
CREATE FUNCTION calculate_student_average_grade(
    student_id INT,
    subject_id INT
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
    FROM attendance
    WHERE attendance.student_id = student_id
        AND attendance.subject_id = subject_id
        AND attendance_date BETWEEN @semester_start_date AND @semester_end_date;

    IF grade_count > 0 THEN
        SET average_grade = total_grade / grade_count;
    ELSE
        SET average_grade = 4;
    END IF;

    RETURN average_grade;
END //

DELIMITER ;

SET @result = calculate_student_average_grade(37, 3);
SELECT @result;


DROP TRIGGER before_insert_exam1;
DELIMITER //
CREATE TRIGGER before_insert_exam1
BEFORE INSERT ON exam
FOR EACH ROW
BEGIN
    DECLARE average_grade FLOAT;

    SET average_grade = calculate_student_average_grade(
        NEW.ref_st_id,
        NEW.ref_sub_id
    );

    SET NEW.cur_mark = average_grade;
    SET NEW.final_grade = ROUND(NEW.coef * NEW.exam_mark + (1 - NEW.coef) * average_grade + 0.1);
END //

DELIMITER ;

DROP TRIGGER  before_insert_exam3;
DELIMITER $$
CREATE TRIGGER before_insert_exam3
BEFORE INSERT ON exam
FOR EACH ROW
BEGIN
	DECLARE st_re_credit INT;
    DECLARE st_re_exam INT;
    DECLARE expelled BOOLEAN;
    
    SELECT studs.expelled INTO expelled FROM studs WHERE st_id = NEW.ref_st_id;
    IF expelled THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: Студент отчислен.';
    END IF;
    
    SELECT studs.st_re_credit INTO st_re_credit FROM studs WHERE st_id = NEW.ref_st_id;
    IF st_re_credit > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: Студент сдал не все зачеты.';
    END IF;
    
    SELECT studs.st_re_exam INTO st_re_exam FROM studs WHERE st_id = NEW.ref_st_id;
    IF st_re_exam > 2 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: Студент провалил сессию. Экзамен сдавать нельзя. Отчислен.';
    END IF;
    
END$$
DELIMITER ;
# проверим матершину (заменять звездочками)

DROP TRIGGER before_insert_exam;
DELIMITER $$
CREATE TRIGGER before_insert_exam
BEFORE INSERT ON exam
FOR EACH ROW
BEGIN
    DECLARE student_count INT;
    DECLARE subject_count INT;
    DECLARE group_subject_count INT;

    -- Проверка существования студента в таблице studs
    SELECT COUNT(*) INTO student_count FROM studs WHERE st_id = NEW.ref_st_id;
    IF student_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: Студент с указанным ID не существует в таблице studs.';
    END IF;

    -- Проверка существования предмета в таблице subjects
    SELECT COUNT(*) INTO subject_count FROM subjects WHERE sub_id = NEW.ref_sub_id;
    IF subject_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: Предмет с указанным ID не существует в таблице subjects.';
    END IF;

    -- Проверка того, что по этому предмету действительно есть экзамен
    SELECT COUNT(*)
	INTO group_subject_count
	FROM group_subjects
	WHERE st_group_id = (SELECT st_group_id FROM studs WHERE st_id = NEW.ref_st_id)
	  AND sub_id = NEW.ref_sub_id
	  AND exam = TRUE;

    IF group_subject_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: Этот экзамен не нужно сдавать данному студенту.';
    END IF;
END$$
DELIMITER ;

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 1, 10, 9, 0.5); # обычный нормальный студент

INSERT INTO studs(st_name, st_surname, st_group_id, expelled)
VALUES ('Александр', 'Иванов', 1, TRUE);

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 1, 26, 9, 0.5); # отчисленный студент

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 1, 127, 9, 0.5); # несуществующий студент

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 110, 1, 9, 0.5); # несуществующий предмет

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 10, 10, 9, 0.5); # у группы нет такого предмета

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 1, 3, 9, 0.5); # обычный нормальный студент2

SELECT * FROM exam;

DROP TRIGGER before_insert_exam4;
DELIMITER //
CREATE TRIGGER before_insert_exam4
BEFORE INSERT ON exam
FOR EACH ROW
BEGIN
    DECLARE student_re_exam_count INT;

    SELECT st_re_exam INTO student_re_exam_count
    FROM studs
    WHERE st_id = NEW.ref_st_id;

    IF NEW.exam_mark < 4 THEN
        SET NEW.re1 = 'в процессе';
        SET student_re_exam_count = student_re_exam_count + 1;
        SET NEW.final_grade = NULL;
        UPDATE studs SET scholarship = 0 WHERE st_id = NEW.ref_st_id;

        IF student_re_exam_count > 2 THEN
            UPDATE studs
			SET expelled = TRUE
			WHERE st_id = NEW.ref_st_id;
        END IF;
    END IF;

    UPDATE studs
    SET st_re_exam = student_re_exam_count
    WHERE st_id = NEW.ref_st_id;
END //
DELIMITER ;

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 3, 10, 3, 0.5); # 3 за экзамен - пересдача 1


DROP TRIGGER after_exam_completed;

DELIMITER //

CREATE TRIGGER after_exam_completed
AFTER INSERT ON exam
FOR EACH ROW
BEGIN
    DECLARE student_id_val INT;
    DECLARE total_exam_mark_val FLOAT;
    DECLARE exam_count_val INT;
    
    IF (SELECT COUNT(*)
	FROM
		subjects
	JOIN
		group_subjects ON subjects.sub_id = group_subjects.sub_id 
		AND group_subjects.st_group_id = (SELECT st_group_id FROM studs WHERE st_id = NEW.ref_st_id) AND group_subjects.exam = TRUE
	LEFT JOIN
		exam ON subjects.sub_id = exam.ref_sub_id AND exam.ref_st_id = NEW.ref_st_id
        WHERE exam.final_grade IS NULL) = 0 THEN
	
     SELECT SUM(final_grade) INTO total_exam_mark_val
      FROM exam
        WHERE ref_st_id = NEW.ref_st_id AND final_grade IS NOT NULL;
        
            SELECT    COUNT(exam_id) INTO exam_count_val
        FROM exam
        WHERE ref_st_id = NEW.ref_st_id AND final_grade IS NOT NULL;

        UPDATE studs
        SET st_value = total_exam_mark_val / exam_count_val
        WHERE st_id = NEW.ref_st_id;
END IF;
END //

DELIMITER ;



DROP TRIGGER before_update_exam;
 DELIMITER //
CREATE TRIGGER before_update_exam
BEFORE UPDATE ON exam
FOR EACH ROW
BEGIN
    DECLARE old_re1 VARCHAR(20);
    DECLARE student_re_exam_count INT;
	DECLARE average_grade FLOAT;

    SELECT re1 INTO old_re1
    FROM exam
    WHERE exam_id = OLD.exam_id;

    SELECT st_re_exam INTO student_re_exam_count
    FROM studs
    WHERE st_id = OLD.ref_st_id;

    IF old_re1 = 'в процессе' AND NEW.exam_mark < 4 THEN
        SET NEW.re1 = 'не пересдал';
        SET NEW.re2 = 'в процессе';
    END IF;

    IF old_re1 = 'в процессе' AND NEW.exam_mark >= 4 THEN
        SET NEW.re1 = 'пересдал';
        SET student_re_exam_count = (student_re_exam_count - 1);
   
		SET average_grade = calculate_student_average_grade(
			NEW.ref_st_id,
			NEW.ref_sub_id);

		SET NEW.cur_mark = average_grade;
		SET NEW.final_grade = ROUND(NEW.coef * NEW.exam_mark + (1 - NEW.coef) * average_grade);
    END IF;

    UPDATE studs
    SET st_re_exam = student_re_exam_count
    WHERE st_id = OLD.ref_st_id;
END //
DELIMITER ;

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 1, 2, 3, 0.5); # 3 за экзамен - пересдача 1

UPDATE exam 
SET exam_mark = 4
WHERE exam_id = 14; # человечек пересдал

SELECT * FROM exam;

DROP TRIGGER before_update_exam2;
DELIMITER //
CREATE TRIGGER before_update_exam2
BEFORE UPDATE ON exam
FOR EACH ROW
BEGIN
    DECLARE old_re2 VARCHAR(20);
    DECLARE student_re_exam_count INT;
	DECLARE average_grade FLOAT;

    SELECT re2 INTO old_re2
    FROM exam
    WHERE exam_id = OLD.exam_id;

    SELECT st_re_exam INTO student_re_exam_count
    FROM studs
    WHERE st_id = OLD.ref_st_id;

    IF old_re2 = 'в процессе' AND NEW.exam_mark < 4 THEN
        SET NEW.re2 = 'не пересдал';
        SET NEW.comission = 'в процессе';
    END IF;

    IF old_re2 = 'в процессе' AND NEW.exam_mark >= 4 THEN
        SET NEW.re2 = 'пересдал';
        SET student_re_exam_count = (student_re_exam_count - 1);
   
		SET average_grade = calculate_student_average_grade(
			NEW.ref_st_id,
			NEW.ref_sub_id);

		SET NEW.cur_mark = average_grade;
		SET NEW.final_grade = ROUND(NEW.coef * NEW.exam_mark + (1 - NEW.coef) * average_grade);
    END IF;

    UPDATE studs
    SET st_re_exam = student_re_exam_count
    WHERE st_id = OLD.ref_st_id;
END //
DELIMITER ;

DROP TRIGGER before_update_exam3;
DELIMITER //
CREATE TRIGGER before_update_exam3
BEFORE UPDATE ON exam
FOR EACH ROW
BEGIN
    DECLARE old_comission VARCHAR(20);
    DECLARE student_re_exam_count INT;
	DECLARE average_grade FLOAT;

    SELECT comission INTO old_comission
    FROM exam
    WHERE exam_id = OLD.exam_id;

    SELECT st_re_exam INTO student_re_exam_count
    FROM studs
    WHERE st_id = OLD.ref_st_id;

    IF old_comission = 'в процессе' AND NEW.exam_mark < 4 THEN
        SET NEW.comission = 'не пересдал';
		UPDATE studs
		SET expelled = TRUE
		WHERE st_id = OLD.ref_st_id;
    END IF;

    IF old_comission = 'в процессе' AND NEW.exam_mark >= 4 THEN
        SET NEW.comission = 'пересдал';
        SET student_re_exam_count = (student_re_exam_count - 1);
   
		SET average_grade = calculate_student_average_grade(
			NEW.ref_st_id,
			NEW.ref_sub_id);

		SET NEW.cur_mark = average_grade;
		SET NEW.final_grade = ROUND(NEW.coef * NEW.exam_mark + (1 - NEW.coef) * average_grade);
    END IF;

    UPDATE studs
    SET st_re_exam = student_re_exam_count
    WHERE st_id = OLD.ref_st_id;
END //
DELIMITER ;

INSERT INTO exam(exam_date, ref_sub_id,
ref_st_id, exam_mark, coef)
VALUES
('2024-01-03', 1, 2, 3, 0.5); # 3 за экзамен - пересдача 1

SELECT * FROM exam;

UPDATE exam 
SET exam_mark = 3
WHERE exam_id = 6; # человечек не пересдал 1 раз

UPDATE exam 
SET exam_mark = 3
WHERE exam_id = 6; # человечек не пересдал 2 раз

UPDATE exam 
SET exam_mark = 3
WHERE exam_id = 6; # человечек не пересдал 3 раз. отчислен

#________________________ЗАЧЕТЫ_________________________
DROP TABLE credits;
CREATE TABLE credits (
    credit_id INT PRIMARY KEY AUTO_INCREMENT,
    ref_st_id INT,
    ref_sub_id INT,
    credit_date DATE,
    
    result boolean,
	re1 enum("пересдал", "не пересдал", "в процессе"),
	re2 enum("пересдал", "не пересдал", "в процессе"),
	comission enum("пересдал", "не пересдал", "в процессе"),
    FOREIGN KEY (ref_st_id) REFERENCES studs(st_id),
    foreign key (ref_sub_id) REFERENCES subjects (sub_id) ON UPDATE CASCADE 
);

DROP TRIGGER IF EXISTS before_insert_credits;
DELIMITER $$
CREATE TRIGGER before_insert_credits
BEFORE INSERT ON credits
FOR EACH ROW
BEGIN
    DECLARE st_re_credit INT;
    DECLARE expelled BOOLEAN;

    SELECT studs.st_re_credit, studs.expelled
    INTO st_re_credit, expelled
    FROM studs
    WHERE studs.st_id = NEW.ref_st_id;

    IF expelled THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: Студент отчислен.';
    END IF;

    IF st_re_credit > 2 THEN
        UPDATE studs SET expelled = TRUE WHERE st_id = NEW.ref_st_id;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: 3 незачета. Отчислен.';
    END IF;
END$$
DELIMITER ;


INSERT INTO credits(credit_date, ref_sub_id,
ref_st_id, result)
VALUES
('2024-01-03', 1, 26, 1); # отчисленный студент

DROP TRIGGER before_insert_credit2;
DELIMITER $$
CREATE TRIGGER before_insert_credit2
BEFORE INSERT ON credits
FOR EACH ROW
BEGIN
    DECLARE student_count INT;
    DECLARE subject_count INT;
    DECLARE group_subject_count INT;

    -- Проверка существования студента в таблице studs
    SELECT COUNT(*) INTO student_count FROM studs WHERE st_id = NEW.ref_st_id;
    IF student_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: Студент с указанным ID не существует в таблице studs.';
    END IF;

    -- Проверка существования предмета в таблице subjects
    SELECT COUNT(*) INTO subject_count FROM subjects WHERE sub_id = NEW.ref_sub_id;
    IF subject_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: Предмет с указанным ID не существует в таблице subjects.';
    END IF;

    -- Проверка того, что по этому предмету действительно есть зачет
    SELECT COUNT(*)
	INTO group_subject_count
	FROM group_subjects
	WHERE st_group_id = (SELECT st_group_id FROM studs WHERE st_id = NEW.ref_st_id)
	  AND sub_id = NEW.ref_sub_id
	  AND credit = TRUE;

    IF group_subject_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: Данному студенту не нужно сдавать этот зачет.';
    END IF;
END$$
DELIMITER ;

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2024-01-03', 8, 6, 1); # обычный нормальный студент

SELECT * FROM credits;


INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2024-01-03', 1, 127,1); # несуществующий студент

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2024-01-03', 110, 1, 1); # несуществующий предмет

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2024-01-03', 6, 8, 1); # у группы нет такого предмета

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2024-01-03', 1, 3, 1); # обычный нормальный студент2

SELECT * FROM credits;

INSERT INTO studs (st_name, st_surname, st_group_id, st_re_credit_fk, st_re_credit)
VALUES
('Алексей', 'Попов', 1, 1, 2),
('Максим', 'Попов', 1, 1, 3);

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2024-01-03', 1, 28, 1); # с 3мя незачетами

INSERT INTO studs (st_name, st_surname, st_group_id, st_re_credit_fk, st_re_credit)
VALUES
('Иван', 'Попов', 1, 1, 2);

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2024-01-03', 1, 29, 1); # с 2мя незачетами можно получать зачет

DROP TRIGGER IF EXISTS before_insert_credits3;
DELIMITER $$
CREATE TRIGGER before_insert_credits3
BEFORE INSERT ON credits
FOR EACH ROW
BEGIN
    DECLARE st_re_credit_fk INT;
    DECLARE st_re_credit INT;
    DECLARE subject_name VARCHAR(50);

    SELECT studs.st_re_credit_fk, studs.st_re_credit, subjects.sub_name
    INTO st_re_credit_fk, st_re_credit, subject_name
    FROM studs
    JOIN subjects ON subjects.sub_id = NEW.ref_sub_id
    WHERE studs.st_id = NEW.ref_st_id;

    IF NEW.result = 0 THEN
        IF subject_name = 'Физическая культура' THEN
            UPDATE studs SET st_re_credit_fk = st_re_credit_fk + 1 WHERE st_id = NEW.ref_st_id;
        ELSE
            UPDATE studs SET st_re_credit = st_re_credit + 1 WHERE st_id = NEW.ref_st_id;
            SET NEW.re1 = 'в процессе';
            SET st_re_credit = st_re_credit + 1;
        END IF;
    END IF;

    IF st_re_credit > 2 THEN
        UPDATE studs SET expelled = TRUE WHERE st_id = NEW.ref_st_id;
    END IF;
    
END$$
DELIMITER ;

INSERT INTO studs (st_name, st_surname, st_group_id, st_re_credit_fk, st_re_credit)
VALUES
('Иван', 'Иванов', 1, 1, 2);

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2024-01-03', 1, 32, 0); # с 2мя незачетами получаем незачет

INSERT INTO studs (st_name, st_surname, st_group_id, st_re_credit_fk, st_re_credit)
VALUES
('Петр', 'Петров', 1, 0, 2);

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2024-01-03', 5, 33, 0); # с 2мя незачетами получаем незачет по физкультуре

SELECT * FROM credits;

DROP TRIGGER before_update_credit;
 DELIMITER //
CREATE TRIGGER before_update_credit
BEFORE UPDATE ON credits
FOR EACH ROW
BEGIN
    DECLARE old_re1 VARCHAR(20);
    DECLARE student_re_credit_count INT;
	DECLARE average_grade FLOAT;
	DECLARE subject_name VARCHAR(50);

    SELECT subjects.sub_name
    INTO subject_name
    FROM studs
    JOIN subjects ON subjects.sub_id = NEW.ref_sub_id
    WHERE studs.st_id = NEW.ref_st_id;

	IF subject_name = 'Физическая культура' THEN
    IF NEW.result = TRUE THEN
            UPDATE studs SET st_re_credit_fk = st_re_credit_fk - 1 WHERE st_id = NEW.ref_st_id;
	END IF;
	END IF;
	
    SELECT re1 INTO old_re1
    FROM credits
    WHERE credit_id = OLD.credit_id;

    SELECT st_re_credit INTO student_re_credit_count
    FROM studs
    WHERE st_id = OLD.ref_st_id;

    IF old_re1 = 'в процессе' AND NEW.result = FALSE THEN
        SET NEW.re1 = 'не пересдал';
        SET NEW.re2 = 'в процессе';
    END IF;

    IF old_re1 = 'в процессе' AND NEW.result = TRUE THEN
        SET NEW.re1 = 'пересдал';
         BEGIN
            UPDATE studs
            SET st_re_credit = st_re_credit - 1
            WHERE st_id = OLD.ref_st_id;
        END;
    END IF;

END //
DELIMITER ;

INSERT INTO studs (st_name, st_surname, st_group_id, st_re_credit_fk, st_re_credit)
VALUES
('Семен', 'Семенов', 1, 0, 0);

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2024-01-03', 1, 35, 0); # первый незачет

SELECT * FROM credits;

UPDATE credits
SET result = 1
WHERE credit_id = 13; # человечек пересдал

DROP TRIGGER before_update_credit2;
DELIMITER //
CREATE TRIGGER before_update_credit2
BEFORE UPDATE ON credits
FOR EACH ROW
BEGIN
    DECLARE old_re2 VARCHAR(20);
    DECLARE student_re_credit_count INT;

    SELECT re2 INTO old_re2
    FROM credits
    WHERE credit_id = OLD.credit_id;

    SELECT st_re_credit INTO student_re_credit_count
    FROM studs
    WHERE st_id = OLD.ref_st_id;

    IF old_re2 = 'в процессе' AND NEW.result = FALSE THEN
        SET NEW.re2 = 'не пересдал';
        SET NEW.comission = 'в процессе';
    END IF;

    IF old_re2 = 'в процессе' AND NEW.result = TRUE THEN
        SET NEW.re2 = 'пересдал';
        SET student_re_credit_count = (student_re_credit_count - 1);
    END IF;

    UPDATE studs
    SET st_re_credit = student_re_credit_count
    WHERE st_id = OLD.ref_st_id;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_update_credit3
BEFORE UPDATE ON credits
FOR EACH ROW
BEGIN
    DECLARE old_comission VARCHAR(20);
    DECLARE student_re_credit_count INT;

    SELECT comission INTO old_comission
    FROM credits
    WHERE credit_id = OLD.credit_id;

    SELECT st_re_credit INTO student_re_credit_count
    FROM studs
    WHERE st_id = OLD.ref_st_id;

    IF old_comission = 'в процессе' AND NEW.result = FALSE THEN
        SET NEW.comission = 'не пересдал';
		UPDATE studs
		SET expelled = TRUE
		WHERE st_id = OLD.ref_st_id;
    END IF;

    IF old_comission = 'в процессе' AND NEW.result = TRUE THEN
        SET NEW.comission = 'пересдал';
        SET student_re_credit_count = (student_re_credit_count - 1);
    END IF;

    UPDATE studs
    SET st_re_credit = student_re_credit_count
    WHERE st_id = OLD.ref_st_id;
END //
DELIMITER ;

INSERT INTO credits(credit_date, ref_sub_id, ref_st_id, result)
VALUES
('2024-01-03', 1, 35, 0); # первый незачет

SELECT * FROM credits;

UPDATE credits
SET result = FALSE
WHERE credit_id = 14; # человечек не пересдал 1 раз

UPDATE credits
SET result = FALSE
WHERE credit_id = 14; # человечек не пересдал 2 раз

UPDATE credits
SET result = FALSE
WHERE credit_id = 14; # человечек не пересдал 3 раз. все




#___________________________4________________________________

#4.1. Процедура для повышения всех стипендий на некоторое количество процентов.
DELIMITER $$
CREATE PROCEDURE increase_all_scholarships(IN percentage INT)
BEGIN
    UPDATE studs SET scholarship = scholarship * (1 + percentage / 100) WHERE scholarship IS NOT NULL;
END$$
DELIMITER ;

CALL increase_all_scholarships(20);
SELECT * FROM studs;

#4.2. Функция, вычисляющая среднюю оценку на экзамене у определённого преподавателя.
DROP FUNCTION get_average_exam_mark;
DELIMITER //
CREATE FUNCTION get_average_exam_mark(sub_teacher_lastname VARCHAR(50))
RETURNS FLOAT
BEGIN
    DECLARE total_mark FLOAT;
    DECLARE total_count INT;

    SET total_mark = 0;
    SET total_count = 0;

    SELECT SUM(exam_mark), COUNT(exam_mark)
    INTO total_mark, total_count
    FROM exam
    WHERE ref_sub_id IN (
        SELECT sub_id
        FROM group_subjects
        WHERE sub_teacher_lecture = sub_teacher_lastname
    );

    IF total_count > 0 THEN
        RETURN total_mark / total_count;
    ELSE
        RETURN NULL; 
    END IF;
END //
DELIMITER ;

SELECT * FROM exam;
SELECT get_average_exam_mark('Алексеев');


#4.3. Процедура для начисления надбавок общественно активным студентам. 
# Критерий начисления надбавок, должен быть привязан к некоторому числовому параметру. 
DROP PROCEDURE bonus_to_active_students;
DELIMITER //
CREATE PROCEDURE bonus_to_active_students(bonus DECIMAL(8, 2))
BEGIN
    DECLARE student_id INT;
    DECLARE events_count INT;
    DECLARE done INT DEFAULT 0;

    DECLARE student_cursor CURSOR FOR
        SELECT ref_st_id, COUNT(*) AS event_count
        FROM activities
        GROUP BY ref_st_id;

	 DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN student_cursor;
    read_students: LOOP
        FETCH student_cursor INTO student_id, events_count;
	 IF done = 1 THEN
            LEAVE read_students;
        END IF;
        
        IF events_count > 0 THEN
            UPDATE studs
            SET scholarship = scholarship + bonus * events_count
            WHERE st_id = student_id;
        END IF;

    END LOOP read_students;
    CLOSE student_cursor;

END //
DELIMITER ;

CALL bonus_to_active_students(10);

SELECT * FROM activities;
SELECT * FROM studs;



#4.4. Процедуры для вывода топ-5 самых успешных студентов факультета, топ-5 «двоечников», топ-5 самых активных. Результаты курсором записать в новые таблицы. 

DROP PROCEDURE top_successful_students;
DROP TABLE top5_successful_students;
DELIMITER //
CREATE PROCEDURE top_successful_students()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE student_id INT;
    DECLARE student_name VARCHAR(50);
    DECLARE student_surname VARCHAR(50);
    DECLARE student_value FLOAT;

    DECLARE successful_students_cursor CURSOR FOR
        SELECT st_id, st_name, st_surname, st_value
        FROM studs
        ORDER BY st_value DESC
        LIMIT 5;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    CREATE TABLE top5_successful_students (
        student_id INT,
        student_name VARCHAR(50),
        student_surname VARCHAR(50),
        student_value FLOAT
    );
    OPEN successful_students_cursor;
    read_successful_students: LOOP
        FETCH successful_students_cursor INTO student_id, student_name, student_surname, student_value;
        IF done = 1 THEN
            LEAVE read_successful_students;
        END IF;
        INSERT INTO top5_successful_students VALUES (student_id, student_name, student_surname, student_value);
    END LOOP read_successful_students;
    CLOSE successful_students_cursor;
    SELECT * FROM top5_successful_students;
    DROP TABLE top5_successful_students;

END //


DROP PROCEDURE top_bad_students//
DROP TABLE top5_bad_students//
CREATE PROCEDURE top_bad_students()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE student_id INT;
    DECLARE student_name VARCHAR(50);
    DECLARE student_surname VARCHAR(50);
    DECLARE student_value FLOAT;

    DECLARE bad_students_cursor CURSOR FOR
        SELECT st_id, st_name, st_surname, st_value
        FROM studs
        WHERE expelled = 0 AND st_value IS NOT NULL
        ORDER BY st_value ASC
        LIMIT 5;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    CREATE TABLE top5_bad_students (
        student_id INT,
        student_name VARCHAR(50),
        student_surname VARCHAR(50),
        student_value FLOAT
    );
    OPEN bad_students_cursor;
    read_bad_students: LOOP
        FETCH bad_students_cursor INTO student_id, student_name, student_surname, student_value;
        IF done = 1 THEN
            LEAVE read_bad_students;
        END IF;
        INSERT INTO top5_bad_students VALUES (student_id, student_name, student_surname, student_value);
    END LOOP read_bad_students;
    CLOSE bad_students_cursor;
    SELECT * FROM top5_bad_students;
	DROP TABLE top5_bad_students;
END //



DROP PROCEDURE top_active_students//
CREATE PROCEDURE top_active_students()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE stud_id INT;
    DECLARE stud_name VARCHAR(50);
    DECLARE stud_surname VARCHAR(50);
    DECLARE act_count INT;
    
    DECLARE active_students_cursor CURSOR FOR
        SELECT s.st_id, s.st_name, s.st_surname, COUNT(a.activity_id) AS activity_count
        FROM studs s
        LEFT JOIN activities a ON s.st_id = a.ref_st_id
        GROUP BY s.st_id, s.st_name, s.st_surname
        ORDER BY activity_count DESC
        LIMIT 5;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    DROP TABLE IF EXISTS top_active_students;
    CREATE TABLE top_active_students (
        student_id INT,
        student_name VARCHAR(50),
        student_surname VARCHAR(50),
        activity_count INT
    );

    OPEN active_students_cursor;
    read_active_students: LOOP
        FETCH active_students_cursor INTO stud_id, stud_name, stud_surname, act_count;
        IF done = 1 THEN
            LEAVE read_active_students;
        END IF;
        INSERT INTO top_active_students VALUES (stud_id, stud_name, stud_surname, act_count);
    END LOOP read_active_students;
    CLOSE active_students_cursor;
    SELECT * FROM top_active_students;
    
END //


DELIMITER ;


CALL top_successful_students();
CALL top_bad_students();
CALL top_active_students();

SELECT * FROM activities;
 SELECT s.st_id, s.st_name, s.st_surname, COUNT(a.activity_id) AS activity_count
        FROM studs s
        LEFT JOIN activities a ON s.st_id = a.ref_st_id
        GROUP BY s.st_id, s.st_name, s.st_surname
        ORDER BY activity_count DESC
        LIMIT 5;


#4.5. Процедура для отчисления проблемных студентов. Подумайте о проверке условий отчисления. 

DROP PROCEDURE move_expelled_students;
DROP TABLE expelled_students;
DELIMITER //
CREATE PROCEDURE move_expelled_students()
BEGIN 
DROP TABLE expelled_students;
    CREATE TABLE expelled_students AS
        SELECT * FROM studs WHERE expelled = 1;

    DELETE FROM studs WHERE expelled = 1;

    SELECT * FROM expelled_students;
END //
DELIMITER ;

CALL move_expelled_students();

SELECT * FROM expelled_students;
#4.6. Функция вычисляющую самую популярную оценку в группе.
DROP FUNCTION get_most_popular_grade;

DELIMITER //
CREATE FUNCTION get_most_popular_grade(group_id INT) 
RETURNS INT
BEGIN
    DECLARE most_popular_grade INT;
    SELECT grade
    INTO most_popular_grade
    FROM (
        SELECT grade, COUNT(grade) AS grade_count
        FROM attendance a
        JOIN studs s ON a.student_id = s.st_id
        WHERE s.st_group_id = group_id
        GROUP BY grade
        ORDER BY grade_count DESC
        LIMIT 1
    ) AS popular_grade_query;

    RETURN most_popular_grade;
END //

DELIMITER ;

SET @grade = get_most_popular_grade(14);
SELECT @grade;

# 4.7. Процедура для вычисления процента пропущенных занятий для студентов определённой группы.

DROP PROCEDURE calculate_absence_percentage;
DELIMITER //
CREATE PROCEDURE calculate_absence_percentage(IN group_id INT)
BEGIN
    DECLARE total_lessons INT;
    DECLARE absent_lessons INT;
    DECLARE absence_percentage DECIMAL(5,2);

    SELECT COUNT(*) INTO total_lessons
    FROM attendance
    JOIN studs ON attendance.student_id = studs.st_id
    WHERE studs.st_group_id = group_id;

    SELECT COUNT(*) INTO absent_lessons
    FROM attendance
    JOIN studs ON attendance.student_id = studs.st_id
    WHERE studs.st_group_id = group_id AND attendance_TF = 0;

    IF total_lessons > 0 THEN
        SET absence_percentage = (absent_lessons / total_lessons) * 100;
    ELSE
        SET absence_percentage = 0;
    END IF;

    SELECT absence_percentage;
END //

DELIMITER ;

CALL calculate_absence_percentage(8);
SELECT * FROM attendance;


# 4.8. Процедура для вычисления самых лояльных и предвзятых преподавателей на факультете.

DROP PROCEDURE calculate_teacher_bias;
DELIMITER //

CREATE PROCEDURE calculate_teacher_bias()
BEGIN
  DROP TABLE IF EXISTS bias_results;
  CREATE TABLE bias_results (
    teacher_name VARCHAR(50),
    avg_diff FLOAT,
    bias_type ENUM('loyal', 'biased')
  );

  INSERT INTO bias_results
  SELECT sub_teacher_lecture, AVG(exam_mark - cur_mark), 'loyal'
  FROM group_subjects gs
  JOIN exam e ON gs.sub_id = e.ref_sub_id
  WHERE exam_mark > cur_mark
  GROUP BY sub_teacher_lecture
  ORDER BY AVG(exam_mark - cur_mark) DESC
  LIMIT 1;

  INSERT INTO bias_results
  SELECT sub_teacher_lecture, AVG(cur_mark - exam_mark), 'biased'
  FROM group_subjects gs
  JOIN exam e ON gs.sub_id = e.ref_sub_id
  WHERE exam_mark < cur_mark
  GROUP BY sub_teacher_lecture
  ORDER BY AVG(cur_mark - exam_mark) DESC
  LIMIT 1;

  SELECT * FROM bias_results;
END //

DELIMITER ;

CALL calculate_teacher_bias();

# 4.9. Процедура для выдачи бонусов студентам. Принимает на вход некоторый период времени 
# начисляет надбавку к стипендии студентам, родившимся в этот период. Чем старше студент, тем больше надбавка

DROP PROCEDURE IF EXISTS award_bonus_to_students;
DELIMITER //
CREATE PROCEDURE award_bonus_to_students(IN start_date DATE, IN end_date DATE, IN bonus_base INT)
BEGIN
    UPDATE studs
    SET scholarship = scholarship + bonus_base * POWER(1.05, FLOOR(DATEDIFF(CURDATE(), st_birthdate) / 365))
    WHERE st_birthdate BETWEEN start_date AND end_date;

    SELECT * FROM studs WHERE st_birthdate BETWEEN start_date AND end_date;
END //
DELIMITER ;

SELECT * FROM studs;
CALL award_bonus_to_students('2004-11-12', '2004-11-13', 10);



DROP PROCEDURE IF EXISTS award_bonus_to_students2;
DELIMITER //
CREATE PROCEDURE award_bonus_to_students2(IN start_date DATE, IN end_date DATE, IN bonus_base INT, IN dayOfWeek INT)
BEGIN
    UPDATE studs
    SET scholarship = 
        CASE
            WHEN (DAYOFWEEK(st_birthdate) = dayOfWeek) THEN scholarship + bonus_base * 3 * POWER(1.1, FLOOR(DATEDIFF(CURDATE(), st_birthdate) / 365))
            ELSE scholarship + bonus_base * POWER(1.05, FLOOR(DATEDIFF(CURDATE(), st_birthdate) / 365))
        END
    WHERE st_birthdate BETWEEN start_date AND end_date;

    SELECT * FROM studs WHERE st_birthdate BETWEEN start_date AND end_date;
END //
DELIMITER ;

SELECT * FROM studs;
CALL award_bonus_to_students2('2005-01-20', '2006-11-13', 10, 5);


DROP PROCEDURE calculate_expected_grade;
DELIMITER //
CREATE PROCEDURE calculate_expected_grade(
    IN student_id INT,
    IN subject_id INT
)
BEGIN
DECLARE expected_grade FLOAT;
    DECLARE loyalty_factor FLOAT;
    DECLARE success_factor FLOAT;
    DECLARE random_factor FLOAT;

    SELECT calculate_student_average_grade(student_id, subject_id) INTO success_factor;

    SELECT 
        AVG(e.exam_mark) AS avg_exam, 
        AVG(e.cur_mark) AS avg_cur
    INTO 
        @avg_exam, 
        @avg_cur
    FROM 
        exam e
    JOIN 
        group_subjects gs ON e.ref_sub_id = gs.sub_id
    WHERE 
        gs.sub_id = subject_id
        AND gs.st_group_id = (SELECT st_group_id FROM studs WHERE st_id = student_id)
        AND gs.sub_teacher_lecture IS NOT NULL;

    SET loyalty_factor = CASE
        WHEN @avg_exam > @avg_cur THEN 1
        WHEN @avg_exam < @avg_cur THEN -1
        ELSE 0
    END;

    SET random_factor = RAND() - 0.5;

    SET expected_grade = success_factor + random_factor + loyalty_factor;
    
    SET expected_grade = ROUND(LEAST(GREATEST(expected_grade, 0), 10), 2);

    SELECT expected_grade;
    END//

DELIMITER ;

CALL calculate_expected_grade(37, 3);

SET @res = calculate_student_average_grade(37, 3);
SELECT @res;
SELECT * FROM exam;
# ______________________________5___________________________________

# 5.1. Триггер для автоматического изменения размера стипендии в зависимости от успеваемости.

SET  @session_start_date = '2024-01-02';
SET  @session_end_date = '2024-01-20';
DROP TRIGGER update_scholarship;
DELIMITER //
CREATE TRIGGER update_scholarship
AFTER INSERT ON exam
FOR EACH ROW
BEGIN
    DECLARE avg_exam_score FLOAT;

    IF (SELECT COUNT(*)
	FROM
		subjects
	JOIN
		group_subjects ON subjects.sub_id = group_subjects.sub_id 
		AND group_subjects.st_group_id = (SELECT st_group_id FROM studs WHERE st_id = NEW.ref_st_id) AND group_subjects.exam = TRUE
	LEFT JOIN
		exam ON subjects.sub_id = exam.ref_sub_id AND exam.ref_st_id = NEW.ref_st_id
        WHERE exam.final_grade IS NULL) = 0 THEN

        SELECT AVG(final_grade)
        INTO avg_exam_score
        FROM exam
        WHERE ref_st_id = NEW.ref_st_id
              AND final_grade IS NOT NULL
              AND exam_date BETWEEN @session_start_date AND @session_end_date;

        UPDATE studs
        SET scholarship = CASE
            WHEN avg_exam_score > 9 THEN 300
            WHEN avg_exam_score BETWEEN 8 AND 9 THEN 250
            WHEN avg_exam_score BETWEEN 7 AND 8 THEN 200
            WHEN avg_exam_score BETWEEN 6 AND 7 THEN 150
            WHEN avg_exam_score BETWEEN 5 AND 6 THEN 100
            ELSE 0
        END
        WHERE st_id = NEW.ref_st_id;

    END IF;
END //
DELIMITER ;


# 5.2. Триггер для автоматического снижения оплаты при успешной успеваемости.
DROP TRIGGER reduce_fee_on_success;
DELIMITER //
CREATE TRIGGER reduce_fee_on_success
AFTER INSERT ON exam
FOR EACH ROW
BEGIN
    DECLARE avg_exam_score FLOAT;

    IF (SELECT COUNT(*)
	FROM
		subjects
	JOIN
		group_subjects ON subjects.sub_id = group_subjects.sub_id 
		AND group_subjects.st_group_id = (SELECT st_group_id FROM studs WHERE st_id = NEW.ref_st_id) AND group_subjects.exam = TRUE
	LEFT JOIN
		exam ON subjects.sub_id = exam.ref_sub_id AND exam.ref_st_id = NEW.ref_st_id
        WHERE exam.final_grade IS NULL) = 0 THEN

        SELECT AVG(final_grade)
        INTO avg_exam_score
        FROM exam
        WHERE ref_st_id = NEW.ref_st_id
              AND final_grade IS NOT NULL
              AND exam_date BETWEEN @session_start_date AND @session_end_date;

        UPDATE studs
        SET fee = CASE
            WHEN avg_exam_score > 9 THEN fee * 0.9
            WHEN avg_exam_score BETWEEN 8 AND 9 THEN fee * 0.95
            WHEN avg_exam_score BETWEEN 7 AND 8 THEN fee * 0.98
            ELSE fee
        END
        WHERE st_id = NEW.ref_st_id;

    END IF;
END //
DELIMITER ;


#5.6. Триггер, не допускающий перевода на следующий курс студента с проблемами по линии здоровья.
DROP TABLE unwell_students_info;
CREATE TABLE unwell_students_info (
    st_id INT PRIMARY KEY,
    st_name VARCHAR(50),
    st_surname VARCHAR(50),
    st_birthdate DATE,
    st_group_id INT,
    st_form enum('budget', 'paid'),
    scholarship DECIMAL(8, 2),
    fee DECIMAL(8, 2),
    st_value float,
    FOREIGN KEY (st_id) REFERENCES studs(st_id) ON DELETE RESTRICT
);

DROP PROCEDURE process_unwell_students;
DELIMITER //
CREATE PROCEDURE process_unwell_students()
BEGIN
	DECLARE done INT;
    DECLARE student_id INT;
    DECLARE student_name VARCHAR(50);
    DECLARE student_surname VARCHAR(50);
    DECLARE student_birthdate DATE;
    DECLARE student_group_id INT;
	DECLARE st_form enum('budget', 'paid');
	DECLARE scholarship DECIMAL(8, 2);
	DECLARE fee DECIMAL(8, 2);
	DECLARE st_value float;

    DECLARE unwell_students_cursor CURSOR FOR
        SELECT s.st_id, s.st_name, s.st_surname, s.st_birthdate, s.st_group_id, s.st_form, s.scholarship, s.fee, s.st_value
        FROM studs s
        JOIN health_info h ON s.st_id = h.ref_st_id
        WHERE h.is_well = FALSE;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN unwell_students_cursor;

    read_unwell_students: LOOP
    IF done = 1 THEN
	LEAVE read_unwell_students;
	END IF;
        FETCH unwell_students_cursor INTO student_id, student_name, student_surname, student_birthdate, student_group_id, st_form, scholarship, fee, st_value;

        INSERT INTO unwell_students_info VALUES (student_id, student_name, student_surname, student_birthdate, student_group_id, st_form, scholarship, fee, st_value);

        DELETE FROM studs WHERE st_id = student_id;
    END LOOP read_unwell_students;

    CLOSE unwell_students_cursor;
END //
DELIMITER ;



#5.4. Триггер для автоматического перевода студента на следующий курс при успешной сессии. *
ALTER TABLE st_group
ADD COLUMN finished BOOLEAN DEFAULT FALSE;

SELECT * FROM st_group;
DROP PROCEDURE update_group_course;
DELIMITER //
CREATE PROCEDURE update_group_course()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE group_id_val INT;
    DECLARE current_course_val INT;

    DECLARE group_cursor CURSOR FOR SELECT group_id, course FROM st_group;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN group_cursor;
    read_groups: LOOP 
        FETCH group_cursor INTO group_id_val, current_course_val;
        IF done = 1 THEN
            LEAVE read_groups;
        END IF;
        
        IF current_course_val < 4 THEN
            UPDATE st_group
            SET course = current_course_val + 1
            WHERE group_id = group_id_val;
        ELSE
            UPDATE st_group
            SET finished = TRUE
            WHERE group_id = group_id_val;
        END IF;
    END LOOP read_groups;

    CLOSE group_cursor;
END //

DELIMITER ;

CALL update_group_course();
SELECT * FROM st_group;


# 5.7. Триггер для хранения истории изменений определённых полей таблиц.

CREATE TABLE exam_mark_update_history (
    line_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_mark VARCHAR(255),
    new_mark VARCHAR(255),
    user_changed VARCHAR(50)
);

DROP TRIGGER exam_update_history_trigger;
DELIMITER //
CREATE TRIGGER exam_update_history_trigger
AFTER UPDATE ON exam
FOR EACH ROW
BEGIN
    IF NEW.exam_mark != OLD.exam_mark THEN
        INSERT INTO exam_mark_update_history (exam_id, old_mark, new_mark, user_changed)
        VALUES (NEW.exam_id, OLD.exam_mark, NEW.exam_mark, CURRENT_USER());
    END IF;

END;
//
DELIMITER ;

SELECT * FROM exam_mark_update_history;

CREATE TABLE exam_deletion_history (
    line_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT,
    st_id INT,
    sub_id INT,
    deletion_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_mark VARCHAR(255),
    user_deleted VARCHAR(50)
);

DELIMITER //
CREATE TRIGGER exam_deletion_history_trigger
AFTER DELETE ON exam
FOR EACH ROW
BEGIN
    INSERT INTO exam_deletion_history (exam_id, st_id, sub_id, deleted_mark, user_deleted)
    VALUES (OLD.exam_id, OLD.ref_st_id, OLD.ref_sub_id, OLD.exam_mark, CURRENT_USER());
END;
//
DELIMITER ;


SELECT * FROM exam_deletion_history;


# 5.5. Триггер помечающий потенциально проблемных студентов специальным модификатором. 
ALTER TABLE studs
ADD COLUMN potential_issue BOOLEAN DEFAULT FALSE;

DROP TRIGGER mark_potential_issues;
DELIMITER //
CREATE TRIGGER mark_potential_issues
AFTER INSERT ON exam
FOR EACH ROW
BEGIN
    DECLARE avg_exam_score FLOAT;

	IF (SELECT COUNT(*)
	FROM
		subjects
	JOIN
		group_subjects ON subjects.sub_id = group_subjects.sub_id 
		AND group_subjects.st_group_id = (SELECT st_group_id FROM studs WHERE st_id = NEW.ref_st_id) AND group_subjects.exam = TRUE
	LEFT JOIN
		exam ON subjects.sub_id = exam.ref_sub_id AND exam.ref_st_id = NEW.ref_st_id
        WHERE exam.final_grade IS NULL) = 0 THEN
        
    SELECT AVG(final_grade)
    INTO avg_exam_score
    FROM exam
    WHERE ref_st_id = NEW.ref_st_id
          AND final_grade IS NOT NULL
          AND exam_date BETWEEN @session_start_date AND @session_end_date;
END IF;

    IF avg_exam_score < 5.0 THEN
        UPDATE studs
        SET potential_issue = 1
        WHERE st_id = NEW.ref_st_id;
    END IF;
END //
DELIMITER ;

