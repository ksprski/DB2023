create database bankDB;
use bankDB;

set global log_bin_trust_function_creators = 1;
set SQL_SAFE_UPDATES = 0;

DROP TABLE account;
CREATE TABLE account(
acc_type enum('debet', 'credit'),
acc_balance DOUBLE,
acc_number VARCHAR(50) PRIMARY KEY,
acc_start_date DATETIME,
acc_owner INT,
FOREIGN KEY (acc_owner) REFERENCES person(person_id)
);

DROP TABLE person;
CREATE TABLE person(
person_id INT PRIMARY KEY auto_increment,
person_name VARCHAR(30),
person_surname VARCHAR(30),
person_adress VARCHAR(50),
person_status enum('active', 'frozen', 'closed', 'blocked'),
person_date DATE
);

DROP TABLE appointment;
CREATE TABLE appointment(
app_id INT PRIMARY KEY auto_increment,
app_op INT,
app_sender VARCHAR(50),
app_recipient VARCHAR(50),
app_time DATETIME,
app_value DOUBLE,
app_contr_number DOUBLE,
FOREIGN KEY (app_op) REFERENCES operations(op_id)
);

DROP TABLE operations;
CREATE TABLE operations(
op_id INT PRIMARY KEY AUTO_INCREMENT,
op_type ENUM('deposit', 'withdrawal', 'transfer', 'payment', 'hold', 'reversal')
);

INSERT INTO operations (op_type) VALUES ('transfer');
INSERT INTO operations (op_type) VALUES ('withdrawal');
INSERT INTO operations (op_type) VALUES ('deposit');


DROP TABLE account_operations;
CREATE TABLE account_operations(
acc_number VARCHAR(50),
op_id INT,
PRIMARY KEY (acc_number, op_id),
FOREIGN KEY (acc_number) REFERENCES account(acc_number),
FOREIGN KEY (op_id) REFERENCES operations(op_id)
);


#________________________1___________________________

DROP PROCEDURE `transfer1` ;
DELIMITER ;;
CREATE PROCEDURE `transfer1` (IN sender VARCHAR(50), IN rec VARCHAR(50), IN transfer_amount DOUBLE)
BEGIN

    DECLARE sender_balance DOUBLE;
    DECLARE recipient_balance DOUBLE;

    IF NOT EXISTS (SELECT 1 FROM account WHERE acc_number = sender) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sender account does not exist';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM account WHERE acc_number = rec) THEN
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = 'Recipient account does not exist';
    END IF;
START TRANSACTION;
    SELECT acc_balance INTO sender_balance
    FROM account
    WHERE acc_number = sender;

    IF sender_balance >= transfer_amount AND transfer_amount > 0 THEN
        SELECT acc_balance INTO recipient_balance
        FROM account
        WHERE acc_number = rec;

        IF recipient_balance IS NOT NULL THEN
            UPDATE account
            SET acc_balance = acc_balance - transfer_amount
            WHERE acc_number = sender;

            IF ROW_COUNT() > 0 THEN
                UPDATE account
                SET acc_balance = acc_balance + transfer_amount
                WHERE acc_number = rec;

                IF ROW_COUNT() > 0 THEN
                    INSERT INTO appointment
                        (app_op, app_sender, app_recipient, app_time, app_value, app_contr_number)
                    VALUES
                        (3, sender, rec, NOW(), transfer_amount, RAND(10));
                    COMMIT;
                ELSE
                    ROLLBACK;
                END IF;
            ELSE
                ROLLBACK;
            END IF;
        ELSE
            ROLLBACK;
        END IF;
    ELSE
        ROLLBACK;
    END IF;
END;;
DELIMITER ;

DROP PROCEDURE `deposit1`;
DELIMITER ;;
CREATE PROCEDURE `deposit1` (IN acc_number VARCHAR(50), IN deposit_amount DOUBLE)
BEGIN
    DECLARE current_balance DOUBLE;

    -- Проверяем существование аккаунта
    IF NOT EXISTS (SELECT 1 FROM account WHERE account.acc_number = acc_number) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Account does not exist';
    END IF;
START TRANSACTION;
    -- Получаем текущий баланс
    SELECT acc_balance INTO current_balance
    FROM account
    WHERE account.acc_number = acc_number;

    -- Проверяем, что счет существует
    IF current_balance IS NOT NULL THEN
        -- Пополняем счет
        UPDATE account
        SET acc_balance = acc_balance + deposit_amount
        WHERE account.acc_number = acc_number;

        -- Проверяем, что обновление прошло успешно
        IF ROW_COUNT() > 0 THEN
            -- Добавляем запись о пополнении в appointment
            INSERT INTO appointment
                (app_op, app_sender, app_recipient, app_time, app_value, app_contr_number)
            VALUES
                (1, NULL, acc_number, NOW(), deposit_amount, RAND(10));

            -- Подтверждаем транзакцию
            COMMIT;
        ELSE
            -- Откатываем транзакцию из-за неудачного обновления баланса
            ROLLBACK;
        END IF;
    ELSE
        -- Откатываем транзакцию из-за отсутствия счета
        ROLLBACK;
    END IF;
END;;

DROP PROCEDURE `withdraw1`;;
CREATE PROCEDURE `withdraw1` (IN acc_number VARCHAR(50), IN withdrawal_amount DOUBLE)
BEGIN
    DECLARE current_balance DOUBLE;

    -- Проверяем существование аккаунта
    IF NOT EXISTS (SELECT 1 FROM account WHERE account.acc_number = acc_number) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Account does not exist';
    END IF;

START TRANSACTION;
    -- Получаем текущий баланс
    SELECT acc_balance INTO current_balance
    FROM account
    WHERE account.acc_number = acc_number;

    -- Проверяем, что счет существует и достаточно средств для снятия
    IF current_balance IS NOT NULL AND current_balance >= withdrawal_amount AND withdrawal_amount > 0 THEN
        -- Снимаем средства
        UPDATE account
        SET acc_balance = acc_balance - withdrawal_amount
        WHERE account.acc_number = acc_number;

        -- Проверяем, что обновление прошло успешно
        IF ROW_COUNT() > 0 THEN
            -- Добавляем запись о снятии в appointment
            INSERT INTO appointment
                (app_op, app_sender, app_recipient, app_time, app_value, app_contr_number)
            VALUES
                (2, acc_number, NULL, NOW(), withdrawal_amount, RAND(10));

            -- Подтверждаем транзакцию
            COMMIT;
        ELSE
            -- Откатываем транзакцию из-за неудачного обновления баланса
            ROLLBACK;
        END IF;
    ELSE
        -- Откатываем транзакцию из-за недостаточных средств или отсутствия счета
        ROLLBACK;
    END IF;
END;;
DELIMITER ;



INSERT INTO person (person_name, person_surname, person_adress, person_date)
VALUES ('Иван', 'Иванов', 'Москва, ул. Примерная, д. 1', '1990-01-15'),
('Мария', 'Петрова', 'Санкт-Петербург, ул. Тестовая, д. 2', '1985-05-20');

SELECT * FROM person;

INSERT INTO account (acc_type, acc_balance, acc_number, acc_start_date, acc_owner)
VALUES ('debet', 1000.00, '123456789', NOW(), 1),
('credit', 500.00, '987654321', NOW(), 2);
SELECT * FROM account;



