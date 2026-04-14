CREATE TABLE s (
    sid  INT PRIMARY KEY,
    nm   VARCHAR(100),
    em   VARCHAR(100),
    jd   DATE
);

CREATE TABLE b (
    bid  INT PRIMARY KEY,
    tt   VARCHAR(200),
    cat  VARCHAR(50),
    auth VARCHAR(100),
    stk  INT DEFAULT 3
);

CREATE TABLE ib (
    iid  INT PRIMARY KEY,
    sid  INT REFERENCES s(sid),
    bid  INT REFERENCES b(bid),
    isd  DATE,
    rd   DATE
);

CREATE TABLE pen (
    pid   SERIAL PRIMARY KEY,
    sid   INT REFERENCES s(sid),
    iid   INT REFERENCES ib(iid),
    amt   NUMERIC(6,2),
    pd    DATE DEFAULT CURRENT_DATE
);

CREATE TABLE log (
    lid   SERIAL PRIMARY KEY,
    act   VARCHAR(50),
    sid   INT,
    bid   INT,
    ts    TIMESTAMP DEFAULT NOW()
);

CREATE INDEX ix_ib_sid ON ib(sid);
CREATE INDEX ix_ib_bid ON ib(bid);
CREATE INDEX ix_ib_isd ON ib(isd);

INSERT INTO s VALUES
(1,'Alice Ray','alice@mail.com','2020-01-10'),
(2,'Bob Marsh','bob@mail.com','2019-05-22'),
(3,'Carol Sun','carol@mail.com','2022-03-15'),
(4,'Dan Fox','dan@mail.com','2021-07-01'),
(5,'Eva Lin','eva@mail.com','2018-11-30');

INSERT INTO b VALUES
(1,'The Great Gatsby','Fiction','F. Scott',3),
(2,'A Brief History','Science','Hawking',2),
(3,'Sapiens','History','Harari',4),
(4,'Dune','Fiction','Herbert',3),
(5,'Cosmos','Science','Sagan',2),
(6,'1984','Fiction','Orwell',5);

INSERT INTO ib VALUES
(1,1,1,'2026-03-25',NULL),
(2,2,3,'2026-03-20',NULL),
(3,3,4,'2026-04-10','2026-04-12'),
(4,4,2,'2026-03-01',NULL),
(5,1,6,'2026-04-13',NULL),
(6,5,5,'2022-01-01','2022-01-10');

CREATE OR REPLACE FUNCTION fn_fine(p_iid INT) RETURNS NUMERIC AS $$
DECLARE
    d INT;
BEGIN
    SELECT COALESCE(rd, CURRENT_DATE) - isd INTO d FROM ib WHERE iid = p_iid;
    RETURN GREATEST(0, (d - 14) * 0.50);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_dec_stk() RETURNS TRIGGER AS $$
BEGIN
    UPDATE b SET stk = stk - 1 WHERE bid = NEW.bid;
    INSERT INTO log(act, sid, bid) VALUES ('ISSUE', NEW.sid, NEW.bid);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_issue
AFTER INSERT ON ib
FOR EACH ROW EXECUTE FUNCTION fn_dec_stk();

CREATE OR REPLACE FUNCTION fn_inc_stk() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.rd IS NOT NULL AND OLD.rd IS NULL THEN
        UPDATE b SET stk = stk + 1 WHERE bid = NEW.bid;
        INSERT INTO log(act, sid, bid) VALUES ('RETURN', NEW.sid, NEW.bid);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_auto_pen() RETURNS TRIGGER AS $$
DECLARE
    d INT;
BEGIN
    d := NEW.rd - NEW.isd;
    IF d > 14 THEN
        INSERT INTO pen(sid, iid, amt)
        VALUES (NEW.sid, NEW.iid, (d - 14) * 0.50);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pen
AFTER UPDATE ON ib
FOR EACH ROW
WHEN (NEW.rd IS NOT NULL AND OLD.rd IS NULL)
EXECUTE FUNCTION fn_auto_pen();

CREATE TRIGGER trg_return
AFTER UPDATE ON ib
FOR EACH ROW EXECUTE FUNCTION fn_inc_stk();

CREATE VIEW v_pop AS
SELECT b.cat, COUNT(*) AS borrows
FROM ib
JOIN b ON ib.bid = b.bid
GROUP BY b.cat
ORDER BY borrows DESC;

CREATE OR REPLACE PROCEDURE pr_return(p_iid INT, p_rd DATE) AS $$
BEGIN
    UPDATE ib SET rd = p_rd WHERE iid = p_iid;
END;
$$ LANGUAGE plpgsql;

CREATE VIEW v_overdue AS
SELECT s.sid, s.nm, b.tt, ib.isd,
       CURRENT_DATE - ib.isd AS days_out,
       (CURRENT_DATE - ib.isd - 14) * 0.50 AS fine
FROM ib
JOIN s ON ib.sid = s.sid
JOIN b ON ib.bid = b.bid
WHERE ib.rd IS NULL
  AND CURRENT_DATE - ib.isd > 14;

