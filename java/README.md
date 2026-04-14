# FinSafe – Transaction Validator

A console-based Java application for a digital wallet that validates transactions, prevents overdrafts, and logs activity.

## Files

| File                              | Purpose                                          |
| --------------------------------- | ------------------------------------------------ |
| `Main.java`                       | Entry point, menu loop                           |
| `Account.java`                    | Encapsulated account with deposit/withdraw logic |
| `InSufficientFundsException.java` | Custom exception for overdraft                   |

## Java Topics Covered

- Encapsulation with private fields and getters
- Custom exception class extending `Exception`
- `throw` / `try-catch` error handling
- `IllegalArgumentException` for invalid input
- `ArrayList` for transaction history (capped at 5)
- `Scanner` for user input
- `String.format` / `printf` for output formatting
- Switch-case menu loop

## Requirements

- Java 8+

## Compile & Run

```bash
javac *.java
java Main
```

## Menu Options

```
[1] Deposit    – add funds to account
[2] Withdraw   – deduct funds (throws error if insufficient)
[3] Statement  – view last 5 transactions and current balance
[q] Quit
```

## Sample Session

```
Account holder name: John
Opening balance: 500
Welcome, John! Balance: 500.00

[1] Deposit  [2] Withdraw  [3] Statement  [q] Quit
Choice: 2
Amount to withdraw: 600
Error: Insufficient funds. Shortfall: 100.0

Choice: 3
--- Mini Statement [John] ---
No transactions yet.
Current Balance: 500.00
```
