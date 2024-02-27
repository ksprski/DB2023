-- Пример 1 --

DELIMITER //
create procedure givestuds()
begin
	select * from studs;
end //
DELIMITER ;

call givestuds();

-- Пример 2 --


DELIMITER //
create procedure givestudsbycourse(in course int)
begin
	select * from studs
    where st_course=course;
end //
DELIMITER ;

call givestudsbycourse(4);

DELIMITER //
create procedure studsquant(out res int)
begin
	select count(*) into res
    from subjects;
end //
DELIMITER ;

call studsquant(@xx);
select @xx;

-- Пример 3 --
#drop procedure passexam;
DELIMITER //
create procedure passexam(in stud_id int, in sub_value varchar(50), in ex_date datetime, in ex_mark int)
begin
	declare id, qua int;
SELECT sub_id into id from subjects
    where sub_name=sub_value;
    select count(*) into qua from studs
    where st_id=stud_id;
    if (qua=1 and id>0) then
		insert into exam
        (ref_sub_id, ref_st_id,exam_date,exam_mark)
        values
        (id, stud_id, ex_date, ex_mark);
	else
		select null;
	end if;
end //
DELIMITER ;

-- Пример 4 --

create table res_table
(
res_name varchar(30),
res_surname varchar(30)
);

DELIMITER //
create procedure cursorexample()
begin
	declare n, sn varchar(50);
    declare is_end int default 0;
    
    declare studscur cursor for select st_name, st_surname from studs;
    
    declare continue handler for not  found set is_end=1;
    
    open studscur;
    curs: Loop
		fetch studscur into n, sn;
        if is_end then
			leave curs;
		end if;
        insert into res_table value (n, sn);
	end loop curs;
    
    close studscur;
end //
DELIMITER ;

call cursorexample;
select * from res_table;

-- Пример 5 --
#SET GLOBAL log_bin_trust_function_creators = 1;

#drop function average_mark;
DELIMITER //
create function average_mark(id int)
returns float
DETERMINISTIC
NO SQL
begin
	declare averagemark float;
    select avg(exam_mark) into averagemark from exam
    where ref_st_id=id;
    return averagemark;
end //
DELIMITER ;

select * from exam
where exam_mark>=average_mark(4);

select average_mark(4);

-- Пример 6 --

set @fails=0;

DELIMITER //
CREATE TRIGGER fail_count AFTER INSERT ON exam
FOR EACH ROW
BEGIN
	IF NEW.exam_mark<4 THEN
		SET @fails = @fails+1;
	END IF;
END //
DELIMITER ;

CALL passexam(4, 'Алгебра', now(), 2);

select @fails;

DROP TRIGGER st_check;
DELIMITER //
CREATE TRIGGER st_check BEFORE INSERT ON studs
FOR EACH ROW
BEGIN
	CASE NEW.st_form
		WHEN 'budget' THEN
			SET NEW.st_value=100;
		WHEN 'paid' THEN
			SET NEW.st_value=0;
		END CASE;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER sub_check BEFORE INSERT ON subjects
FOR EACH ROW
BEGIN
	IF NEW.sub_name='Databases' THEN
		SIGNAL sqlstate '45000';
	END IF;
END //
DELIMITER ;



