CREATE DATABASE IF NOT EXISTS collage_lib;
USE collage_lib;

CREATE TABLE studs (
    stud_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    email_id VARCHAR(100),
    join_dt DATE
);

CREATE TABLE boks (
    bok_id INT PRIMARY KEY,
    bok_title VARCHAR(200),
    categry VARCHAR(50),
    auther VARCHAR(100),
    stok INT DEFAULT 3
);

CREATE TABLE isued_boks (
    isue_id INT PRIMARY KEY,
    stud_id INT,
    bok_id INT,
    isue_dt DATE,
    retun_dt DATE,
    FOREIGN KEY (stud_id) REFERENCES studs(stud_id),
    FOREIGN KEY (bok_id) REFERENCES boks(bok_id)
);

CREATE TABLE penality (
    pen_id INT AUTO_INCREMENT PRIMARY KEY,
    stud_id INT,
    isue_id INT,
    fine_amt DECIMAL(6,2),
    pen_dt DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (stud_id) REFERENCES studs(stud_id),
    FOREIGN KEY (isue_id) REFERENCES isued_boks(isue_id)
);

CREATE TABLE actvity_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    actn VARCHAR(50),
    stud_id INT,
    bok_id INT,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO studs VALUES
(1,'Alice Ray','alice@mail.com','2020-01-10'),
(2,'Bob Marsh','bob@mail.com','2019-05-22'),
(3,'Carol Sun','carol@mail.com','2022-03-15'),
(4,'Dan Fox','dan@mail.com','2021-07-01'),
(5,'Eva Lin','eva@mail.com','2018-11-30');

INSERT INTO boks VALUES
(1,'The Great Gatsby','Fiction','F. Scott',3),
(2,'A Brief History','Science','Hawking',2),
(3,'Sapiens','History','Harari',4),
(4,'Dune','Fiction','Herbert',3),
(5,'Cosmos','Science','Sagan',2),
(6,'1984','Fiction','Orwell',5);

INSERT INTO isued_boks VALUES
(1,1,1,'2026-03-25',NULL),
(2,2,3,'2026-03-20',NULL),
(3,3,4,'2026-04-10','2026-04-12'),
(4,4,2,'2026-03-01',NULL),
(5,1,6,'2026-04-13',NULL),
(6,5,5,'2022-01-01','2022-01-10');

DELIMITER $$

CREATE TRIGGER aftr_isue
AFTER INSERT ON isued_boks
FOR EACH ROW
BEGIN
    UPDATE boks SET stok = stok - 1 WHERE bok_id = NEW.bok_id;
    INSERT INTO actvity_log(actn, stud_id, bok_id) VALUES ('ISSUED', NEW.stud_id, NEW.bok_id);
END$$

CREATE TRIGGER aftr_retun
AFTER UPDATE ON isued_boks
FOR EACH ROW
BEGIN
    IF NEW.retun_dt IS NOT NULL AND OLD.retun_dt IS NULL THEN
        UPDATE boks SET stok = stok + 1 WHERE bok_id = NEW.bok_id;
        INSERT INTO actvity_log(actn, stud_id, bok_id) VALUES ('RETURNED', NEW.stud_id, NEW.bok_id);
        IF DATEDIFF(NEW.retun_dt, NEW.isue_dt) > 14 THEN
            INSERT INTO penality(stud_id, isue_id, fine_amt)
            VALUES (NEW.stud_id, NEW.isue_id, (DATEDIFF(NEW.retun_dt, NEW.isue_dt) - 14) * 0.50);
        END IF;
    END IF;
END$$

CREATE PROCEDURE mark_retun(IN p_id INT, IN p_dt DATE)
BEGIN
    UPDATE isued_boks SET retun_dt = p_dt WHERE isue_id = p_id;
END$$

CREATE FUNCTION get_fine(p_id INT) RETURNS DECIMAL(6,2)
DETERMINISTIC
BEGIN
    DECLARE dayz INT;
    SELECT DATEDIFF(COALESCE(retun_dt, CURDATE()), isue_dt) INTO dayz
    FROM isued_boks WHERE isue_id = p_id;
    RETURN GREATEST(0, (dayz - 14) * 0.50);
END$$

DELIMITER ;

CREATE VIEW overdue_list AS
SELECT studs.stud_id, studs.full_name, boks.bok_title, isued_boks.isue_dt,
       DATEDIFF(CURDATE(), isued_boks.isue_dt) AS days_out,
       (DATEDIFF(CURDATE(), isued_boks.isue_dt) - 14) * 0.50 AS fine
FROM isued_boks
JOIN studs ON isued_boks.stud_id = studs.stud_id
JOIN boks ON isued_boks.bok_id = boks.bok_id
WHERE isued_boks.retun_dt IS NULL
AND DATEDIFF(CURDATE(), isued_boks.isue_dt) > 14;

CREATE VIEW popular_categry AS
SELECT boks.categry, COUNT(*) AS total_borrows
FROM isued_boks
JOIN boks ON isued_boks.bok_id = boks.bok_id
GROUP BY boks.categry
ORDER BY total_borrows DESC;

SELECT studs.full_name, boks.bok_title, isued_boks.isue_dt,
       DATEDIFF(CURDATE(), isued_boks.isue_dt) AS days_out
FROM isued_boks
INNER JOIN studs ON isued_boks.stud_id = studs.stud_id
INNER JOIN boks ON isued_boks.bok_id = boks.bok_id
WHERE isued_boks.retun_dt IS NULL
AND DATEDIFF(CURDATE(), isued_boks.isue_dt) > 14;

