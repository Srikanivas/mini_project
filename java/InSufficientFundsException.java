public class InSufficientFundsException extends Exception {
    private double amt;
    public InSufficientFundsException(double a) {
        super("Insufficient funds. Shortfall: " + a);
        this.amt = a;
    }
    public double getAmt() { return amt; }
}
