SELECT
    ib.issue_id,
    s.student_id,
    s.name          AS student_name,
    s.email         AS student_email,
    b.book_id,
    b.title         AS book_title,
    b.category,
    ib.issue_date,
    (CURRENT_DATE - ib.issue_date) AS days_overdue
FROM IssuedBooks ib
JOIN Books    b ON ib.book_id    = b.book_id
JOIN Students s ON ib.student_id = s.student_id
WHERE ib.return_date IS NULL
  AND ib.issue_date < CURRENT_DATE - INTERVAL '14 days'
ORDER BY days_overdue DESC;
