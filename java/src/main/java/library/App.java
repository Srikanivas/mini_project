package library;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Scanner;

public class App {

    public static void main(String[] args) {
        try (Connection conn = DbConnection.openLink();
             Scanner sc = new Scanner(System.in)) {
            boolean running = true;
            while (running) {
                printMenu();
                String choice = sc.nextLine().trim();
                switch (choice) {
                    case "1":
                        System.out.print("Enter issue_id, book_id, student_id (space-separated): ");
                        String[] lendArgs = sc.nextLine().trim().split("\\s+");
                        BookOperations.lendVolume(conn,
                                Integer.parseInt(lendArgs[0]),
                                Integer.parseInt(lendArgs[1]),
                                Integer.parseInt(lendArgs[2]));
                        break;
                    case "2":
                        System.out.print("Enter issue_id to return: ");
                        int recordId = Integer.parseInt(sc.nextLine().trim());
                        BookOperations.recoverVolume(conn, recordId);
                        break;
                    case "3":
                        System.out.println("\n--- Overdue Books ---");
                        ReportOperations.fetchOverdueList(conn);
                        break;
                    case "4":
                        System.out.println("\n--- Category Popularity ---");
                        ReportOperations.computePopularity(conn);
                        break;
                    case "5":
                        System.out.println("\n--- Inactive Members (>3 years or never borrowed) ---");
                        StudentOperations.locateIdleMembers(conn);
                        break;
                    case "6":
                        System.out.println("\n--- Current Active Loans ---");
                        ReportOperations.currentLoans(conn);
                        break;
                    case "7":
                        System.out.print("Confirm purge inactive members? (yes/no): ");
                        if ("yes".equalsIgnoreCase(sc.nextLine().trim())) {
                            StudentOperations.purgeIdleMembers(conn);
                        } else {
                            System.out.println("Purge cancelled.");
                        }
                        break;
                    case "8":
                        BookOperations.syncCopyCounts(conn);
                        break;
                    case "0":
                        running = false;
                        System.out.println("Goodbye.");
                        break;
                    default:
                        System.out.println("Invalid option.");
                }
                System.out.println();
            }
        } catch (SQLException e) {
            System.err.println("Database error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void printMenu() {
        System.out.println("=== Digital Library Audit System ===");
        System.out.println("1. Lend a volume (issue book)");
        System.out.println("2. Recover a volume (return book)");
        System.out.println("3. Fetch overdue list");
        System.out.println("4. Compute category popularity");
        System.out.println("5. Locate idle members");
        System.out.println("6. Current active loans");
        System.out.println("7. Purge idle members");
        System.out.println("8. Sync copy counts (reconcile)");
        System.out.println("0. Exit");
        System.out.print("Choice: ");
    }
}
