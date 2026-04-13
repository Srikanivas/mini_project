# Digital Library Audit System

A PostgreSQL-based library management system for tracking books, students, and borrowing activity. Includes audit queries, transactional DML operations, and a pgTAP test suite.

---

## Prerequisites

- **PostgreSQL 14+** — [postgresql.org/download](https://www.postgresql.org/download/)
- **pgTAP** — required only to run the test suite ([pgtap.org](https://pgtap.org/))
- **pg_prove** — Perl test runner bundled with pgTAP (`cpan TAP::Parser::SourceHandler::pgTAP`)
- **psql** — the standard PostgreSQL CLI client (ships with PostgreSQL)
- **Python 3.8+** and **Java 11+** for the application layers

> **Windows users:** All commands below use PowerShell syntax. Do not use `KEY=value command` — that is Linux/bash only.

---

## Setup

### 1. Create the database

```bash
createdb library_db
```

### 2. Apply the schema

Creates the `Books`, `Students`, and `IssuedBooks` tables with all constraints and indexes.

```bash
psql -d library_db -f sql/schema.sql
```

### 3. Create roles and grant privileges

Creates `library_admin` (read/write) and `library_reader` (read-only) roles.

```bash
psql -d library_db -f sql/roles.sql
```

Assign a role to a database user:

```sql
GRANT library_admin TO your_admin_user;
GRANT library_reader TO your_readonly_user;
```

### 4. Load seed data

Populates the database with sample books, students, and borrowing history.

```bash
psql -d library_db -f sql/seed.sql
```

---

## Running Query Scripts

All query scripts are read-only `SELECT` statements and require no parameters.

```bash
psql -d library_db -f sql/queries/overdue_books.sql
psql -d library_db -f sql/queries/category_popularity.sql
psql -d library_db -f sql/queries/inactive_students.sql
psql -d library_db -f sql/queries/active_issues.sql
```

---

## Running DML Operation Scripts

DML scripts use `current_setting('app.*')` to read parameters. Set the required session variables with `SET` before executing the script, or pass them inline using `psql -c`.

### Issue a book

Required parameters: `app.new_issue_id`, `app.book_id`, `app.student_id`.

```bash
psql -d library_db -c "SET app.new_issue_id = 20; SET app.book_id = 3; SET app.student_id = 1;" -f sql/dml/issue_book.sql
```

### Return a book

Required parameter: `app.issue_id`.

```bash
psql -d library_db -c "SET app.issue_id = 1;" -f sql/dml/return_book.sql
```

### Delete inactive students

```bash
psql -d library_db -f sql/dml/delete_inactive_students.sql
```

### Reconcile book availability

```bash
psql -d library_db -f sql/dml/reconcile_availability.sql
```

---

## Running the Python App

```powershell
cd python
pip install -r requirements.txt
$env:DB_HOST="localhost"; $env:DB_NAME="library_db"; $env:DB_USER="postgres"; $env:DB_PASS="secret"; python main.py
```

## Running the Java App

```powershell
cd java
mvn package
$env:DB_URL="jdbc:postgresql://localhost/library_db"; $env:DB_USER="postgres"; $env:DB_PASS="secret"; java -jar target/digital-library-audit-1.0.0.jar
```

---

## Running the Test Suite

Tests live in the `tests/` directory and use [pgTAP](https://pgtap.org/).

> **Note:** The `tests/` directory is not included in this repository. The pgTAP property-based tests described in the spec are optional. To use the test suite, create the `tests/` directory and add your pgTAP `.sql` test files there.

### Install pgTAP into the database

```bash
psql -d library_db -c "CREATE EXTENSION IF NOT EXISTS pgtap;"
```

### Run all tests with pg_prove

```bash
pg_prove -d library_db tests/*.sql
```

### Run a single test file

```bash
psql -d library_db -f tests/<test_file>.sql
```

---

## Security Considerations

### Parameterisation

DML scripts read runtime values via `current_setting('app.*')` rather than embedding literals directly in SQL. This prevents SQL injection by keeping user-supplied values out of the query text. Always set parameters with `SET app.<param> = <value>` before executing a script — never by concatenating strings into the SQL file.

Example of the safe pattern used throughout:

```sql
-- Inside the script
v_book_id := current_setting('app.book_id')::INT;

-- Caller sets the value before running the script
SET app.book_id = 42;
```

### Role-Based Access Control

Two roles are provided with least-privilege access:

| Role | Permissions |
|---|---|
| `library_admin` | `SELECT`, `INSERT`, `UPDATE`, `DELETE` on all tables |
| `library_reader` | `SELECT` only on all tables |

- Use `library_reader` for reporting and audit queries.
- Use `library_admin` for DML operations (issue, return, delete, reconcile).
- Avoid connecting as a superuser for routine operations.
