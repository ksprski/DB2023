CREATE DATABASE FoM_db;
USE FoM_db;

DROP TABLE Operators;
CREATE TABLE Operators (
    id INT PRIMARY KEY auto_increment,
    firstName VARCHAR(255),
    lastName VARCHAR(255),
    contactEmail VARCHAR(255)
);

CREATE TABLE Editors (
    id INT PRIMARY KEY auto_increment,
    firstName VARCHAR(255),
    lastName VARCHAR(255),
    contactEmail VARCHAR(255)
);


DROP TABLE NumberOfRelease;
CREATE TABLE NumberOfRelease (
    id INT PRIMARY KEY  auto_increment,
    releaseNumber INT,
    shootingDate DATE,
    operatorId INT,
    editorId INT,
    FOREIGN KEY (operatorId) REFERENCES Operators(id),
    FOREIGN KEY (editorId) REFERENCES Editors(id)
);




DROP TABLE Participants;
CREATE TABLE Participants (
    id INT PRIMARY KEY  auto_increment,
    firstName VARCHAR(255),
    lastName VARCHAR(255),
    contactEmail VARCHAR(255),
    participationHistory TEXT
);

DROP TABLE QuestionTexts;
CREATE TABLE QuestionTexts (
    id INT PRIMARY KEY auto_increment,
    questionText TEXT,
    releaseId INT,
    FOREIGN KEY (releaseId) REFERENCES NumberOfRelease(id)
);


DROP TABLE Rounds;
CREATE TABLE Rounds (
    id INT PRIMARY KEY  auto_increment,
    roundNumber INT,
    releaseId INT,
    FOREIGN KEY (releaseId) REFERENCES NumberOfRelease(id)
);


DROP TABLE GiftsToYakubovich;
CREATE TABLE GiftsToYakubovich (
    id INT PRIMARY KEY  auto_increment,
    giftDescription TEXT,
    participantId INT,
    releaseId INT,
    FOREIGN KEY (participantId) REFERENCES Participants(id),
    FOREIGN KEY (releaseId) REFERENCES NumberOfRelease(id)
);

DROP TABLE Prizes;
CREATE TABLE Prizes (
    id INT PRIMARY KEY  auto_increment,
    prizeName VARCHAR(255),
    prizeDescription TEXT
);

DROP TABLE Winners;
CREATE TABLE Winners (
    id INT PRIMARY KEY  auto_increment,
    participantId INT,
    prizeId INT,
    releaseId INT,
    FOREIGN KEY (participantId) REFERENCES Participants(id),
    FOREIGN KEY (prizeId) REFERENCES Prizes(id),
    FOREIGN KEY (releaseId) REFERENCES NumberOfRelease(id)
);

DROP TABLE Ratings;
CREATE TABLE Ratings (
    id INT PRIMARY KEY  auto_increment,
    showRating DECIMAL(5,2),
    releaseId INT,
    FOREIGN KEY (releaseId) REFERENCES NumberOfRelease(id)
);


DROP TABLE AdvertisingSponsors;
CREATE TABLE AdvertisingSponsors (
    id INT PRIMARY KEY  auto_increment,
    sponsorName VARCHAR(255),
    cooperationConditions TEXT,
    releaseId INT,
    FOREIGN KEY (releaseId) REFERENCES NumberOfRelease(id)
);

INSERT INTO AdvertisingSponsors (sponsorName, cooperationConditions, releaseId)
VALUES
    ('Рекламная компания "Экспресс-Авто"', 'Размещение логотипа на доске вопросов и 30 секундный рекламный ролик', 1),
    ('Кофейня "Аромат утра"', 'Предоставление бесплатных напитков для участников', 2),
    ('Технологическая компания "Инновации 2023"', 'Реклама нового гаджета в начале выпуска', 3),
    ('Сеть ресторанов "Вкусный уголок"', 'Специальное меню для участников и зрителей', 4),
    ('Банк "Финансовый успех"', 'Подарок каждому участнику и ведущему - банковская карта с бонусами', 3),
    ('Магазин спортивных товаров "СпортЛайф"', 'Розыгрыш подарочных сертификатов для зрителей', 1),
    ('Авиакомпания "Высокое небо"', 'Лотерея на билеты на рейсы для участников', 1);

