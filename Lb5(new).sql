CREATE DATABASE bankDB2;
USE bankDB2;

DROP TABLE IF EXISTS person;
CREATE TABLE person(
    person_id INT PRIMARY KEY AUTO_INCREMENT,
    person_name VARCHAR(30),
    person_surname VARCHAR(30),
    person_address VARCHAR(100),
    person_status ENUM('active', 'frozen', 'closed', 'blocked') DEFAULT 'active',
    person_date DATE
);

DROP TABLE IF EXISTS account;
CREATE TABLE account(
    acc_type ENUM('checking', 'deposit'),
    acc_balance DOUBLE,
    acc_number VARCHAR(50) PRIMARY KEY,
    acc_start_date DATETIME,
    acc_owner INT,
    FOREIGN KEY (acc_owner) REFERENCES person(person_id),
    CHECK (acc_balance >= 0)
);


DROP TABLE IF EXISTS appointment;
CREATE TABLE appointment(
    app_id INT PRIMARY KEY AUTO_INCREMENT,
    app_op INT,
    app_sender VARCHAR(50),
    app_recipient VARCHAR(50),
    app_time DATETIME,
    app_value DOUBLE,
    app_contr_number DOUBLE,
    FOREIGN KEY (app_op) REFERENCES operations(op_id)
);


DROP TABLE IF EXISTS operations;
CREATE TABLE operations(
    op_id INT PRIMARY KEY AUTO_INCREMENT,
    op_type ENUM('deposit', 'withdrawal', 'transfer')
);

INSERT INTO operations (op_type) VALUES ('deposit');
INSERT INTO operations (op_type) VALUES ('withdrawal');
INSERT INTO operations (op_type) VALUES ('transfer');

SELECT * FROM operations;


DROP TRIGGER IF EXISTS `before_update_balance`;
DELIMITER ;;
CREATE TRIGGER `before_update_balance`
BEFORE UPDATE ON `account`
FOR EACH ROW
BEGIN
    DECLARE current_balance DOUBLE;
    
    IF NEW.acc_balance < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Недостаточно средств для завершения транзакции';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM account WHERE acc_number = NEW.acc_number) THEN
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = 'Такого аккаунта не существует';
    END IF;
END;;
DELIMITER ;


DROP PROCEDURE IF EXISTS `transfer1`;
DELIMITER ;;
CREATE PROCEDURE `transfer1` (IN sender VARCHAR(50), IN rec VARCHAR(50), IN transfer_amount DOUBLE)
BEGIN
    DECLARE sender_balance DOUBLE;
    DECLARE recipient_balance DOUBLE;
    DECLARE avg_transfer_amount DOUBLE;
     DECLARE transaction_count INT;

    SELECT AVG(ABS(app_value)) INTO avg_transfer_amount
    FROM appointment
    WHERE app_sender = sender;

SELECT COUNT(*)
    INTO transaction_count
    FROM appointment
    WHERE (app_sender = sender
      AND CAST(app_time AS DATE) = CURDATE()
      AND app_value < 1);

    IF transaction_count >= 100 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Превышен лимит переводов. Попробуйте снова завтра.';
    ELSEIF transfer_amount > 5 * avg_transfer_amount AND avg_transfer_amount IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Зафиксирована подозрительная операция. Свяжитесь со службой поддержки.';
    ELSE
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
                            (3, sender, rec, NOW(), transfer_amount, CONCAT(FLOOR(RAND() * (20 - 10 + 1) + 10), UNIX_TIMESTAMP(NOW()), FLOOR(RAND() * (20 - 10 + 1) + 10)));
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
    END IF;
END;;
DELIMITER ;

CALL transfer1('123456789', '987654321', 50);
SELECT * FROM appointment;
# запрятать в контрольный номер дату, время

SET @res = (SELECT app_contr_number FROM appointment WHERE app_id = 23);
SELECT @res;
SET @res = (SELECT SUBSTRING(@res, 3, LENGTH(@res) - 4));
SELECT FROM_UNIXTIME(@res);


CALL transfer1('987654321', '123456789',50000);
CALL transfer1('123456789', '987654321', 0.1);


DROP PROCEDURE `deposit1`;
DELIMITER ;;
CREATE PROCEDURE `deposit1` (IN acc_number VARCHAR(50), IN deposit_amount DOUBLE)
BEGIN
    DECLARE current_balance DOUBLE;
    
