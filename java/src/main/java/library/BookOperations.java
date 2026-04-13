package library;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class BookOperations {

    public static void lendVolume(Connection conn, int rid, int vid, int mid) throws SQLException {
        conn.setAutoCommit(false);
        try {
            String ins = "INSERT INTO IssuedBooks (issue_id, book_id, student_id, issue_date) " +
                         "VALUES (?, ?, ?, CURRENT_DATE)";
            try (PreparedStatement stmt = conn.prepareStatement(ins)) {
                stmt.setInt(1, rid);
                stmt.setInt(2, vid);
                stmt.setInt(3, mid);
                stmt.executeUpdate();
            }

            String upd = "UPDATE Books SET available_copies = available_copies - 1 " +
                         "WHERE book_id = ? AND available_copies > 0";
            int rows;
            try (PreparedStatement stmt = conn.prepareStatement(upd)) {
                stmt.setInt(1, vid);
                rows = stmt.executeUpdate();
            }

            if (rows == 0) {
                conn.rollback();
                System.out.println("Lend failed: no copies available for book_id=" + vid + ". Rolled back.");
            } else {
                conn.commit();
                System.out.println("Lend successful: issue_id=" + rid);
            }
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }

    public static void recoverVolume(Connection conn, int recordId) throws SQLException {
        conn.setAutoCommit(false);
        try {
            String updIssue = "UPDATE IssuedBooks SET return_date = CURRENT_DATE " +
                              "WHERE issue_id = ? AND return_date IS NULL";
            int rows;
            try (PreparedStatement stmt = conn.prepareStatement(updIssue)) {
                stmt.setInt(1, recordId);
                rows = stmt.executeUpdate();
            }

            if (rows == 0) {
                conn.rollback();
                System.out.println("Return skipped: issue_id=" + recordId + " already returned or not found.");
                return;
            }

            String updBook = "UPDATE Books SET available_copies = available_copies + 1 " +
                             "WHERE book_id = (SELECT book_id FROM IssuedBooks WHERE issue_id = ?)";
            try (PreparedStatement stmt = conn.prepareStatement(updBook)) {
                stmt.setInt(1, recordId);
                stmt.executeUpdate();
            }

            conn.commit();
            System.out.println("Return successful: issue_id=" + recordId);
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }

    public static void syncCopyCounts(Connection conn) throws SQLException {
        String sql = "UPDATE Books b SET available_copies = b.total_copies - (" +
                     "SELECT COUNT(*) FROM IssuedBooks ib " +
                     "WHERE ib.book_id = b.book_id AND ib.return_date IS NULL)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            int rows = stmt.executeUpdate();
            System.out.println("Reconciled available_copies for " + rows + " book(s).");
        }
    }
}