CREATE TABLE AdvertisingCampaigns (
    id INT PRIMARY KEY AUTO_INCREMENT,
    campaignName VARCHAR(255),
    startDate DATE,
    endDate DATE,
    budget DECIMAL(10, 2)
);

ALTER TABLE AdvertisingSponsors
ADD COLUMN campaignId INT,
ADD FOREIGN KEY (campaignId) REFERENCES AdvertisingCampaigns(id);


CREATE TABLE ViewerReviews (
    reviewId INT PRIMARY KEY AUTO_INCREMENT,
    viewerName VARCHAR(255),
    email VARCHAR(255),
    commentText TEXT,
    rating INT,
    releaseId INT,
    FOREIGN KEY (releaseId) REFERENCES NumberOfRelease(id)
);

INSERT INTO ViewerReviews (viewerName, email, commentText, rating, releaseId)
VALUES
    ('Иванов Петр', 'ivanov@example.com', 'Отличное шоу, интересные вопросы!', 5, 1),
    ('Мария Сидорова', 'maria@example.com', 'Хочу больше раундов в следующем выпуске!', 4, 2),
    ('Алексей Козлов', 'alex@example.com', 'Увлекательное шоу, но вопросы слишком сложные', 3, 3),
    ('Екатерина Иванова', 'ekaterina@example.com', 'Отличная атмосфера, но не хватает призов', 4, 4),
    ('Дмитрий Петров', 'dmitriy@example.com', 'Прикольное шоу, ждем следующий выпуск!', 5, 1),
    ('Анна Михайлова', 'anna@example.com', 'Молодцы, продолжайте в том же духе!', 5, 3),
    ('Сергей Николаев', 'sergey@example.com', 'Интересные гости, хочу участвовать!', 4, 2);


#  Регистрация участников

DELIMITER //
CREATE PROCEDURE AddParticipant(
    IN firstNameParam VARCHAR(255),
    IN lastNameParam VARCHAR(255),
    IN contactEmailParam VARCHAR(255),
    IN participationHistoryParam TEXT
)
BEGIN
    INSERT INTO Participants (firstName, lastName, contactEmail, participationHistory)
    VALUES (firstNameParam, lastNameParam, contactEmailParam, participationHistoryParam);
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_insert_participant
BEFORE INSERT ON Participants
FOR EACH ROW
BEGIN
    SET NEW.participationHistory = CONCAT('Registered on ', NOW());
END;
//
DELIMITER ;

CALL AddParticipant('Иван', 'Иванов', 'vanyz.@example.com', 'Участвует впервые');
SELECT * FROM Participants;


INSERT INTO Participants (firstName, lastName, contactEmail) VALUES
    ('Илья', 'Ильин', 'ilia@example.com'),
    ('J', 'Smith', 'j.smith@example.com');

INSERT INTO Operators (firstName, lastName, contactEmail) VALUES
    ('Александр', 'Иванов', 'alex.ivanov@example.com'),
    ('Екатерина', 'Петрова', 'ekaterina.petrova@example.com'),
    ('Михаил', 'Сидоров', 'mikhail.sidorov@example.com'),
    ('Ольга', 'Козлова', 'olga.kozlova@example.com'),
    ('Денис', 'Смирнов', 'denis.smirnov@example.com');

INSERT INTO Editors (firstName, lastName, contactEmail) VALUES
    ('Татьяна', 'Кузнецова', 'tatyana.kuznetsova@example.com'),
    ('Иван', 'Морозов', 'ivan.morozov@example.com'),
    ('Анна', 'Сергеева', 'anna.sergeeva@example.com'),
    ('Сергей', 'Павлов', 'sergey.pavlov@example.com'),
    ('Наталья', 'Васнецова', 'natalia.vasnetsova@example.com');

