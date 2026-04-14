# Digital Library Audit – SQL Project

A relational database system for a community college library to track book loans, overdue returns, penalties, and borrowing trends.

## Tables

| Table | Purpose                           |
| ----- | --------------------------------- |
| `s`   | Students                          |
| `b`   | Books with stock count            |
| `ib`  | Issued books (loans)              |
| `pen` | Penalty records                   |
| `log` | Audit log of issue/return actions |

## Features Covered

- DDL: table creation, indexes, views
- DML: insert, update, delete
- Joins: INNER, LEFT, RIGHT, FULL OUTER, SELF
- Subqueries, correlated subqueries, CTEs
- Window functions: RANK, running COUNT
- Aggregates with HAVING, CASE expressions
- UNION, INTERSECT, EXCEPT
- Triggers: auto stock update, auto penalty insert, audit logging
- Stored procedure: `pr_return` to mark a book returned
- Scalar function: `fn_fine` to calculate fine for a loan

## Requirements

- PostgreSQL 13+

## Execution

**Run the full file:**

```bash
psql -U <username> -d <database> -f library.sql
```

**Create a fresh database and run:**

```bash
createdb libdb
psql -U postgres -d libdb -f library.sql
```

**Run interactively:**

```bash
psql -U postgres -d libdb
\i library.sql
```

**Check overdue books:**

```sql
SELECT * FROM v_overdue;
```

**Check popular categories:**

```sql
SELECT * FROM v_pop;
```

**Return a book (loan id, return date):**

```sql
CALL pr_return(1, CURRENT_DATE);
```

**Get fine for a loan:**

```sql
SELECT fn_fine(2);
```

**View audit log:**

```sql
SELECT * FROM log ORDER BY ts DESC;
```
