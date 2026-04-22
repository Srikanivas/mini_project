CREATE DATABASE IF NOT EXISTS collage_lib;
USE collage_lib;

CREATE TABLE studs (
    stud_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    roll_no VARCHAR(20),
    dept VARCHAR(50),
    join_dt DATE
);

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    book_title VARCHAR(200),
    categry VARCHAR(50),
    author VARCHAR(100),
    stock INT DEFAULT 3
);

CREATE TABLE issued_books (
    issue_id INT PRIMARY KEY,
    stud_id INT,
    book_id INT,
    issue_dt DATE,
    return_dt DATE,
    FOREIGN KEY (stud_id) REFERENCES studs(stud_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

CREATE TABLE penality (
    pen_id INT AUTO_INCREMENT PRIMARY KEY,
    stud_id INT,
    issue_id INT,
    fine_amt DECIMAL(6,2),
    pen_dt DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (stud_id) REFERENCES studs(stud_id),
    FOREIGN KEY (issue_id) REFERENCES issued_books(issue_id)
);

CREATE TABLE actvity_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    actn VARCHAR(50),
    stud_id INT,
    book_id INT,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO studs VALUES
(1,'Ravi Kumar','22881A0501','CSE','2020-01-10'),
(2,'Priya Sharma','22881A0562','ECE','2019-05-22'),
(3,'Arjun Reddy','21881A7234','IT','2022-03-15'),
(4,'Sneha Patel','21881A0589','CSE','2021-07-01'),
(5,'Kiran Babu','20881A7262','MECH','2018-11-30');

INSERT INTO books VALUES
(1,'Database Management Systems','DBMS','Ramakrishnan',4),
(2,'Object Oriented Programming','OOPS','Balagurusamy',5),
(3,'Core Java Programming','Java','Herbert Schildt',3),
(4,'Data Structures and Algorithms','DSA','Narasimha Karumanchi',4),
(5,'Computer Networks','Networks','Tanenbaum',2),
(6,'Operating System Concepts','OS','Galvin',3),
(7,'Software Engineering','SE','Pressman',2),
(8,'C Programming Language','C','Dennis Ritchie',5),
(9,'Python Programming','Python','Guido',3),
(10,'Discrete Mathematics','Maths','Tremblay',2);

INSERT INTO issued_books VALUES
(1,1,1,'2026-03-25',NULL),
(2,2,3,'2026-03-20',NULL),
(3,3,4,'2026-04-10','2026-04-12'),
(4,4,2,'2026-03-01',NULL),
(5,1,6,'2026-04-13',NULL),
(6,5,5,'2022-01-01','2022-01-10');

DELIMITER $

CREATE TRIGGER after_issue
AFTER INSERT ON issued_books
FOR EACH ROW
BEGIN
    UPDATE books SET stock = stock - 1 WHERE book_id = NEW.book_id;
    INSERT INTO actvity_log(actn, stud_id, book_id) VALUES ('ISSUED', NEW.stud_id, NEW.book_id);
END$

CREATE TRIGGER after_return
AFTER UPDATE ON issued_books
FOR EACH ROW
BEGIN
    IF NEW.return_dt IS NOT NULL AND OLD.return_dt IS NULL THEN
        UPDATE books SET stock = stock + 1 WHERE book_id = NEW.book_id;
        INSERT INTO actvity_log(actn, stud_id, book_id) VALUES ('RETURNED', NEW.stud_id, NEW.book_id);
        IF DATEDIFF(NEW.return_dt, NEW.issue_dt) > 14 THEN
            INSERT INTO penality(stud_id, issue_id, fine_amt)
            VALUES (NEW.stud_id, NEW.issue_id, (DATEDIFF(NEW.return_dt, NEW.issue_dt) - 14) * 0.50);
        END IF;
    END IF;
END$

CREATE PROCEDURE mark_return(IN p_id INT, IN p_dt DATE)
BEGIN
    UPDATE issued_books SET return_dt = p_dt WHERE issue_id = p_id;
END$

CREATE FUNCTION get_fine(p_id INT) RETURNS DECIMAL(6,2)
DETERMINISTIC
BEGIN
    DECLARE dayz INT;
    SELECT DATEDIFF(COALESCE(return_dt, CURDATE()), issue_dt) INTO dayz
    FROM issued_books WHERE issue_id = p_id;
    RETURN GREATEST(0, (dayz - 14) * 0.50);
END$

DELIMITER ;

CREATE VIEW overdue_list AS
SELECT studs.stud_id, studs.full_name, books.book_title, issued_books.issue_dt,
       DATEDIFF(CURDATE(), issued_books.issue_dt) AS days_out,
       (DATEDIFF(CURDATE(), issued_books.issue_dt) - 14) * 0.50 AS fine
FROM issued_books
JOIN studs ON issued_books.stud_id = studs.stud_id
JOIN books ON issued_books.book_id = books.book_id
WHERE issued_books.return_dt IS NULL
AND DATEDIFF(CURDATE(), issued_books.issue_dt) > 14;

CREATE VIEW popular_category AS
SELECT books.categry, COUNT(*) AS total_borrows
FROM issued_books
JOIN books ON issued_books.book_id = books.book_id
GROUP BY books.categry
ORDER BY total_borrows DESC;

SELECT studs.full_name, books.book_title, issued_books.issue_dt,
       DATEDIFF(CURDATE(), issued_books.issue_dt) AS days_out
FROM issued_books
INNER JOIN studs ON issued_books.stud_id = studs.stud_id
INNER JOIN books ON issued_books.book_id = books.book_id
WHERE issued_books.return_dt IS NULL
AND DATEDIFF(CURDATE(), issued_books.issue_dt) > 14;

SELECT studs.full_name, COUNT(issued_books.issue_id) AS total
FROM studs
LEFT JOIN issued_books ON studs.stud_id = issued_books.stud_id
GROUP BY studs.full_name
ORDER BY total DESC;

SELECT books.book_title, books.categry, COUNT(issued_books.issue_id) AS times_taken
FROM issued_books
RIGHT JOIN books ON issued_books.book_id = books.book_id
GROUP BY books.book_id, books.book_title, books.categry;

SELECT a.full_name, b.full_name, YEAR(a.join_dt) AS yr
FROM studs a
JOIN studs b ON YEAR(a.join_dt) = YEAR(b.join_dt) AND a.stud_id < b.stud_id;

SELECT full_name FROM studs
WHERE stud_id IN (
    SELECT stud_id FROM issued_books
    GROUP BY stud_id
    HAVING COUNT(*) > (SELECT AVG(cnt) FROM (SELECT COUNT(*) cnt FROM issued_books GROUP BY stud_id) tmp)
);

SELECT studs.full_name, books.book_title, issued_books.issue_dt
FROM issued_books
JOIN studs ON issued_books.stud_id = studs.stud_id
JOIN books ON issued_books.book_id = books.book_id
WHERE issued_books.issue_dt = (
    SELECT MAX(x.issue_dt) FROM issued_books x WHERE x.stud_id = issued_books.stud_id
);

SELECT studs.full_name, books.book_title,
       CASE
           WHEN issued_books.return_dt IS NOT NULL THEN 'Returned'
           WHEN DATEDIFF(CURDATE(), issued_books.issue_dt) > 14 THEN 'Overdue'
           ELSE 'Active'
       END AS loan_status
FROM issued_books
JOIN studs ON issued_books.stud_id = studs.stud_id
JOIN books ON issued_books.book_id = books.book_id;

WITH overdue AS (
    SELECT issued_books.issue_id, studs.full_name, books.book_title,
           DATEDIFF(CURDATE(), issued_books.issue_dt) AS dayz
    FROM issued_books
    JOIN studs ON issued_books.stud_id = studs.stud_id
    JOIN books ON issued_books.book_id = books.book_id
    WHERE issued_books.return_dt IS NULL
)
SELECT full_name, book_title, dayz, (dayz - 14) * 0.50 AS fine
FROM overdue WHERE dayz > 14;

SELECT full_name FROM studs
WHERE NOT EXISTS (
    SELECT 1 FROM issued_books WHERE issued_books.stud_id = studs.stud_id
);

SELECT full_name FROM studs
WHERE EXISTS (
    SELECT 1 FROM issued_books WHERE issued_books.stud_id = studs.stud_id AND return_dt IS NULL
);

SELECT books.categry, COUNT(*) AS borrows,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS prcnt
FROM issued_books
JOIN books ON issued_books.book_id = books.book_id
GROUP BY books.categry
ORDER BY borrows DESC;

SELECT books.categry, COUNT(*) AS n
FROM issued_books JOIN books ON issued_books.book_id = books.book_id
GROUP BY books.categry
HAVING COUNT(*) > 1;

SELECT * FROM overdue_list;

SELECT * FROM popular_category;

SELECT get_fine(2) AS fine_amt;

CALL mark_return(1, CURDATE());

SELECT * FROM actvity_log ORDER BY log_time DESC;

UPDATE issued_books SET issue_dt = DATE_SUB(issue_dt, INTERVAL 7 DAY)
WHERE stud_id = (SELECT stud_id FROM studs WHERE full_name = 'Priya Sharma');

SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM issued_books
WHERE stud_id NOT IN (
    SELECT stud_id FROM (
        SELECT stud_id FROM issued_books
        WHERE issue_dt >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
    ) tmp
);

DELETE FROM studs
WHERE stud_id NOT IN (
    SELECT stud_id FROM (
        SELECT stud_id FROM issued_books
        WHERE issue_dt >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
    ) tmp
);

SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;