INSERT INTO NumberOfRelease (releaseNumber, shootingDate, operatorId, editorId) VALUES
    (1, '2023-01-15', 1, 1),
    (2, '2023-02-01', 2, 2),
    (3, '2023-03-10', 3, 3),
    (4, '2023-04-05', 4, 4),
    (5, '2023-05-20', 5, 5);

INSERT INTO Rounds (roundNumber, releaseId) VALUES
    (1, 1),
    (2, 1),
    (3, 1),
    (1, 2),
    (2, 2);
    
    INSERT INTO Rounds (roundNumber, releaseId) VALUES
    (1,3),
    (2,3),
    (3,2),
    (3,3);

INSERT INTO QuestionTexts (questionText, releaseId) VALUES
    ('Как называется столица Франции?', 1),
    ('Сколько планет в Солнечной системе?', 1),
    ('Кто написал "Преступление и наказание"?', 2),
    ('Какой язык программирования самый популярный?', 3),
    ('Как называется самая высокая гора в мире?', 2);

SELECT * FROM  Rounds;

INSERT INTO Prizes (prizeName, prizeDescription) VALUES
    ('Загадочный приз', 'Таинственный подарок от Якубовича'),
    ('Элегантный кубок', 'Красивый кубок для победителя'),
    ('Путешествие на двоих', 'Поездка в экзотическую страну для победителя шоу'),
    ('Электронная техника', 'Современные гаджеты и техника в награду'),
    ('Денежный приз', 'Немаленькая сумма денег для победителя');

DROP TABLE Answers;
CREATE TABLE Answers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    participantId INT,
    releaseId INT,
    roundId INT,
    questionTextId INT,
    isCorrect BOOLEAN, 
    FOREIGN KEY (participantId) REFERENCES Participants(id),
    FOREIGN KEY (releaseId) REFERENCES NumberOfRelease(id),
    FOREIGN KEY (roundId) REFERENCES Rounds(id),
    FOREIGN KEY (questionTextId) REFERENCES QuestionTexts(id)
);

INSERT INTO Answers (participantId, releaseId, roundId, questionTextId, isCorrect) VALUES
    (1, 1, 6, 1, true),
    (1, 1, 7, 2, false),
    (2, 1, 7, 1, false),
    (2, 1, 6, 2, true),
    (1, 2, 8, 3, true),
    (2, 2, 8, 3, false),
    (2, 2, 9, 4, true);


DROP PROCEDURE CalculateAndDeclareWinners;
DELIMITER //
CREATE PROCEDURE CalculateAndDeclareWinners(IN releaseIdParam INT)
BEGIN
    DECLARE participantIdVar INT;
    DECLARE scoreVar INT;

    DROP TEMPORARY TABLE IF EXISTS TempScores;
    CREATE TEMPORARY TABLE TempScores (
        participantId INT,
        score INT
    );

    INSERT INTO TempScores (participantId, score)
    SELECT a.participantId, COUNT(a.id) * 10 AS score
    FROM Answers a
    JOIN QuestionTexts q ON a.questionTextId = q.id
    JOIN Rounds r ON a.roundId = r.id
    WHERE a.isCorrect = 1 AND r.releaseId = releaseIdParam
    GROUP BY a.participantId;

    SELECT participantId, score INTO participantIdVar, scoreVar
    FROM TempScores
    ORDER BY score DESC
    LIMIT 1;

    INSERT INTO Winners (participantId, releaseId, prizeId)
    VALUES (participantIdVar, releaseIdParam, NULL); 

    DROP TEMPORARY TABLE IF EXISTS TempScores;
END;
//
DELIMITER ;



INSERT INTO Answers (participantId, questionTextId, isCorrect) VALUES
    (1, 1, 1), 
    (1, 2, 0), 
    (2, 1, 0), 
    (2, 2, 1), 
    (3, 3, 1), 
    (3, 4, 0), 
    (4, 3, 0), 
    (4, 4, 1), 
    (5, 5, 1), 
    (5, 6, 0); 


CALL CalculateAndDeclareWinners(1);

SELECT * FROM Winners;

