-- Active Issues Query
-- Lists all currently issued books (not yet returned) with student and book details.
-- Requirements: 12.1–12.3

SELECT
    s.student_id,
    s.name,
    b.title,
    b.category,
    ib.issue_date,
    (CURRENT_DATE - ib.issue_date) AS days_held
FROM IssuedBooks ib
JOIN Students s ON ib.student_id = s.student_id
JOIN Books    b ON ib.book_id    = b.book_id
WHERE ib.return_date IS NULL
ORDER BY s.name ASC, ib.issue_date ASC;