START TRANSACTION;
    SELECT acc_balance INTO current_balance
    FROM account
    WHERE account.acc_number = acc_number;

    IF current_balance IS NOT NULL THEN
        UPDATE account
        SET acc_balance = acc_balance + deposit_amount
        WHERE account.acc_number = acc_number;

        IF ROW_COUNT() > 0 THEN
            INSERT INTO appointment
                (app_op, app_sender, app_recipient, app_time, app_value, app_contr_number)
            VALUES
                (1, NULL, acc_number, NOW(), deposit_amount, RAND(10));

            COMMIT;
        ELSE
            ROLLBACK;
        END IF;
    ELSE
        ROLLBACK;
    END IF;
END;;

DROP PROCEDURE `withdraw1`;;
CREATE PROCEDURE `withdraw1` (IN acc_number VARCHAR(50), IN withdrawal_amount DOUBLE)
BEGIN
    DECLARE current_balance DOUBLE;
START TRANSACTION;

    SELECT acc_balance INTO current_balance
    FROM account
    WHERE account.acc_number = acc_number;

    IF current_balance IS NOT NULL AND current_balance >= withdrawal_amount AND withdrawal_amount > 0 THEN
        UPDATE account
        SET acc_balance = acc_balance - withdrawal_amount
        WHERE account.acc_number = acc_number;

        IF ROW_COUNT() > 0 THEN
            INSERT INTO appointment
                (app_op, app_sender, app_recipient, app_time, app_value, app_contr_number)
            VALUES
                (2, acc_number, NULL, NOW(), withdrawal_amount, RAND(10));
            COMMIT;
        ELSE
            ROLLBACK;
        END IF;
    ELSE
        ROLLBACK;
    END IF;
END;;
DELIMITER ;

# 1.5 Основные данные счёта должны хранится в зашифрованном виде. Произведите шифрование. 
INSERT INTO person (person_name, person_surname, person_address, person_date)
VALUES ('Иван', 'Иванов', 'Москва, ул. Примерная, д. 1', '1990-01-15'),
('Мария', 'Петрова', 'Санкт-Петербург, ул. Тестовая, д. 2', '1985-05-20');

ALTER TABLE person
 MODIFY person_name VARBINARY(100),
 MODIFY person_surname VARBINARY(100),
 MODIFY person_address VARBINARY(100);

SELECT * FROM person;

UPDATE person
SET person_name = aes_encrypt(person_name, 'name');
UPDATE person
SET person_surname = aes_encrypt(person_surname, 'surname');
UPDATE person
SET person_address = aes_encrypt(person_address, 'address');

SELECT cast(aes_decrypt(person_name, 'name') AS CHAR) from person;