DROP PROCEDURE GenerateShowStatistics;
DELIMITER //
CREATE PROCEDURE GenerateShowStatistics()
BEGIN
    DECLARE totalParticipants INT;
     DECLARE totalReleases INT;
     DECLARE averageRating DECIMAL(3,2);
      DECLARE totalPrizes INT;
     
    SELECT COUNT(*) INTO totalParticipants FROM Participants;
    SELECT COUNT(*) INTO totalReleases FROM NumberOfRelease;
    SELECT FORMAT(AVG(showRating), 2) INTO averageRating FROM Ratings;
    SELECT COUNT(*) INTO totalPrizes FROM Prizes;

    SELECT
        'Общее количество участников: ' AS Metric,
        totalParticipants AS Value
    UNION
    SELECT
        'Общее количество выпусков: ',
        totalReleases
    UNION
    SELECT
        'Средний рейтинг шоу: ',
        averageRating
    UNION
    SELECT
        'Общее количество призов: ',
        totalPrizes;
END;
//
DELIMITER ;

INSERT INTO Ratings (releaseId, showRating) VALUES
    (1, 4.5),
    (2, 3.8),
    (3, 4.2),
    (4, 4.7),
    (5, 3.5);
    

CALL GenerateShowStatistics();

DELIMITER //

CREATE EVENT WeeklyShowReport
ON SCHEDULE EVERY 1 WEEK
DO
BEGIN
    CALL GenerateShowStatistics();
END;

//
DELIMITER ;

CREATE TABLE ScheduledReleases (
    id INT PRIMARY KEY AUTO_INCREMENT,
    releaseNumber INT,
    shootingDate DATE,
    operatorId INT,
    editorId INT,
    FOREIGN KEY (operatorId) REFERENCES Operators(id),
    FOREIGN KEY (editorId) REFERENCES Editors(id)
);

DELETE FROM ScheduledReleases;
INSERT INTO ScheduledReleases (releaseNumber, shootingDate, operatorId, editorId) VALUES
    (8, '2024-01-10', 1, 2),
    (9, '2024-01-17', 2, 3),
    (10, '2024-01-24', 3, 1),
    (11, '2024-01-31', 1, 2),
    (12, '2024-02-07', 2, 3),
    (13, '2024-02-14', 3, 1),
    (14, '2024-02-21', 1, 2);

DELIMITER //
CREATE TRIGGER CheckAndDeleteScheduledRelease
AFTER INSERT ON NumberOfRelease
FOR EACH ROW
BEGIN
    DECLARE scheduledReleaseId INT;

    SELECT id INTO scheduledReleaseId
    FROM ScheduledReleases
    WHERE shootingDate = NEW.shootingDate;

    IF scheduledReleaseId IS NOT NULL THEN
        DELETE FROM ScheduledReleases WHERE id = scheduledReleaseId;
    END IF;
END;
//
DELIMITER ;

DROP EVENT DailyReminder;
DELIMITER //

CREATE EVENT DailyReminder
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    DECLARE nearestShootingDate DATE;
    DECLARE operatorIdParam INT;
    DECLARE editorIdParam INT;

    SELECT shootingDate, operatorId, editorId INTO nearestShootingDate, operatorIdParam, editorIdParam
    FROM ScheduledReleases
    WHERE shootingDate >= CURDATE()
    ORDER BY shootingDate ASC
    LIMIT 1;

    IF nearestShootingDate IS NOT NULL THEN
        CALL SendReminder(operatorIdParam, editorIdParam, nearestShootingDate);
    END IF;
END;

//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE SendReminder(IN operatorIdParam INT, IN editorIdParam INT, IN shootingDateParam DATE)
BEGIN
    DECLARE operatorName VARCHAR(255);
    DECLARE editorName VARCHAR(255);

    SELECT firstName INTO operatorName
    FROM Operators
    WHERE id = operatorIdParam;

    SELECT firstName INTO editorName
    FROM Editors
    WHERE id = editorIdParam;

    SET @reminderText = CONCAT('Дорогие ', operatorName, ' и ', editorName, ', уже ', shootingDateParam, ' у нас съемка нового выпуска!');

    SELECT @reminderText AS reminder;
