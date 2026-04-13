-- Delete Inactive Students Operation
--
-- Behaviour:
--   Removes students who have had no borrowing activity in the past 3 years
--   (or who have never borrowed a book), along with their historical IssuedBooks
--   records.
--
--   An inactive student is defined as one whose MAX(issue_date) predates
--   CURRENT_DATE - INTERVAL '3 years', or who has no IssuedBooks records at all.
--
--   SAFETY GUARD: A student is NEVER deleted if they have any active (unreturned)
--   IssuedBooks record (return_date IS NULL), regardless of how long ago they
--   last borrowed.
--
--   Step 1: DELETE from IssuedBooks all historical records belonging to inactive
--           students (those who pass the HAVING predicate AND have no active issues).
--   Step 2: DELETE from Students all students who no longer appear in IssuedBooks
--           (i.e. their records were just removed in Step 1, or they never had any).
--
-- Requirements: 9.1–9.4

BEGIN;

-- Step 1: Remove historical IssuedBooks records for inactive students.
-- The subquery identifies inactive students:
--   - Grouped by student_id
--   - HAVING: last issue_date is older than 3 years ago, OR student has no issues at all
--   - EXCLUDING: any student who currently has an unreturned book (return_date IS NULL)
DELETE FROM IssuedBooks
WHERE student_id IN (
    SELECT s.student_id
    FROM Students s
    LEFT JOIN IssuedBooks ib ON s.student_id = ib.student_id
    GROUP BY s.student_id
    HAVING (
        MAX(ib.issue_date) < CURRENT_DATE - INTERVAL '3 years'
        OR MAX(ib.issue_date) IS NULL
    )
    AND s.student_id NOT IN (
        SELECT DISTINCT student_id
        FROM IssuedBooks
        WHERE return_date IS NULL
    )
);

-- Step 2: Remove the inactive student records themselves.
-- After Step 1, any student whose IssuedBooks rows were all deleted will no longer
-- appear in IssuedBooks. Deleting students NOT IN IssuedBooks safely removes exactly
-- those students — and only those students — while preserving any student who still
-- has records (active or otherwise) in IssuedBooks.
DELETE FROM Students
WHERE student_id NOT IN (
    SELECT DISTINCT student_id FROM IssuedBooks
);

COMMIT;
