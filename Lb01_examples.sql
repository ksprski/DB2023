SET GLOBAL sql_mode='';
SHOW VARIABLES LIKE 'sql_mode';

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
(employee_id integer primary key auto_increment,
employee_name varchar(50) DEFAULT '' not null,
employee_surname varchar(50) DEFAULT '' not null,
employee_position enum('barman','cook')
);
insert into staff 
(employee_name, employee_surname, employee_position)
values
('Ярослав', 'Гершов', 'barman'),
('Варвара','Бондаренко', 'barman'),
('Марагрита', 'Кольке', 'cook'),
('Екатерина','Шклярик', 'cook'),
('Григорий','Янушкевич', 'cook');

ALTER TABLE staff
ADD employee_birthdate date;

insert into staff 
(employee_birthdate)
value
("2003-12-05"),
("2003-11-04"),
('2002-12-01'),
('2004-01-01'),
('2004-03-05');

ALTER TABLE staff
ADD employee_age INTEGER DEFAULT (YEAR((CURRENT_DATE)) - YEAR(employee_birthdate));


drop table staff;  

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
("2022-06-16 16:37:23", 2, 1),
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
(product_id, quantity)
values
(2, 3),
(1, 1),
(2, 3),
(4, 5);

drop table products_sells;  


create table contract
(
contract_id integer primary key auto_increment,
contract_start_date DATE DEFAULT (CURRENT_DATE),
contract_end_date date,
salary integer not null default '0',
constraint cont_start_end_cons check (contract_start_date != contract_end_date),
constraint salary_max_cons check (salary < 1000)
);


select * from staff;
SHOW TABLES FROM db_example;