# 1.6.  Создайте представление для отображения истории счёта, конкретного пользователя за определённый период.
DROP PROCEDURE IF EXISTS `generate_account_history_view`;
DELIMITER ;;
CREATE PROCEDURE `generate_account_history_view` (
    IN user_id INT,
    IN start_date DATETIME,
    IN end_date DATETIME
)
BEGIN
    DROP VIEW IF EXISTS user_view;

    SET @create_query = CONCAT(
        'CREATE VIEW user_view AS ',
        'SELECT ap.app_time, o.op_type, ',
        'CASE WHEN o.op_type = \'transfer\' THEN ',
        '         CASE WHEN a.acc_number = ap.app_sender THEN -ap.app_value ',
        '              WHEN a.acc_number = ap.app_recipient THEN ap.app_value ',
        '         END ',
        '     WHEN o.op_type IN (\'deposit\', \'withdraw\') THEN ap.app_value ',
        '     ELSE 0 END AS transaction_amount, ',
        'ap.app_sender AS sender_account_number, ',
        'ap.app_recipient AS recipient_account_number ',
        ' FROM account a',
        ' JOIN appointment ap ON a.acc_number = ap.app_sender OR a.acc_number = ap.app_recipient',
        ' JOIN operations o ON ap.app_op = o.op_id',
        ' WHERE a.acc_owner = ', user_id,
        ' AND ap.app_time BETWEEN ''', start_date, ''' AND ''', end_date, ''''
    );

    PREPARE create_q FROM @create_query;
    EXECUTE create_q;
    DEALLOCATE PREPARE create_q;

	SELECT * FROM user_view;
END;;
DELIMITER ;

DELETE FROM account;
INSERT INTO account (acc_type, acc_balance, acc_number, acc_start_date, acc_owner)
VALUES 
('checking', 1000.00, '123456789', NOW(), 1),
('checking', 500.00, '987654321', NOW(), 2);
SELECT * FROM account;

CALL transfer1('123456789', '987654321', 10);
CALL withdraw1('123456789',  100);
CALL withdraw1('987654321',  200);
CALL deposit1('987654321',  150);
CALL deposit1('987654321',  300);
CALL transfer1('987654321', '123456789',  0);

# 	Ограничить кол-во транзакций для одного аккаунта так, чтобы детектить мошенников. (необычные операции)

CALL generate_account_history_view(2, '2023-01-01', '2023-12-31');
CALL generate_account_history_view(1, '2023-01-01', '2023-12-31');

# 1.7 Добавьте в вашу БД отдельную функциональность с кредитами пользователя.

SELECT * FROM credit_types;
CREATE TABLE credit_types (
    credit_type_id INT PRIMARY KEY AUTO_INCREMENT,
    credit_name VARCHAR(50),
    interest_rate DECIMAL(5, 2) NOT NULL 
);

INSERT INTO credit_types (credit_name, interest_rate) VALUES
('Добрый', 0.5),
('Нормальный', 3),
('Так себе', 5),
('Злой', 10);

DROP TABLE user_credits;
CREATE TABLE user_credits (
    user_credit_id INT PRIMARY KEY AUTO_INCREMENT,
    acc_number VARCHAR(50) NOT NULL,
    credit_type_id INT,
    credit_amount DOUBLE NOT NULL,
    credit_start_date DATETIME NOT NULL,
    credit_end_date DATETIME NOT NULL,
    FOREIGN KEY (acc_number) REFERENCES account(acc_number),
    FOREIGN KEY (credit_type_id) REFERENCES credit_types(credit_type_id),
    CHECK (credit_amount > 0),
    CHECK (credit_start_date < credit_end_date)
);

DROP TABLE credit_payments;
CREATE TABLE credit_payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    user_credit_id INT,
    payment_due_date DATETIME NOT NULL,
    payment_amount DOUBLE,
    payment_date DATETIME,
    is_paid BOOLEAN DEFAULT false,
    FOREIGN KEY (user_credit_id) REFERENCES user_credits(user_credit_id),
    CHECK (payment_amount > 0)
);

# 1.8. Реализуйте хранимые процедуры для получения кредитной истории, получения и пошагового погашения кредита 
# с различным типом процентных ставок в транзактном режиме.

ALTER TABLE operations 
MODIFY op_type ENUM('deposit', 'withdrawal', 'transfer', 'credit_payment');

SELECT * FROM operations;
UPDATE operations 
SET op_type = 'credit_payment' WHERE op_id = 4;

DROP PROCEDURE `apply_for_credit`;
DELIMITER ;;
CREATE PROCEDURE `apply_for_credit` (
    IN p_acc_number VARCHAR(50),
    IN p_credit_type_id INT,
    IN p_credit_amount DOUBLE,
    IN p_credit_start_date DATE,
    IN p_credit_end_date DATE
)
BEGIN
    DECLARE interest_rate DECIMAL(5, 2);

    SELECT credit_types.interest_rate INTO interest_rate
    FROM credit_types
    WHERE credit_type_id = p_credit_type_id;

    INSERT INTO user_credits (acc_number, credit_type_id, credit_amount, credit_start_date, credit_end_date)
    VALUES (p_acc_number, p_credit_type_id, p_credit_amount, p_credit_start_date, p_credit_end_date);

    CALL generate_credit_payments(LAST_INSERT_ID(), p_credit_start_date, p_credit_end_date, interest_rate, p_credit_amount);
END;;
DELIMITER ;


DROP PROCEDURE `generate_credit_payments`;
DELIMITER ;;
CREATE PROCEDURE `generate_credit_payments` (
    IN p_user_credit_id INT,
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN interest_rate DECIMAL(5, 2),
    IN p_remaining_amount DOUBLE
)
BEGIN
    DECLARE cur_date DATE;
    DECLARE payment_amount DOUBLE;
    DECLARE p_interest_rate DECIMAL(5, 2);
    
    SET cur_date = p_start_date;
	SET p_interest_rate = interest_rate/100;

    WHILE cur_date <= p_end_date DO
        SET payment_amount = p_remaining_amount * (p_interest_rate + p_interest_rate/(POWER(1+p_interest_rate, (DATEDIFF(p_end_date , p_start_date) / 30)) -1));

        INSERT INTO credit_payments (user_credit_id, payment_due_date, payment_amount)
        VALUES (p_user_credit_id, cur_date, payment_amount);

        SET cur_date = ADDDATE(cur_date, INTERVAL 1 MONTH);
    END WHILE;
END;;
DELIMITER ;




SELECT 12000 * (0.005 + 0.005/(POWER(1+0.005, (DATEDIFF('2024-01-01' , '2023-01-01') / 30)) -1));




DELIMITER ;;
CREATE TRIGGER `update_credit_on_payment`
AFTER UPDATE ON credit_payments
FOR EACH ROW
BEGIN
    DECLARE total_paid DOUBLE;
    SELECT COALESCE(SUM(payment_amount), 0) INTO total_paid
    FROM credit_payments
    WHERE user_credit_id = NEW.user_credit_id AND is_paid = true;

    UPDATE user_credits
    SET credit_amount = credit_amount - total_paid
    WHERE user_credit_id = NEW.user_credit_id;
END;;
DELIMITER ;

DROP PROCEDURE `pay_credit_payment`;
DELIMITER ;;
CREATE PROCEDURE `pay_credit_payment` (
     IN p_acc_number VARCHAR(50)
)
BEGIN
    DECLARE payment_amount DOUBLE;
    DECLARE last_unpaid_payment_id INT;

    SELECT MIN(cp.payment_id) INTO last_unpaid_payment_id
    FROM credit_payments cp
    JOIN user_credits uc ON cp.user_credit_id = uc.user_credit_id
    WHERE uc.acc_number = p_acc_number AND cp.is_paid = FALSE;

    IF last_unpaid_payment_id IS NOT NULL THEN

        SELECT cp.payment_amount INTO payment_amount
        FROM credit_payments cp
        JOIN user_credits uc ON cp.user_credit_id = uc.user_credit_id
        WHERE cp.payment_id = last_unpaid_payment_id;

        UPDATE credit_payments
        SET is_paid = TRUE, payment_date = NOW()
        WHERE payment_id = last_unpaid_payment_id;

        INSERT INTO appointment
            (app_op, app_sender, app_value, app_time, app_contr_number)
        VALUES
            (4, p_acc_number, -payment_amount, NOW(), RAND(10));
    END IF;
END;;
DELIMITER ;



SELECT * FROM appointment;

SHOW TRIGGERS;
DROP TRIGGER IF EXISTS `after_update_credit_payments`;
DELIMITER ;;
CREATE TRIGGER `after_update_credit_payments`
AFTER UPDATE ON `credit_payments`
FOR EACH ROW
BEGIN
    DECLARE payment_amount DOUBLE;
    DECLARE acc_number VARCHAR(50);

    IF NEW.is_paid = TRUE AND OLD.is_paid = FALSE THEN

        SELECT NEW.payment_amount INTO payment_amount;

        SELECT uc.acc_number INTO acc_number
        FROM user_credits uc
        WHERE uc.user_credit_id = NEW.user_credit_id;

        UPDATE account
        SET acc_balance = acc_balance - payment_amount
        WHERE account.acc_number = acc_number;
    END IF;
END;
;;
DELIMITER ;





SELECT * FROM account;

CALL apply_for_credit('123456789', 2, 12000, '2023-01-01','2024-01-01');

SELECT * FROM credit_payments;
SELECT * FROM user_credits;


CALL pay_credit_payment('123456789');

UPDATE account SET acc_balance = 10000;
CALL deposit1('123456789', 10000);
CALL generate_account_history_view(1, '2023-01-01', '2023-12-31');


SELECT * FROM appointment;

DROP PROCEDURE IF EXISTS `generate_full_account_history_view`;
DELIMITER ;;
CREATE PROCEDURE `generate_full_account_history_view` (
    IN user_id INT,
    IN start_date DATETIME,
    IN end_date DATETIME
)
BEGIN
    DROP VIEW IF EXISTS full_account_history_view;

    SET @create_query = CONCAT(
        'CREATE VIEW full_account_history_view AS ',
        'SELECT ap.app_time, o.op_type, ',
        'CASE WHEN o.op_type = \'transfer\' THEN ',
        '         CASE WHEN a.acc_number = ap.app_sender THEN -ap.app_value ',
        '              WHEN a.acc_number = ap.app_recipient THEN ap.app_value ',
        '         END ',
        '     WHEN o.op_type IN (\'deposit\', \'withdraw\') THEN ap.app_value ',
        '     WHEN o.op_type = \'credit_payment\' THEN ap.app_value ', 
        '     ELSE 0 END AS transaction_amount, ',
        'ap.app_sender AS sender_account_number, ',
        'ap.app_recipient AS recipient_account_number ',
        ' FROM account a',
        ' JOIN appointment ap ON a.acc_number = ap.app_sender OR a.acc_number = ap.app_recipient',
        ' JOIN operations o ON ap.app_op = o.op_id',
        ' WHERE a.acc_owner = ', user_id,
        ' AND ap.app_time BETWEEN ''', start_date, ''' AND ''', end_date, ''''
    );

    PREPARE create_q FROM @create_query;
    EXECUTE create_q;
    DEALLOCATE PREPARE create_q;

    SELECT * FROM full_account_history_view;
END;;
DELIMITER ;



CALL generate_full_account_history_view(1, '2023-01-01', '2024-01-01');

#_________________________________________3___________________________________________________________
use bankDB2;

#_________________________________________4_________________________________

CREATE DATABASE quotesDB;
USE quotesDB;

DROP TABLE quotes;
CREATE TABLE quotes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    author VARCHAR(100),
    text TEXT,
    FULLTEXT (text)
);

DELETE FROM quotes;
INSERT INTO quotes (author, text) VALUES
('Eric Schmidt', 'The more data we generate, the more reliant we are on skilled data experts who can turn it into something meaningful.'),
('Peter Sondergaard', 'Just like oil, data is useless until it’s mined and handled (i.e. analyzed) in the right way.'),
('Dan Heath', 'The difference between raw data and insights, and how data alone is rarely ever meaningful.'),
('Dean Abbott', 'All models are wrong, but some are useful.'),
('Sherlock Holmes', 'Ideas or theories without data are just assumptions, with no factual reality to back them up.'),
('Mark Twain', 'Unless you have a plan for that data, it won’t really be of much use.'),
('Ernest Dimnet', 'Our potential for innovation, problem-solving, and growth is only as good as the data we collect and, most importantly, utilize.'),
('Jay Baer', 'The data is certainly there, but not everybody is using it.'),
('Marissa Mayer', 'The sooner an organization starts collecting data, the sooner they can benefit from its insights.'),
('Charles Babbage', 'Any data is better than nothing.'),
('Hilary Mason', 'A key part of data analytics is having a “feel” for what questions you should be asking, and developing an intuition for what story the data might be trying to tell you.'),
('Josh Wills', 'A data scientist is at the intersection of statistics and engineering.'),
('Jennifer Shin', 'Data scientists are curious people, and what makes them great at what they do is an innate drive to find answers and solve problems.'),
('Robert Cailliau', 'Data has huge potential to address global issues and ultimately make the world a better place.'),
('Vik Paruchuri', 'Data is such a broad field, spanning a whole host of industries; it’s entirely feasible to combine your love of data with a sector that resonates with you.'),
('Ash Gupta', 'Getting information off the internet is like taking a drink from a firehose.'),
('Nate Silver', 'On average, people should be more skeptical when they see numbers. They should be more willing to play around with the data themselves.'),
('Dan Ariely', 'We should teach the students, as well as executives, how to conduct experiments, how to examine data, and how to use these tools to make better decisions.'),
('Thomas H. Davenport', 'Every company has big data in its future, and every company will eventually be in the data business.'),
('Virginia M. (Ginni) Rometty', 'Big data will spell the death of customer segmentation and force the marketer to understand each customer as an individual within 18 months or risk being left in the dust.'),
('Andrew McAfee', 'The world is one big data problem.'),
('Beyoncé', 'All the single ladies, all the single ladies'),
('Eminem', 'His palms are sweaty, knees weak, arms are heavy'),
('Kelly Clarkson', 'Since you been gone, I can breathe for the first time'),
('Nelly', 'It’s getting hot in here, so take off all your clothes'),
('OutKast', 'Shake it like a Polaroid picture'),
('Britney Spears', 'Oops!... I Did It Again'),
('Destiny’s Child', 'Im a survivor, Im not gonna give up'),
('Avril Lavigne', 'He was a skater boy, she said see you later boy'),
('Green Day', 'Wake me up when September ends'),
('Black Eyed Peas', 'I gotta feeling that tonight’s gonna be a good night'),
('Justin Timberlake', 'Its like youre my mirror, my mirror staring back at me'),
('Linkin Park', 'In the end, it doesn’t even matter'),
('Shakira', 'Whenever, wherever, we’re meant to be together'),
('Evanescence', 'Wake me up inside, I can’t wake up'),
('Jennifer Lopez', 'Love dont cost a thing'),
('Coldplay', 'Lights will guide you home'),
('Alicia Keys', 'Concrete jungle where dreams are made of'),
('Sum 41', 'Because, in the end, we all end up alone'),
('Rihanna', 'Shine bright like a diamond'),
('Alicia Keys', 'I keep on fallin’ in and out of love with you'),
('U2', 'It’s a beautiful day, don’t let it get away'),
('John Mayer', 'Your body is a wonderland'),
('Sheryl Crow', 'Soak up the sun, tell me when the day is done'),
('Christina Aguilera', 'I feel like I’ve been locked up tight for a century of lonely nights'),
('Nickelback', 'Look at this photograph, every time I do it makes me laugh'),
('Nelly Furtado', 'I’m like a bird, I only fly away'),
('Dido', 'My tea’s gone cold, I’m wondering why I got out of bed at all'),
('Shakira', 'Lucky you were born that far away so we could both make fun of distance'),
('Coldplay', 'Nobody said it was easy, no one ever said it would be this hard'),
('Eminem', 'Im beginning to feel like a Rap God, Rap God'),
('Norah Jones', 'Don’t know why I didn’t come, when I saw the break of day'),
('Aerosmith', 'I don’t wanna close my eyes, I don’t wanna fall asleep'),
('The Fray', 'All my thoughts of you, they could heat or cool the room'),
('Gorillaz', 'It’s a bitter pill to swallow, so I’ll just spit it out'),
('Nelly', 'Its getting harder and harder to breathe'),
('Red Hot Chili Peppers', 'Californication, born and raised by those who praise control of population'),
('Justin Timberlake', 'What goes around, goes around, goes around, comes all the way back around'),
('The Black Eyed Peas', 'People killing people dying, children hurting, I hear them crying'),
('Adele', 'We could have had it all, rolling in the deep'),
('Hoobastank', 'Im not a perfect person, theres many things I wish I didnt do'),
('Oasis', 'Because maybe, youre gonna be the one that saves me'),
('Cersei Lannister', 'When you play the game of thrones, you win or you die.'),
('Jaime Lannister', 'The things I do for love.'),
('Eddard Stark', 'Winter is coming.'),
('Catelyn Stark', 'Family, duty, honor.'),
('Jorah Mormont', 'The common people pray for rain, healthy children, and a summer that never ends. It is no matter to them if the high lords play their game of thrones, so long as they are left in peace.'),
('Tywin Lannister', 'A lion does not concern itself with the opinion of sheep.'),
('Melisandre', 'The night is dark and full of terrors.'),
('Varys', 'Power resides where men believe it resides. It’s a trick, a shadow on the wall.'),
('Ygritte', 'You know nothing, Jon Snow.'),
('Samwell Tarly', 'I always wanted to be a wizard.'),
('Cersei Lannister', 'Power is power.'),
('Jaime Lannister', 'There are no men like me. Only me.'),
('Davos Seaworth', 'I’ve never been much of a fighter. Apologies for what you’re about to see.'),
('Joffrey Baratheon', 'Everyone is mine to torment.'),
('Tyrion Lannister', 'I have a tender spot in my heart for cripples, bastards, and broken things.'),
('Eddard Stark', 'The man who passes the sentence should swing the sword.'),
('Tyrion Lannister', 'I try to know as many people as I can. You never know which one you’ll need.'),
('Arya Stark', 'A girl has no name.'),
('Daenerys Targaryen', 'Dracarys.'),
('Jaime Lannister', 'So many vows… they make you swear and swear. Defend the king. Obey the king. Keep his secrets. Do his bidding. Your life for his. But obey your father. Love your sister. Protect the innocent. Defend the weak. Respect the gods. Obey the laws. It’s too much. No matter what you do, you’re forsaking one vow or the other.'),
('Varys', 'A very small man can cast a very large shadow.'),
('Tormund Giantsbane', 'The big woman still here?'),
('Stannis Baratheon', 'A good act does not wash out the bad, nor a bad act the good. Each should have its own reward.'),
('Petyr Baelish', 'Chaos isn’t a pit. Chaos is a ladder.'),
('Petyr Baelish', 'A man with no motive is a man no one suspects. Always keep your foes confused.'),
('Petyr Baelish', 'Gold wins wars, not soldiers.'),
('Petyr Baelish', 'Knowledge is power.'),
('Petyr Baelish', 'I did warn you not to trust me.'),
('Petyr Baelish', 'The climb is all there is.');


SELECT * FROM quotes WHERE MATCH(text) AGAINST('power');
SELECT * FROM quotes WHERE MATCH(text) AGAINST('data');

SELECT * FROM quotes WHERE MATCH(text) AGAINST('night' WITH QUERY EXPANSION);

SELECT * FROM quotes WHERE MATCH(text) AGAINST('+night + good' IN BOOLEAN MODE);
SELECT * FROM quotes WHERE MATCH(text) AGAINST('-night + good' IN BOOLEAN MODE);
SELECT * FROM quotes WHERE MATCH(text) AGAINST('+night - good' IN BOOLEAN MODE);
SELECT * FROM quotes WHERE MATCH(text) AGAINST('night + good');
SELECT * FROM quotes WHERE MATCH(text) AGAINST('"night good"' IN BOOLEAN MODE);
SELECT * FROM quotes WHERE MATCH(text) AGAINST('"good night"' IN BOOLEAN MODE);

SELECT id, author, text, 
    MATCH(text) AGAINST('power') AS relevance
FROM quotes
WHERE MATCH(text) AGAINST('power')
ORDER BY relevance DESC;

INSERT INTO quotes(text)
VALUES
('Power'),
('Power adkshbgufqcbha'),
('Power Power'),
('Power power adkshbgufqcbha'),
('dnhsfjfsdfj');


SELECT id, author, text, 
    MATCH(text) AGAINST('power') AS relevance
FROM quotes
WHERE MATCH(text) AGAINST('power')
ORDER BY relevance DESC;

INSERT INTO quotes(text)
VALUES
('Power fdjs. fjhasda.. sfajahsd.as asaakjda. SDJKAWKJQ. sjhsaa. shshshak,sjnds. wsajdskq. skjajwnsda.');



#_________________________________________5___________________________________________________________


#_________________________________________6___________________________________________________________

use world;
SELECT CountryCode,sum(Population) from city GROUP BY CountryCode;

SELECT CountryCode, name, sum(Population) OVER (partition by CountryCode) from city;

SELECT *, Rank() OVER (partition by CountryCode ORDER BY Population DESC) AS r FROM city;

SELECT CountryCode, sum(Population) FROM
(SELECT *, Rank() OVER (partition by CountryCode ORDER BY Population DESC) AS r FROM city) AS t
WHERE t.r <= 2
GROUP BY CountryCode;


# 1. Для каждой страны определите её позицию в алфавитном порядке относительно других стран. 
# Выведите следующие столбцы: CountryName, AlphabeticalPosition.

SELECT name, ROW_NUMBER() OVER (order by name) AS AlphabeticalPosition FROM country;

# 2. Для каждого языка определите страну, в которой этот язык является официальным, и выведите столбцы:
# LanguageName - название языка.
# CountryName - название страны, в которой язык является официальным.
# NumOfficialLanguages - количество официальных языков в данной стране.

SELECT cl.language AS LanguageName,  c.name AS CountryName, COUNT(*) OVER (partition by cl.CountryCode) AS NumOfficialLanguages
FROM countrylanguage AS cl
JOIN country AS c ON cl.countryCode = c.Code
WHERE isOfficial = 'T';

# 3. Для каждого города определите следующее:
# CityName - название города.
# CountryName - название страны, в которой находится город.
# Population - население города.
# AveragePopulation - среднее население городов в той же стране, что и данный город.
# PopulationVsAverage - отношение населения данного города к среднему населению городов в той же стране (в процентах).

SELECT
    ci.name AS CityName,
    c.name AS CountryName,
    ci.population AS Population,
    AVG(ci.population) OVER (PARTITION BY ci.CountryCode) AS AveragePopulation,
    IF(ci.population > 0, ROUND(ci.population / AVG(ci.population) OVER (PARTITION BY ci.CountryCode) * 100, 2), 0) AS PopulationVsAverage
FROM
    city AS ci
LEFT JOIN
    country AS c ON ci.CountryCode = c.Code
    ORDER BY PopulationVsAverage ASC;



