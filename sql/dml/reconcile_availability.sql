-- Bulk Availability Reconciliation
--
-- Recalculates available_copies for every book in a single UPDATE by
-- deriving the correct value from live IssuedBooks data rather than
-- relying on incremental counter updates.
--
-- Formula:
--   available_copies = total_copies - COUNT(active issues)
--
-- An "active issue" is any IssuedBooks row where return_date IS NULL,
-- meaning the copy has not yet been returned.
--
-- This operation is idempotent: running it multiple times produces the
-- same result and can be used to repair drift caused by missed
-- increments/decrements.
--
-- Requirements: 10.1, 10.2

BEGIN;

UPDATE Books b
   SET available_copies = b.total_copies - (
           SELECT COUNT(*)
             FROM IssuedBooks ib
            WHERE ib.book_id     = b.book_id
              AND ib.return_date IS NULL
       );

COMMIT;
