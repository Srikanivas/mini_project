package library;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class StudentOperations {

    public static void locateIdleMembers(Connection conn) throws SQLException {
        String sql = "SELECT s.student_id, s.name, s.email, s.enrolled_date, " +
                     "MAX(ib.issue_date) AS last_activity_date " +
                     "FROM Students s " +
                     "LEFT JOIN IssuedBooks ib ON s.student_id = ib.student_id " +
                     "GROUP BY s.student_id, s.name, s.email, s.enrolled_date " +
                     "HAVING MAX(ib.issue_date) < CURRENT_DATE - INTERVAL '3 years' " +
                     "OR MAX(ib.issue_date) IS NULL " +
                     "ORDER BY last_activity_date ASC NULLS FIRST";
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            System.out.printf("%-6s %-25s %-30s %-14s %-18s%n",
                    "ID", "Name", "Email", "Enrolled", "Last Activity");
            System.out.println("-".repeat(95));
            while (rs.next()) {
                System.out.printf("%-6d %-25s %-30s %-14s %-18s%n",
                        rs.getInt("student_id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("enrolled_date"),
                        rs.getString("last_activity_date") == null ? "Never" : rs.getString("last_activity_date"));
            }
        }
    }

    public static void purgeIdleMembers(Connection conn) throws SQLException {
        conn.setAutoCommit(false);
        try {
            String delIssued = "DELETE FROM IssuedBooks WHERE student_id IN (" +
                               "SELECT s.student_id FROM Students s " +
                               "LEFT JOIN IssuedBooks ib ON s.student_id = ib.student_id " +
                               "GROUP BY s.student_id " +
                               "HAVING (MAX(ib.issue_date) < CURRENT_DATE - INTERVAL '3 years' " +
                               "OR MAX(ib.issue_date) IS NULL) " +
                               "AND s.student_id NOT IN (" +
                               "SELECT DISTINCT student_id FROM IssuedBooks WHERE return_date IS NULL))";
            int issuedRows;
            try (PreparedStatement stmt = conn.prepareStatement(delIssued)) {
                issuedRows = stmt.executeUpdate();
            }

            String delStudents = "DELETE FROM Students WHERE student_id NOT IN (" +
                                 "SELECT DISTINCT student_id FROM IssuedBooks)";
            int studentRows;
            try (PreparedStatement stmt = conn.prepareStatement(delStudents)) {
                studentRows = stmt.executeUpdate();
            }

            conn.commit();
            System.out.println("Purged " + issuedRows + " issued record(s) and " + studentRows + " inactive student(s).");
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }
}
