import java.time.LocalDate;

public class Transaction {
    int uid, bid;
    LocalDate issued_dt, due_dt, return_dt;

    public Transaction(int uid, int bid) {
        this.uid = uid;
        this.bid = bid;
        this.issued_dt = LocalDate.now();
        this.due_dt = issued_dt.plusDays(14);
        this.return_dt = null;
    }

    public double fine() {
        if (return_dt == null)
            return 0;
        if (!return_dt.isAfter(due_dt))
            return 0;
        long d = return_dt.toEpochDay() - due_dt.toEpochDay();
        return d * 2.0;
    }

    public String toString() {
        String r = (return_dt == null) ? "Not Returned" : return_dt.toString();
        return "User:" + uid + " Book:" + bid + " | Issued:" + issued_dt + " Due:" + due_dt + " Return:" + r + " Fine:Rs." + fine();
    }
}
