# Portfolio 3: Transactions and Concurrency

## Project Overview

This portfolio demonstrates transaction management, isolation, and concurrency control using PurpleBank, a fictional Nigerian digital bank.

The objective is to examine how PostgreSQL maintains data consistency and integrity when processing successful transactions, handling errors, and managing simultaneous database operations.

The experiments were conducted using PostgreSQL 16 and fictional banking records in the `purplebank_portfolio` database.

## 1. Transaction Management: COMMIT and ROLLBACK

### Successful Transaction Using COMMIT

A transaction was initiated to simulate a withdrawal of NGN 10,000 from an active PurpleBank account belonging to Ada Okafor.

The account initially had a balance of NGN 100,000. PostgreSQL's `BEGIN` command started the transaction, and an `UPDATE` statement deducted NGN 10,000 after checking that the account was active and had sufficient funds.

The `COMMIT` command saved the change, resulting in a final account balance of NGN 90,000.

A subsequent query verified that the updated balance remained saved after the transaction was committed.

### Failed Transaction Using ROLLBACK

A second transaction was initiated to demonstrate how PostgreSQL handles errors during database operations.

An additional NGN 5,000 was temporarily deducted from Ada Okafor's account, reducing the balance from NGN 90,000 to NGN 85,000.

An invalid account insertion was then attempted using a negative balance of NGN 500. PostgreSQL rejected the insertion because it violated the `account_balance_check` constraint.

The `ROLLBACK` command cancelled all changes made within the failed transaction.

A verification query confirmed that Ada's account balance returned to NGN 90,000 and that the invalid account was not created.

### Findings

The COMMIT experiment demonstrated the persistence of successfully committed changes, while the ROLLBACK experiment demonstrated transaction atomicity by ensuring that the failed operation did not leave partial changes in the database.

## 2. Transaction Isolation and Concurrency Control

### Objective

The concurrency experiment investigated how PostgreSQL handles simultaneous database operations that attempt to insert records with the same unique transaction reference.

Two independent PostgreSQL sessions, Session A and Session B, were used to simulate competing banking operations.

### Session A: Uncommitted Transaction

Session A began a transaction using the `READ COMMITTED` isolation level.

A pending deposit record of NGN 1,000 was inserted using the unique reference `PB-P3-CONCURRENT-001`.

The transaction remained uncommitted while Session B attempted to access and insert a conflicting record.

### Session B: Conflicting Transaction

Session B also operated at the `READ COMMITTED` isolation level.

An initial query returned zero matching records because Session A's transaction had not yet been committed.

Session B then attempted to insert another pending deposit of NGN 2,000 using the same transaction reference.

PostgreSQL blocked the conflicting insertion while Session A's transaction remained uncommitted.

### Concurrency Resolution

After Session A executed `COMMIT`, PostgreSQL resolved the waiting operation in Session B.

Session B's insertion was rejected because the transaction reference already existed, violating the database's UNIQUE constraint.

A `ROLLBACK` command ended Session B's failed transaction.

The final verification query confirmed that only one transaction with reference `PB-P3-CONCURRENT-001` existed in the database.

### Findings

The experiment demonstrated PostgreSQL's isolation and concurrency control mechanisms.

At the `READ COMMITTED` isolation level, Session B could not retrieve Session A's uncommitted record through an ordinary SELECT query.

The unique constraint also prevented two concurrent operations from creating transactions with identical references.

These mechanisms help preserve data integrity and prevent conflicting transaction records in PurpleBank.

## 3. Application of ACID Properties

The experiments demonstrated the following database transaction properties:

- **Atomicity:** ROLLBACK ensured that changes within the failed transaction were undone together.
- **Consistency:** Database constraints prevented invalid account balances and duplicate transaction references.
- **Isolation:** Session B could not read Session A's uncommitted transaction, and the conflicting insertion was controlled.
- **Durability:** COMMIT preserved successfully completed database changes after the transactions ended.

## 4. Conclusion

The experiments demonstrated how PostgreSQL manages successful transactions, handles failed operations, and controls concurrent database activities.

COMMIT preserved a successful account balance update, while ROLLBACK restored the database to its previously committed state after a constraint violation.

The two-session experiment demonstrated how transaction isolation and unique constraints work together to prevent conflicting transaction records.

These capabilities are important for maintaining reliable financial records and transaction integrity in a digital banking environment such as PurpleBank.

The experiments focused on database transaction controls. A complete banking transaction workflow would additionally require coordinated balance updates, transaction logging, and appropriate authorisation.

## 5. Portfolio Files and Evidence

### SQL Scripts

- [Transaction Management Script](Nkemeh_Crystal_P3_Transactions.sql) – Demonstrates COMMIT, ROLLBACK, and account balance verification.
- [Session A Script](Nkemeh_Crystal_P3_SessionA.sql) – Contains the SQL commands executed by the first PostgreSQL session.
- [Session B Script](Nkemeh_Crystal_P3_SessionB.sql) – Contains the SQL commands used to demonstrate transaction isolation and the conflicting insertion.

### Screenshots

- [COMMIT Evidence](screenshots/Nkemeh_Crystal_P3_Commit.png) – Successful balance update and COMMIT.
- [ROLLBACK Evidence](screenshots/Nkemeh_Crystal_P3_Rollback.png) – Constraint violation, ROLLBACK, and balance verification.
- [Session Waiting Evidence](screenshots/Nkemeh_Crystal_P3_SessionsWaiting.png) – Demonstrates the concurrent session waiting on a database lock.
- [Concurrency Result](screenshots/Nkemeh_Crystal_P3_ConcurrencyResult.png) – Shows the conflicting transaction error and final verification.

## 6. References

PostgreSQL Global Development Group. (n.d.). *Transactions*. PostgreSQL documentation. https://www.postgresql.org/docs/current/tutorial-transactions.html

PostgreSQL Global Development Group. (n.d.). *Transaction isolation*. PostgreSQL documentation. https://www.postgresql.org/docs/current/transaction-iso.html

PostgreSQL Global Development Group. (n.d.). *Explicit locking*. PostgreSQL documentation. https://www.postgresql.org/docs/current/explicit-locking.html