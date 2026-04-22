import java.util.ArrayList;
import java.util.Collections;

public class Account {
    private double bal;
    private String nm;
    private ArrayList<String> hist = new ArrayList<>();

    public Account(String n, double b) {
        this.nm = n;
        this.bal = b;
    }

    public void printMiniStatement() {
        System.out.println("\n--- Mini Statement [" + nm + "] ---");
        if (hist.isEmpty()) { System.out.println("No transactions yet."); }
        else { for (String x : hist) System.out.println("  " + x); }
        System.out.printf("Current Balance: %.2f%n", bal);
        System.out.println("--------------------------------\n");
    }

    public double getBal() { return bal; }
    public String getNm()  { return nm; }

    private void addHist(String e) {
        if (hist.size() == 5) hist.remove(0);
        hist.add(e);
    }

    public void deposit(double a) {
        if (a <= 0) throw new IllegalArgumentException("Deposit must be positive.");
        bal += a;
        addHist(String.format("DEP  +%.2f | Bal: %.2f", a, bal));
        System.out.printf("Deposited %.2f | New Balance: %.2f%n", a, bal);
    }

    public void processTransaction(double a) throws InSufficientFundsException {
        if (a < 0) throw new IllegalArgumentException("Amount cannot be negative.");
        if (a > bal) throw new InSufficientFundsException(a - bal);
        bal -= a;
        addHist(String.format("WDR  -%.2f | Bal: %.2f", a, bal));
        System.out.printf("Withdrawn %.2f | New Balance: %.2f%n", a, bal);
    }
}