END;

//
DELIMITER ;

CALL SendReminder(1, 1, '2024-01-10');

DROP VIEW CurrentAndScheduledReleases;
CREATE VIEW CurrentAndScheduledReleases AS
SELECT
    'Current' AS ReleaseType,
    nr.id AS ReleaseId,
    nr.releaseNumber,
    nr.shootingDate,
    o.firstName AS OperatorFirstName,
    o.lastName AS OperatorLastName,
    e.firstName AS EditorFirstName,
    e.lastName AS EditorLastName
FROM
    NumberOfRelease nr
    JOIN Operators o ON nr.operatorId = o.id
    JOIN Editors e ON nr.editorId = e.id
WHERE
    nr.shootingDate <= CURDATE()
UNION
SELECT
    'Scheduled' AS ReleaseType,
    sr.id AS ReleaseId,
    sr.releaseNumber,
    sr.shootingDate,
    o.firstName AS OperatorFirstName,
    o.lastName AS OperatorLastName,
    e.firstName AS EditorFirstName,
    e.lastName AS EditorLastName
FROM
    ScheduledReleases sr
    JOIN Operators o ON sr.operatorId = o.id
    JOIN Editors e ON sr.editorId = e.id
WHERE sr.shootingDate > CURDATE()
ORDER BY shootingDate;

SELECT * FROM CurrentAndScheduledReleases;

DROP VIEW PlayerResults;
CREATE VIEW PlayerResults AS
SELECT
    p.id AS ParticipantId,
    p.firstName AS ParticipantFirstName,
    p.lastName AS ParticipantLastName,
    COUNT(qt.id) AS TotalRoundsPlayed,
    SUM(a.isCorrect) AS TotalCorrectAnswers,
    COUNT(DISTINCT nr.id) AS TotalEpisodesParticipated,
    w.prizeId AS LastWonPrizeId,
    pz.prizeName AS LastWonPrizeName,
    pz.prizeDescription AS LastWonPrizeDescription
FROM
    Participants p
    LEFT JOIN QuestionTexts qt ON p.id = qt.releaseId  
    LEFT JOIN NumberOfRelease nr ON qt.releaseId = nr.id
    LEFT JOIN Answers a ON p.id = a.participantId AND qt.id = a.questionTextId
    LEFT JOIN Winners w ON p.id = w.participantId
    LEFT JOIN Prizes pz ON w.prizeId = pz.id
GROUP BY
    p.id
ORDER BY
    ParticipantId;


SELECT * FROM PlayerResults;

DROP TRIGGER after_insert_winner;

DELIMITER //
CREATE TRIGGER after_insert_winner_prize
AFTER INSERT ON Winners
FOR EACH ROW
BEGIN
    DECLARE participantHistoryText VARCHAR(255);

    DECLARE prizeDescriptionText VARCHAR(255);
    SELECT prizeDescription INTO prizeDescriptionText FROM Prizes WHERE id = NEW.prizeId;

    SET participantHistoryText = CONCAT('Winner of "', prizeDescriptionText, '" in release ', NEW.releaseId, ' - ', NOW());

    UPDATE Participants
    SET participationHistory = CONCAT(participationHistory, '\n', participantHistoryText)
    WHERE id = NEW.participantId;
END;
//
DELIMITER ;


INSERT INTO Winners (participantId, prizeId, releaseId) VALUES
    (1, 1, 1),
    (2, 2, 1),
    (3, 1, 2);

SELECT * FROM Participants;

CREATE USER 'participant_user'@'localhost' IDENTIFIED BY 'password1';
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'password2';

GRANT SELECT ON FoM_db.CurrentAndScheduledReleases TO 'participant_user'@'localhost';
GRANT SELECT ON FoM_db.PlayerResults TO 'participant_user'@'localhost';
GRANT ALL PRIVILEGES ON FoM_db.* TO 'admin_user'@'localhost';

# mysqlslap --create-schema=FoM_db -u root -p MyParol9460! --query="C:\Users\asus\Desktop\БД\Lb6.sql"

