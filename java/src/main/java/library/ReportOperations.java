package library;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ReportOperations {

    public static void fetchOverdueList(Connection conn) throws SQLException {
        String sql = "SELECT ib.issue_id, s.student_id, s.name AS student_name, s.email AS student_email, " +
                     "b.book_id, b.title AS book_title, b.category, ib.issue_date, " +
                     "(CURRENT_DATE - ib.issue_date) AS days_overdue " +
                     "FROM IssuedBooks ib " +
                     "JOIN Books b ON ib.book_id = b.book_id " +
                     "JOIN Students s ON ib.student_id = s.student_id " +
                     "WHERE ib.return_date IS NULL " +
                     "AND ib.issue_date < CURRENT_DATE - INTERVAL '14 days' " +
                     "ORDER BY days_overdue DESC";
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            System.out.printf("%-8s %-25s %-30s %-30s %-12s %-10s%n",
                    "IssueID", "Student", "Email", "Title", "Issue Date", "Days Over");
            System.out.println("-".repeat(115));
            while (rs.next()) {
                System.out.printf("%-8d %-25s %-30s %-30s %-12s %-10d%n",
                        rs.getInt("issue_id"),
                        rs.getString("student_name"),
                        rs.getString("student_email"),
                        rs.getString("book_title"),
                        rs.getString("issue_date"),
                        rs.getInt("days_overdue"));
            }
        }
    }

    public static void computePopularity(Connection conn) throws SQLException {
        String sql = "SELECT b.category, COUNT(ib.issue_id) AS total_borrows, " +
                     "COUNT(DISTINCT b.book_id) AS unique_books_borrowed " +
                     "FROM Books b " +
                     "LEFT JOIN IssuedBooks ib ON b.book_id = ib.book_id " +
                     "GROUP BY b.category " +
                     "ORDER BY total_borrows DESC";
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            System.out.printf("%-20s %-15s %-20s%n", "Category", "Total Borrows", "Unique Books Borrowed");
            System.out.println("-".repeat(55));
            while (rs.next()) {
                System.out.printf("%-20s %-15d %-20d%n",
                        rs.getString("category"),
                        rs.getInt("total_borrows"),
                        rs.getInt("unique_books_borrowed"));
            }
        }
    }

    public static void currentLoans(Connection conn) throws SQLException {
        String sql = "SELECT s.student_id, s.name, b.title, b.category, ib.issue_date, " +
                     "(CURRENT_DATE - ib.issue_date) AS days_held " +
                     "FROM IssuedBooks ib " +
                     "JOIN Students s ON ib.student_id = s.student_id " +
                     "JOIN Books b ON ib.book_id = b.book_id " +
                     "WHERE ib.return_date IS NULL " +
                     "ORDER BY s.name ASC, ib.issue_date ASC";
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            System.out.printf("%-6s %-25s %-30s %-15s %-12s %-10s%n",
                    "StuID", "Name", "Title", "Category", "Issue Date", "Days Held");
            System.out.println("-".repeat(100));
            while (rs.next()) {
                System.out.printf("%-6d %-25s %-30s %-15s %-12s %-10d%n",
                        rs.getInt("student_id"),
                        rs.getString("name"),
                        rs.getString("title"),
                        rs.getString("category"),
                        rs.getString("issue_date"),
                        rs.getInt("days_held"));
            }
        }
    }
}
