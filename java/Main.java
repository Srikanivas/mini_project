import java.util.Scanner;

public class Main {
    static Scanner sc = new Scanner(System.in);

    static double getAmt(String prompt) {
        System.out.print(prompt);
        try {
            return Double.parseDouble(sc.nextLine().trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid number.");
        }
    }

    static void menu() {
        System.out.println("\n[1] Deposit  [2] Withdraw  [3] Statement  [q] Quit");
        System.out.print("Choice: ");
    }

    public static void main(String[] args) {
        System.out.print("Account holder name: ");
        String n = sc.nextLine().trim();
        double init;
        try {
            init = getAmt("Opening balance: ");
        } catch (IllegalArgumentException e) {
            System.out.println(e.getMessage());
            return;
        }

        Account acc = new Account(n, init);
        System.out.printf("Welcome, %s! Balance: %.2f%n", acc.getNm(), acc.getBal());

        while (true) {
            menu();
            String cmd = sc.nextLine().trim();
            try {
                switch (cmd) {
                    case "1":
                        acc.deposit(getAmt("Amount to deposit: "));
                        break;
                    case "2":
                        acc.processTransaction(getAmt("Amount to withdraw: "));
                        break;
                    case "3":
                        acc.printMiniStatement();
                        break;
                    case "q":
                        System.out.println("Goodbye!");
                        return;
                    default:
                        System.out.println("Invalid option.");
                }
            } catch (InSufficientFundsException e) {
                System.out.println("Error: " + e.getMessage());
            } catch (IllegalArgumentException e) {
                System.out.println("Error: " + e.getMessage());
            }
        }
    }
}
