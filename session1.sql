DROP TABLE `table1`;
CREATE TABLE `table1` ( 
`id` INT NOT NULL AUTO_INCREMENT, 
`name` VARCHAR(255) NOT NULL, 
`marks` INT NOT NULL, 
PRIMARY KEY (`id`)
);

INSERT INTO table1 (id, name, marks) VALUES (1, "ivan", 10);

INSERT INTO table1 (id, name, marks) VALUES (2, "july", 1);

BEGIN;
UPDATE table1 SET marks=marks-1 WHERE id=1; 
#__________________ залочили 1
UPDATE table1 SET marks=marks+1 WHERE id=2;
COMMIT;

SELECT * FROM table1;
