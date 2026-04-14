-- Return a Book Operation
--
-- Parameters (psql \set variables — substitute before running):
--   :issue_id   INT   — ID of the IssuedBooks record to mark as returned   ($1)
--
-- Behaviour:
--   1. UPDATE IssuedBooks SET return_date = CURRENT_DATE
--      WHERE issue_id = :issue_id AND return_date IS NULL.
--   2. If Step 1 affects 0 rows (book already returned or issue_id not found),
--      skip Step 2 — leave Books.available_copies unchanged.
--   3. UPDATE Books SET available_copies = available_copies + 1
--      WHERE book_id = (SELECT book_id FROM IssuedBooks WHERE issue_id = :issue_id).
--   4. Both updates are wrapped in a single transaction so either both succeed
--      or neither takes effect.
--
-- Requirements: 8.1–8.4

BEGIN;

DO $$
DECLARE
    v_issue_id  INT := current_setting('app.issue_id')::INT;  -- $1 :issue_id
    v_rows      INT;
BEGIN
    -- Step 1: Mark the book as returned, but only if it hasn't been returned yet.
    -- The AND return_date IS NULL guard ensures idempotence (Req 8.3).
    UPDATE IssuedBooks
       SET return_date = CURRENT_DATE
     WHERE issue_id    = v_issue_id   -- :issue_id
       AND return_date IS NULL;

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    -- Step 2: Only increment available_copies when Step 1 actually updated a row.
    -- If 0 rows were affected the book was already returned; leave copies unchanged.
    IF v_rows > 0 THEN
        UPDATE Books
           SET available_copies = available_copies + 1
         WHERE book_id = (
             SELECT book_id
               FROM IssuedBooks
              WHERE issue_id = v_issue_id  -- :issue_id
         );
    END IF;
END;
$$;

COMMIT;
