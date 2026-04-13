def lend_item(cur, eid, iid, pid):
    cur.execute(
        """
        INSERT INTO IssuedBooks (issue_id, book_id, student_id, issue_date)
        VALUES (%s, %s, %s, CURRENT_DATE)
        """,
        (eid, iid, pid),
    )
    cur.execute(
        """
        UPDATE Books
        SET available_copies = available_copies - 1
        WHERE book_id = %s AND available_copies > 0
        """,
        (iid,),
    )
    affected = cur.rowcount
    if affected == 0:
        raise ValueError(f"No available copies for book {iid}; transaction rolled back")
    return affected


def recover_item(cur, eid):
    cur.execute(
        """
        UPDATE IssuedBooks
        SET return_date = CURRENT_DATE
        WHERE issue_id = %s AND return_date IS NULL
        """,
        (eid,),
    )
    touched = cur.rowcount
    if touched == 0:
        return 0
    cur.execute(
        """
        UPDATE Books
        SET available_copies = available_copies + 1
        WHERE book_id = (
            SELECT book_id FROM IssuedBooks WHERE issue_id = %s
        )
        """,
        (eid,),
    )
    return touched
