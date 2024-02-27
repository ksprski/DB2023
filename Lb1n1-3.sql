create database db_example;
use db_example;
create table product
(
product_id integer primary key auto_increment,
product_name varchar(50) check (left(product_name, 1) != 'z'),
product_type varchar(30),
product_price float check (product_price >= 0)
);
insert into product 
(product_name, product_type, product_price)
values
('Аливария', 'Пиво', 1.5),
('Свояк','Водка', 8),
('Добрый', 'Сок', 1),
('Guiness','Пиво', 6),
('Rich','Сок', 5);

drop table product;  

create table staff
(
employee_id integer primary key auto_increment,
employee_idNew char(36) default (UUID()),
employee_name varchar(50) default '' not null,
employee_surname varchar(50) default '' not null,
employee_position enum('barman','cook'),
employee_birthdate date,
employee_nickname VARCHAR(100) AS (CONCAT(employee_name, employee_surname, right(left(employee_idNew, 8),3))) STORED
);
insert into staff 
(employee_name, employee_surname, employee_position, employee_birthdate)
values
('Ярослав', 'Гершов', 'barman', '2003-12-05'),
('Варвара','Бондаренко', 'barman', '2003-11-04'),
('Марагрита', 'Кольке', 'cook', '2002-12-01'),
('Екатерина','Шклярик', 'cook', '2004-01-01'),
('Григорий','Янушкевич', 'cook', '2004-03-05');

ALTER TABLE staff
ADD employee_age integer default (TIMESTAMPDIFF(YEAR, employee_birthdate, CURDATE()));

insert into staff 
(employee_name, employee_surname, employee_birthdate)
values
("Адольф", "Гитлер", "1889-04-20");
drop table staff;  
select * from staff;

create table sells
(
sell_id integer primary key auto_increment,
sell_date datetime not null,
barman_id integer not null,
sell_amount float not null,
constraint cn2 foreign key (barman_id) references staff(employee_id)
);
insert into sells
(sell_date, barman_id, sell_amount)
values
("2022-12-05 10:37:22", 2, 3),
("2022-06-16 16:37:23", 4, 1),
("2023-08-18 04:39:10", 1, 1),
("2023-09-20 16:31:33", 3, 5);

drop table sells;  

create table products_sells
(
sell_id integer not null,
product_id integer not null,
quantity integer,
constraint cn3 foreign key (sell_id) references sells(sell_id),
constraint cn4 foreign key (product_id) references product(product_id)
);
insert into products_sells
(sell_id, product_id, quantity)
values
(1, 4, 3),
(2, 1, 1),
(2, 2, 3),
(3, 3, 5);

drop table products_sells;  


create table contract
(
contract_id integer not null auto_increment,
FOREIGN KEY (contract_id) REFERENCES staff(employee_id),
contract_start_date DATE DEFAULT (CURRENT_DATE),
contract_end_date date,
salary integer not null default '0',
constraint cont_start_end_cons check (contract_start_date != contract_end_date),
constraint salary_max_cons check (salary < 1000)
);
insert into contract
(contract_end_date, salary)
values
('2023-12-31', 100),
('2023-12-31', 100),
('2023-12-31', 200),
('2023-12-31', 300),
('2023-12-31', 500);

drop table contract;

select * from staff;
select * from contract;
SHOW TABLES FROM db_example;