SELECT @@GLOBAL.general_log;
SET GLOBAL general_log = 1;
SET GLOBAL log_output = 'TABLE';
SELECT * FROM mysql.general_log;


EXPLAIN SELECT *
FROM Participants
WHERE YEAR(lastName) = 'Иванов';

INSERT INTO Participants (firstName, lastName, contactEmail)
VALUES
  ('Иван', 'Иванов', 'ivan@example.com'),
  ('Мария', 'Петрова', 'maria@example.com'),
  ('Александр', 'Сидоров', 'alex@example.com'),
  ('Екатерина', 'Козлова', 'ekaterina@example.com'),
  ('Дмитрий', 'Смирнов', 'dmitriy@example.com'),
  ('Анна', 'Ильина', 'anna@example.com'),
  ('Сергей', 'Павлов', 'sergey@example.com'),
  ('Ольга', 'Морозова', 'olga@example.com'),
  ('Павел', 'Федоров', 'pavel@example.com'),
  ('Анастасия', 'Лебедева', 'anastasia@example.com');
  
  CREATE INDEX idx_participants_firstName ON Participants (firstName);
  
EXPLAIN SELECT *
FROM Participants
WHERE firstName = 'Иван';


SHOW TABLE STATUS LIKE 'Participants';

CREATE TABLE Participants_InnoDB (
    id INT PRIMARY KEY AUTO_INCREMENT,
    firstName VARCHAR(255),
    lastName VARCHAR(255),
    contactEmail VARCHAR(255),
    participationHistory TEXT
) ENGINE=InnoDB;


CREATE TABLE Participants_MyISAM (
    id INT PRIMARY KEY AUTO_INCREMENT,
    firstName VARCHAR(255),
    lastName VARCHAR(255),
    contactEmail VARCHAR(255),
    participationHistory TEXT
) ENGINE=MyISAM;


INSERT INTO Participants_InnoDB (firstName, lastName, contactEmail) VALUES
  ('Иван', 'Иванов', 'ivan@example.com'),
  ('Мария', 'Петрова', 'maria@example.com'),
  ('Александр', 'Сидоров', 'alexander@example.com'),
  ('Елена', 'Козлова', 'elena@example.com'),
  ('Сергей', 'Николаев', 'sergei@example.com'),
  ('Анна', 'Игнатьева', 'anna@example.com'),
  ('Дмитрий', 'Смирнов', 'dmitry@example.com'),
  ('Ольга', 'Кузнецова', 'olga@example.com'),
  ('Павел', 'Федоров', 'pavel@example.com'),
  ('Наталья', 'Морозова', 'natalia@example.com');

INSERT INTO Participants_MyISAM (firstName, lastName, contactEmail) VALUES
  ('Иван', 'Иванов', 'ivan@example.com'),
  ('Мария', 'Петрова', 'maria@example.com'),
  ('Александр', 'Сидоров', 'alexander@example.com'),
  ('Елена', 'Козлова', 'elena@example.com'),
  ('Сергей', 'Николаев', 'sergei@example.com'),
  ('Анна', 'Игнатьева', 'anna@example.com'),
  ('Дмитрий', 'Смирнов', 'dmitry@example.com'),
  ('Ольга', 'Кузнецова', 'olga@example.com'),
  ('Павел', 'Федоров', 'pavel@example.com'),
  ('Наталья', 'Морозова', 'natalia@example.com');

EXPLAIN SELECT * FROM Participants_InnoDB WHERE firstName = 'Наталья';
EXPLAIN SELECT * FROM Participants_MyISAM WHERE firstName = 'Наталья';

SHOW INDEX FROM Participants_InnoDB;

SHOW INDEX FROM Participants_MyISAM;

  CREATE INDEX idx_participants_firstName ON Participants_InnoDB (firstName);
    CREATE INDEX idx_participants_firstName ON Participants_MyISAM (firstName);
    
SET profiling = 1;
SELECT * FROM Participants_InnoDB WHERE firstName = 'Наталья';
SELECT * FROM Participants_MyISAM WHERE firstName = 'Наталья';
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;

