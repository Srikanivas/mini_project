# Academic Mini Projects

Three beginner-level projects covering SQL, Python, and Java fundamentals built as academic assignments.

## Structure

```
├── Sql/
│   ├── library.sql
│   └── README.md
├── python/
│   ├── farecalc.py
│   └── README.md
├── java/
│   ├── Main.java
│   ├── Account.java
│   ├── InSufficientFundsException.java
│   └── README.md
└── README.md
```

---

## 1. SQL – Digital Library Audit (`Sql/`)

A relational database for a community college library to track book loans, overdue returns, and borrowing trends.

**Key Features**

- Tables: Students, Books, Issued Books, Penalties, Audit Log
- Overdue detection with auto fine calculation
- Triggers for stock management and audit logging
- Views, stored procedure, and scalar function
- Covers: joins, subqueries, CTEs, window functions, UNION/INTERSECT/EXCEPT, CASE, indexes

**Run**

```bash
psql -U postgres -d libdb -f Sql/library.sql
```

---

## 2. Python – FareCalc Travel Optimizer (`python/`)

A ride-fare calculator for a ride-sharing startup with surge pricing and session history.

**Key Features**

- Vehicle rate dictionary (Economy / Premium / SUV)
- Surge multiplier (1.5x) during peak hours 17:00–20:00
- Custom exception hierarchy (`FareError`, `InputError`, `VehicleError`)
- File I/O ride logging to `rides.log`
- Menu-driven loop with full input validation

**Run**

```bash
python python/farecalc.py
```

---

## 3. Java – FinSafe Transaction Validator (`java/`)

A digital wallet console app that validates transactions and prevents overdrafts.

**Key Features**

- Encapsulated `Account` class with private fields
- Custom `InSufficientFundsException` for overdraft scenarios
- Deposit and withdraw with full error handling
- Mini statement showing last 5 transactions

**Run**

```bash
cd java
javac *.java
java Main
```

---

## Topics Covered Across Projects

| Topic               | SQL                              | Python                        | Java                        |
| ------------------- | -------------------------------- | ----------------------------- | --------------------------- |
| Data Structures     | Tables, Views                    | Dict, List                    | ArrayList                   |
| Error Handling      | —                                | try/except, custom exceptions | try/catch, custom exception |
| Functions / Methods | Stored proc, triggers, functions | Functions, lambdas            | Methods, constructors       |
| File / IO           | —                                | File read/write               | Scanner                     |
| OOP                 | —                                | Classes                       | Encapsulation, inheritance  |
| Logic               | CASE, joins, subqueries          | Conditionals, loops           | Switch, loops               |
