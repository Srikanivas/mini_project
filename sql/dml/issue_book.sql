-- Issue a Book Operation
--
-- Parameters (psql \set variables — substitute before running):
--   :new_issue_id   INT   — unique ID for the new IssuedBooks record   ($1)
--   :book_id        INT   — ID of the book to issue                    ($2)
--   :student_id     INT   — ID of the student borrowing the book       ($3)
--
-- Behaviour:
--   1. INSERT a new row into IssuedBooks (issue_date = CURRENT_DATE).
--   2. UPDATE Books.available_copies = available_copies - 1
--      WHERE book_id = :book_id AND available_copies > 0.
--   3. If the UPDATE affects 0 rows (available_copies was already 0),
--      ROLLBACK the entire transaction so neither change persists.
--
-- Requirements: 7.1–7.6

BEGIN;

DO $$
DECLARE
    v_new_issue_id  INT := current_setting('app.new_issue_id')::INT;  -- $1 :new_issue_id
    v_book_id       INT := current_setting('app.book_id')::INT;       -- $2 :book_id
    v_student_id    INT := current_setting('app.student_id')::INT;    -- $3 :student_id
    v_rows          INT;
BEGIN
    -- Step 1: Record the borrowing event
    INSERT INTO IssuedBooks (issue_id, book_id, student_id, issue_date)
    VALUES (v_new_issue_id, v_book_id, v_student_id, CURRENT_DATE);

    -- Step 2: Decrement available copies only when the book is available.
    -- The AND available_copies > 0 guard prevents going below zero.
    UPDATE Books
       SET available_copies = available_copies - 1
     WHERE book_id          = v_book_id   -- :book_id
       AND available_copies > 0;

    -- Step 3: If 0 rows were updated the book was unavailable; roll back both steps.
    GET DIAGNOSTICS v_rows = ROW_COUNT;
    IF v_rows = 0 THEN
        RAISE EXCEPTION
            'Book unavailable: available_copies is 0 for book_id %. Transaction rolled back.',
            v_book_id;
    END IF;
END;
$$;

COMMIT;
