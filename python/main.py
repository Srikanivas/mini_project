import sys
from tabulate import tabulate
import db
import circulation
import analytics
import maintenance


def print_table(rows, headers):
    if not rows:
        print("  (no rows)\n")
        return
    print(tabulate(rows, headers=headers, tablefmt="psql"))
    print()


def do_overdue(cur):
    rows = analytics.overdue_report(cur)
    print_table(rows, ["issue_id", "student_id", "name", "email", "book_id", "title", "category", "issue_date", "days_overdue"])


def do_genre_stats(cur):
    rows = analytics.genre_stats(cur)
    print_table(rows, ["category", "total_borrows", "unique_books"])


def do_dormant(cur):
    rows = analytics.dormant_members(cur)
    print_table(rows, ["student_id", "name", "email", "enrolled_date", "last_activity"])


def do_active_loans(cur):
    rows = analytics.active_loans(cur)
    print_table(rows, ["student_id", "name", "title", "category", "issue_date", "days_held"])


def do_lend(conn, cur):
    try:
        eid = int(input("  New issue_id : "))
        iid = int(input("  book_id      : "))
        pid = int(input("  student_id   : "))
    except ValueError:
        print("  Invalid input.\n")
        return
    try:
        circulation.lend_item(cur, eid, iid, pid)
        conn.commit()
        print("  Book issued successfully.\n")
    except Exception as exc:
        conn.rollback()
        print(f"  Failed: {exc}\n")


def do_recover(conn, cur):
    try:
        eid = int(input("  issue_id to return: "))
    except ValueError:
        print("  Invalid input.\n")
        return
    try:
        touched = circulation.recover_item(cur, eid)
        conn.commit()
        if touched:
            print("  Book returned successfully.\n")
        else:
            print("  Already returned or not found (no change).\n")
    except Exception as exc:
        conn.rollback()
        print(f"  Failed: {exc}\n")


def do_remove_dormant(conn, cur):
    confirm = input("  This will delete dormant students. Confirm? [y/N]: ").strip().lower()
    if confirm != "y":
        print("  Aborted.\n")
        return
    try:
        ri, rs = maintenance.remove_dormant(cur)
        conn.commit()
        print(f"  Removed {ri} issue record(s) and {rs} student record(s).\n")
    except Exception as exc:
        conn.rollback()
        print(f"  Failed: {exc}\n")


def do_fix_stock(conn, cur):
    try:
        n = maintenance.fix_stock(cur)
        conn.commit()
        print(f"  Reconciled available_copies for {n} book(s).\n")
    except Exception as exc:
        conn.rollback()
        print(f"  Failed: {exc}\n")


MENU = """
=== Digital Library Audit System ===
  1. Overdue report
  2. Genre / category stats
  3. Dormant members
  4. Active loans
  5. Lend a book
  6. Return a book
  7. Remove dormant members
  8. Fix stock (reconcile available_copies)
  0. Exit
"""


def main():
    try:
        conn = db.open_connection()
    except Exception as exc:
        print(f"Connection failed: {exc}")
        sys.exit(1)

    conn.autocommit = False
    cur = conn.cursor()

    while True:
        print(MENU)
        choice = input("Select option: ").strip()

        if choice == "1":
            do_overdue(cur)
        elif choice == "2":
            do_genre_stats(cur)
        elif choice == "3":
            do_dormant(cur)
        elif choice == "4":
            do_active_loans(cur)
        elif choice == "5":
            do_lend(conn, cur)
        elif choice == "6":
            do_recover(conn, cur)
        elif choice == "7":
            do_remove_dormant(conn, cur)
        elif choice == "8":
            do_fix_stock(conn, cur)
        elif choice == "0":
            break
        else:
            print("  Unknown option.\n")

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