SELECT studs.full_name, COUNT(isued_boks.isue_id) AS total
FROM studs
LEFT JOIN isued_boks ON studs.stud_id = isued_boks.stud_id
GROUP BY studs.full_name
ORDER BY total DESC;

SELECT boks.bok_title, boks.categry, COUNT(isued_boks.isue_id) AS times_taken
FROM isued_boks
RIGHT JOIN boks ON isued_boks.bok_id = boks.bok_id
GROUP BY boks.bok_id, boks.bok_title, boks.categry;

SELECT a.full_name, b.full_name, YEAR(a.join_dt) AS yr
FROM studs a
JOIN studs b ON YEAR(a.join_dt) = YEAR(b.join_dt) AND a.stud_id < b.stud_id;

SELECT full_name FROM studs
WHERE stud_id IN (
    SELECT stud_id FROM isued_boks
    GROUP BY stud_id
    HAVING COUNT(*) > (SELECT AVG(cnt) FROM (SELECT COUNT(*) cnt FROM isued_boks GROUP BY stud_id) tmp)
);

SELECT studs.full_name, boks.bok_title, isued_boks.isue_dt
FROM isued_boks
JOIN studs ON isued_boks.stud_id = studs.stud_id
JOIN boks ON isued_boks.bok_id = boks.bok_id
WHERE isued_boks.isue_dt = (
    SELECT MAX(x.isue_dt) FROM isued_boks x WHERE x.stud_id = isued_boks.stud_id
);

SELECT studs.full_name, boks.bok_title,
       CASE
           WHEN isued_boks.retun_dt IS NOT NULL THEN 'Returned'
           WHEN DATEDIFF(CURDATE(), isued_boks.isue_dt) > 14 THEN 'Overdue'
           ELSE 'Active'
       END AS loan_status
FROM isued_boks
JOIN studs ON isued_boks.stud_id = studs.stud_id
JOIN boks ON isued_boks.bok_id = boks.bok_id;

SELECT studs.full_name, COUNT(isued_boks.isue_id) AS cnt,
       RANK() OVER (ORDER BY COUNT(isued_boks.isue_id) DESC) AS rnk
FROM isued_boks
JOIN studs ON isued_boks.stud_id = studs.stud_id
GROUP BY studs.full_name;

SELECT boks.categry, boks.bok_title, isued_boks.isue_dt,
       COUNT(*) OVER (PARTITION BY boks.categry ORDER BY isued_boks.isue_dt) AS running_cnt
FROM isued_boks
JOIN boks ON isued_boks.bok_id = boks.bok_id;

WITH overdue AS (
    SELECT isued_boks.isue_id, studs.full_name, boks.bok_title,
           DATEDIFF(CURDATE(), isued_boks.isue_dt) AS dayz
    FROM isued_boks
    JOIN studs ON isued_boks.stud_id = studs.stud_id
    JOIN boks ON isued_boks.bok_id = boks.bok_id
    WHERE isued_boks.retun_dt IS NULL
)
SELECT full_name, bok_title, dayz, (dayz - 14) * 0.50 AS fine
FROM overdue WHERE dayz > 14;

SELECT full_name FROM studs
WHERE NOT EXISTS (
    SELECT 1 FROM isued_boks WHERE isued_boks.stud_id = studs.stud_id
);

SELECT full_name FROM studs
WHERE EXISTS (
    SELECT 1 FROM isued_boks WHERE isued_boks.stud_id = studs.stud_id AND retun_dt IS NULL
);

SELECT boks.categry, COUNT(*) AS borrows,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS prcnt
FROM isued_boks
JOIN boks ON isued_boks.bok_id = boks.bok_id
GROUP BY boks.categry
ORDER BY borrows DESC;

SELECT boks.categry, COUNT(*) AS n
FROM isued_boks JOIN boks ON isued_boks.bok_id = boks.bok_id
GROUP BY boks.categry
HAVING COUNT(*) > 1;

SELECT studs.full_name, 'Overdue' AS flag, CAST(isued_boks.isue_dt AS CHAR) AS dt
FROM isued_boks JOIN studs ON isued_boks.stud_id = studs.stud_id
WHERE isued_boks.retun_dt IS NULL AND DATEDIFF(CURDATE(), isued_boks.isue_dt) > 14
UNION
SELECT studs.full_name, 'Penalty', CAST(penality.pen_dt AS CHAR)
FROM penality JOIN studs ON penality.stud_id = studs.stud_id;

SELECT stud_id FROM isued_boks
JOIN boks ON isued_boks.bok_id = boks.bok_id WHERE boks.categry = 'Fiction'
AND stud_id IN (
    SELECT stud_id FROM isued_boks
    JOIN boks ON isued_boks.bok_id = boks.bok_id WHERE boks.categry = 'Science'
);

SELECT * FROM overdue_list;

SELECT * FROM popular_categry;

SELECT get_fine(2) AS fine_amt;

CALL mark_retun(1, CURDATE());

SELECT * FROM actvity_log ORDER BY log_time DESC;

UPDATE isued_boks SET isue_dt = DATE_SUB(isue_dt, INTERVAL 7 DAY)
WHERE stud_id = (SELECT stud_id FROM studs WHERE full_name = 'Bob Marsh');

SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM isued_boks
WHERE stud_id NOT IN (
    SELECT stud_id FROM (
        SELECT stud_id FROM isued_boks
        WHERE isue_dt >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
    ) tmp
);

DELETE FROM studs
WHERE stud_id NOT IN (
    SELECT stud_id FROM (
        SELECT stud_id FROM isued_boks
        WHERE isue_dt >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
    ) tmp
);

SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;
