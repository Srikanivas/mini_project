-- Category Popularity Report
-- Lists all book categories with their borrow counts.
-- Uses LEFT JOIN to include categories with zero borrows (Req 5.5).

SELECT
    b.category,
    COUNT(ib.issue_id)        AS total_borrows,
    COUNT(DISTINCT b.book_id) AS unique_books_borrowed
FROM Books b
LEFT JOIN IssuedBooks ib ON b.book_id = ib.book_id
GROUP BY b.category
ORDER BY total_borrows DESC;
