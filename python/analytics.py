def overdue_report(cur):
    cur.execute(
        """
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
        ORDER BY days_overdue DESC
        """
    )
    return cur.fetchall()


def genre_stats(cur):
    cur.execute(
        """
        SELECT
            b.category,
            COUNT(ib.issue_id)        AS total_borrows,
            COUNT(DISTINCT b.book_id) AS unique_books_borrowed
        FROM Books b
        LEFT JOIN IssuedBooks ib ON b.book_id = ib.book_id
        GROUP BY b.category
        ORDER BY total_borrows DESC
        """
    )
    return cur.fetchall()


def dormant_members(cur):
    cur.execute(
        """
        SELECT
            s.student_id,
            s.name,
            s.email,
            s.enrolled_date,
            MAX(ib.issue_date) AS last_activity_date
        FROM Students s
        LEFT JOIN IssuedBooks ib ON s.student_id = ib.student_id
        GROUP BY s.student_id, s.name, s.email, s.enrolled_date
        HAVING MAX(ib.issue_date) < CURRENT_DATE - INTERVAL '3 years'
            OR MAX(ib.issue_date) IS NULL
        ORDER BY last_activity_date ASC NULLS FIRST
        """
    )
    return cur.fetchall()


def active_loans(cur):
    cur.execute(
        """
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
        ORDER BY s.name, ib.issue_date
        """
    )
    return cur.fetchall()
