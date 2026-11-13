# Portfolio 1 Database Design and Modelling

## Case study

PurpleBank is a fictional Nigerian digital bank that provides customers with digital banking services, including account management, deposits, withdrawals, and internal and interbank fund transfers. The proposed database system manages customer information, bank accounts, beneficiaries, financial transactions, and transaction histories while ensuring data integrity, consistency, and reliable transaction processing. All transactions are conducted in Nigerian Naira (NGN), with interbank transfers simulated using fictional data.

## Users

Customers register, manage their accounts, initiate transfers, manage beneficiaries, and view transaction histories. Bank operations officers monitor transactions, investigate failed transfers, and process authorised reversals. System administrators maintain database records, monitor operations, and ensure data integrity.

## Main operations

Register customers and create bank accounts; deposit and withdraw funds; transfer money between PurpleBank accounts; initiate simulated transfers to other Nigerian banks; manage beneficiaries; retrieve account balances and transaction histories; and process transaction reversals while maintaining audit records.

## Business rules

1. Each customer must have a unique customer ID and email address.
2. Each bank account must have a unique account number and belong to one registered customer. A customer may own multiple accounts.
3. Each transaction must have a unique transaction reference and be associated with an existing PurpleBank account.
4. All accounts and transactions must use Nigerian Naira (NGN), and transaction amounts must be greater than zero.
5. Only active accounts may initiate withdrawals or outgoing transfers.
6. Withdrawals and outgoing transfers cannot exceed the available account balance. Concurrent transactions must not allow the same funds to be spent twice.
7. Internal transfers must reference an existing PurpleBank destination account. Interbank transfers must specify a beneficiary account number and a destination bank.
8. Each transaction must have a timestamp and a valid status of pending, successful, failed, or reversed. Only successful transactions may be reversed, and each may be reversed once without deleting the original record.

## Scope

The system covers a single fictional Nigerian digital bank using simulated customer, account, and transaction data. It includes customer registration, account management, NGN deposits and withdrawals, internal transfers, simulated interbank transfers, beneficiary management, transaction reversals, and audit records. Foreign currencies, currency conversion, live banking network integrations, loans, interest calculations, card processing, and user authentication are outside the scope of the system.

## Design and implementation files

| File | Contents |
|---|---|
| [Database Design](Nkemeh_Crystal_P1_Design.md) | Description of PurpleBank's six entities, attributes, primary keys, foreign keys and relationships. |
| [ER Diagram](Nkemeh_Crystal_P1_ERDiagram.md) | Visual representation of the database entities, attributes and relationships. |
| [Normalisation](Nkemeh_Crystal_P1_Normalisation.md) | Explanation and examples of First, Second and Third Normal Forms (1NF, 2NF and 3NF). |
| [Database Schema](Nkemeh_Crystal_P1_Schema.sql) | PostgreSQL scripts for creating tables, keys, constraints and the reversal uniqueness index. |
| [Sample Data](Nkemeh_Crystal_P1_SampleData.sql) | SQL statements for inserting fictional customers, accounts, banks, beneficiaries, transactions and audit records. |
| [Constraint Tests](Nkemeh_Crystal_P1_ConstraintTests.sql) | SQL statements designed to test data validation rules, including required fields, uniqueness, relationships and valid values. |
| [Screenshots](screenshots/) | Evidence of database creation, table structures, sample data and constraint testing. |

## Implementation

PurpleBank's relational database was implemented using PostgreSQL 16 within GitHub Codespaces. The database, named `purplebank_portfolio`, contains six tables: `customer`, `account`, `bank`, `beneficiary`, `bank_transaction` and `transaction_audit`. Each table has a primary key, while foreign keys establish relationships between customers, accounts, beneficiaries, banks and financial transactions.

The database schema includes NOT NULL, UNIQUE, FOREIGN KEY and CHECK constraints to maintain data integrity. These restrict duplicate identifiers, invalid account balances, unsupported currencies, invalid transaction statuses and incomplete transfer information. A unique partial index also prevents multiple reversal records from referencing the same original transaction. Fictional banking records were inserted using the sample-data script, followed by separate tests using deliberately invalid records.

## Test results

The sample-data script was designed to insert two customers, two external banks, three bank accounts, two beneficiaries, five banking transactions and five transaction audit records. These records represent PurpleBank's core operations, including deposits, withdrawals, internal transfers, simulated interbank transfers and transaction reversals.

Fifteen negative test cases were prepared to assess the database constraints. They cover missing required values, duplicate records, invalid foreign keys, negative balances, unsupported currencies and statuses, incomplete internal transfers, duplicate reversals and invalid audit references. PostgreSQL error messages provide evidence of the constraints rejecting invalid records.

The expected final record counts are 2 customers, 2 banks, 3 accounts, 2 beneficiaries, 5 transactions and 5 audit records, provided all sample inserts succeeded once and every negative test was rejected. Additional transaction logic is required to demonstrate automatic balance updates, concurrent spending protection, reversal eligibility and authorisation. These behaviours are not fully enforced by the table definitions alone.