def remove_dormant(cur):
    cur.execute(
        """
        DELETE FROM IssuedBooks
        WHERE student_id IN (
            SELECT s.student_id
            FROM Students s
            LEFT JOIN IssuedBooks ib ON s.student_id = ib.student_id
            GROUP BY s.student_id
            HAVING MAX(ib.issue_date) < CURRENT_DATE - INTERVAL '3 years'
                OR MAX(ib.issue_date) IS NULL
        )
        AND student_id NOT IN (
            SELECT DISTINCT student_id
            FROM IssuedBooks
            WHERE return_date IS NULL
        )
        """
    )
    removed_issues = cur.rowcount
    cur.execute(
        """
        DELETE FROM Students
        WHERE student_id NOT IN (
            SELECT DISTINCT student_id FROM IssuedBooks
        )
        AND student_id NOT IN (
            SELECT DISTINCT student_id
            FROM IssuedBooks
            WHERE return_date IS NULL
        )
        AND student_id IN (
            SELECT s.student_id
            FROM Students s
            LEFT JOIN IssuedBooks ib ON s.student_id = ib.student_id
            GROUP BY s.student_id
            HAVING MAX(ib.issue_date) < CURRENT_DATE - INTERVAL '3 years'
                OR MAX(ib.issue_date) IS NULL
        )
        """
    )
    removed_students = cur.rowcount
    return removed_issues, removed_students


def fix_stock(cur):
    cur.execute(
        """
        UPDATE Books b
        SET available_copies = b.total_copies - (
            SELECT COUNT(*)
            FROM IssuedBooks ib
            WHERE ib.book_id = b.book_id
              AND ib.return_date IS NULL
        )
        """
    )
    return cur.rowcount