SELECT s.nm, b.tt, ib.isd, CURRENT_DATE - ib.isd AS days_out
FROM ib
INNER JOIN s ON ib.sid = s.sid
INNER JOIN b ON ib.bid = b.bid
WHERE ib.rd IS NULL AND CURRENT_DATE - ib.isd > 14;

SELECT s.nm, COUNT(ib.iid) AS cnt,
       RANK() OVER (ORDER BY COUNT(ib.iid) DESC) AS rnk
FROM ib
JOIN s ON ib.sid = s.sid
GROUP BY s.nm;

SELECT b.cat, COUNT(*) AS n
FROM ib JOIN b ON ib.bid = b.bid
GROUP BY b.cat
HAVING COUNT(*) > 1;

SELECT s.nm, b.tt
FROM s
FULL OUTER JOIN ib ON s.sid = ib.sid
FULL OUTER JOIN b  ON ib.bid = b.bid;

SELECT nm FROM s
WHERE EXISTS (
    SELECT 1 FROM ib WHERE ib.sid = s.sid AND ib.rd IS NULL
);

SELECT b.cat, b.tt, ib.isd,
       COUNT(*) OVER (PARTITION BY b.cat ORDER BY ib.isd) AS running
FROM ib
JOIN b ON ib.bid = b.bid;

SELECT s.nm, b.tt, ib.isd
FROM ib
JOIN s ON ib.sid = s.sid
JOIN b ON ib.bid = b.bid
WHERE ib.isd = (
    SELECT MAX(i2.isd) FROM ib i2 WHERE i2.sid = ib.sid
);

SELECT b.tt, b.cat, COUNT(ib.iid) AS times
FROM ib
RIGHT JOIN b ON ib.bid = b.bid
GROUP BY b.bid, b.tt, b.cat;

SELECT nm FROM s
WHERE sid IN (
    SELECT sid FROM ib
    GROUP BY sid
    HAVING COUNT(*) > (SELECT AVG(c) FROM (SELECT COUNT(*) c FROM ib GROUP BY sid) t)
);

SELECT s.nm, COUNT(ib.iid) AS total
FROM s
LEFT JOIN ib ON s.sid = ib.sid
GROUP BY s.nm
ORDER BY total DESC;

SELECT s.nm, b.tt,
       CASE
           WHEN ib.rd IS NOT NULL THEN 'Returned'
           WHEN CURRENT_DATE - ib.isd > 14 THEN 'Overdue'
           ELSE 'Active'
       END AS status
FROM ib
JOIN s ON ib.sid = s.sid
JOIN b ON ib.bid = b.bid;

SELECT sid FROM ib JOIN b ON ib.bid = b.bid WHERE b.cat = 'Fiction'
INTERSECT
SELECT sid FROM ib JOIN b ON ib.bid = b.bid WHERE b.cat = 'Science';

WITH od AS (
    SELECT ib.iid, s.nm, b.tt, CURRENT_DATE - ib.isd AS d
    FROM ib
    JOIN s ON ib.sid = s.sid
    JOIN b ON ib.bid = b.bid
    WHERE ib.rd IS NULL
)
SELECT nm, tt, d, (d - 14) * 0.50 AS fine
FROM od WHERE d > 14;

SELECT nm FROM s
WHERE NOT EXISTS (
    SELECT 1 FROM ib WHERE ib.sid = s.sid
);

SELECT a.nm AS x, b.nm AS y, EXTRACT(YEAR FROM a.jd) AS yr
FROM s a
JOIN s b ON EXTRACT(YEAR FROM a.jd) = EXTRACT(YEAR FROM b.jd)
         AND a.sid < b.sid;

SELECT b.cat, COUNT(*) AS borrows,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM ib
JOIN b ON ib.bid = b.bid
GROUP BY b.cat
ORDER BY borrows DESC;

SELECT sid FROM ib
EXCEPT
SELECT sid FROM ib WHERE rd IS NOT NULL;

SELECT s.nm, 'Overdue' AS flag, ib.isd::TEXT AS dt
FROM ib JOIN s ON ib.sid = s.sid
WHERE ib.rd IS NULL AND CURRENT_DATE - ib.isd > 14
UNION
SELECT s.nm, 'Penalty', pen.pd::TEXT
FROM pen JOIN s ON pen.sid = s.sid;

UPDATE ib SET isd = isd - 7
WHERE sid = (SELECT sid FROM s WHERE nm = 'Bob Marsh');

SELECT * FROM v_overdue;

CALL pr_return(1, CURRENT_DATE);

SELECT fn_fine(2) AS fine_amt;

SELECT * FROM v_pop;

SELECT * FROM log ORDER BY ts DESC;

DELETE FROM s
WHERE sid NOT IN (
    SELECT DISTINCT sid FROM ib
    WHERE isd >= CURRENT_DATE - INTERVAL '3 years'
);
