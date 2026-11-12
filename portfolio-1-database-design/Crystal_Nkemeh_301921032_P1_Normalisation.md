# PurpleBank Normalisation

## Introduction

Database normalisation is the process of organising data into related tables to reduce redundancy, maintain data integrity, and prevent insertion, update, and deletion anomalies.

For PurpleBank, normalisation ensures that customer details, bank accounts, transactions, beneficiaries, and audit records are stored appropriately without unnecessary duplication.

The following example demonstrates the progression from an unnormalised structure through First Normal Form (1NF), Second Normal Form (2NF), and Third Normal Form (3NF).

All records are fictional and are used to illustrate the database design.

## 1. Unnormalised Form (UNF)

Initially, PurpleBank's account and transaction information could be stored in a single table containing customer details, account information, and lists of transactions.

| Account ID | Customer Name | Email | Account Number | Balance (NGN) | Transactions |
|---|---|---|---|---:|---|
| 101 | Ada Okafor | ada@example.com | 0123456789 | 85,000.00 | TXN001: Transfer ₦15,000; TXN002: Interbank transfer ₦10,000 |
| 102 | Tunde Bello | tunde@example.com | 0987654321 | 45,000.00 | TXN003: Deposit ₦20,000 |

### Problems with this structure

- The Transactions column contains multiple values within a single cell.
- Retrieving or updating individual transactions becomes difficult.
- Customer details may be duplicated whenever account or transaction information is repeated.
- Changes to customer information could create inconsistent records.

This structure does not satisfy First Normal Form because the Transactions field contains a repeating group.

## 2. First Normal Form (1NF)

First Normal Form requires each cell to contain a single value and each row to be uniquely identifiable.

To achieve 1NF, the transaction lists are separated into individual rows.

| Account ID | Event No. | Customer Name | Email | Account Number | Balance (NGN) | Transaction Ref. | Type | Amount (NGN) |
|---|---:|---|---|---|---:|---|---|---:|
| 101 | 1 | Ada Okafor | ada@example.com | 0123456789 | 85,000.00 | TXN001 | Internal transfer | 15,000.00 |
| 101 | 2 | Ada Okafor | ada@example.com | 0123456789 | 85,000.00 | TXN002 | Interbank transfer | 10,000.00 |
| 102 | 1 | Tunde Bello | tunde@example.com | 0987654321 | 45,000.00 | TXN003 | Deposit | 20,000.00 |

**Illustrative primary key:** (`account_id`, `event_no`).

Here, `event_no` is a sequence number within each account, so the combination uniquely identifies each row.

### Improvements

Each transaction occupies its own row, and the transaction details are stored as individual values.

However, customer names, email addresses, account numbers, and balances are still repeated across transactions.

This means the example is in 1NF but still contains unnecessary duplication.

## 3. Second Normal Form (2NF)

Second Normal Form requires a table to satisfy 1NF and ensures that every non-key attribute depends on the entire candidate key rather than only part of a composite key.

In the 1NF table, the illustrative primary key is (`account_id`, `event_no`).

Customer details, account numbers, and balances depend on `account_id` alone, not on the complete composite key. This is a partial dependency.

To remove it, account information is separated from transaction information.

### Account Table (2NF Stage)

| Account ID (PK) | Customer ID | Customer Name | Email | Account Number | Balance (NGN) |
|---|---|---|---|---|---:|
| 101 | 1 | Ada Okafor | ada@example.com | 0123456789 | 85,000.00 |
| 102 | 2 | Tunde Bello | tunde@example.com | 0987654321 | 45,000.00 |

### Transaction Table (2NF Stage)

| Account ID (PK, FK) | Event No. (PK) | Transaction Ref. | Type | Amount (NGN) |
|---|---:|---|---|---:|
| 101 | 1 | TXN001 | Internal transfer | 15,000.00 |
| 101 | 2 | TXN002 | Interbank transfer | 10,000.00 |
| 102 | 1 | TXN003 | Deposit | 20,000.00 |

### Improvements

Account information no longer repeats for every transaction.

The Account table uses `account_id` as its primary key, while the illustrative Transaction table retains the composite key (`account_id`, `event_no`).

The partial dependency has been removed.

However, the Account table still contains a transitive dependency: the customer ID determines the customer's name and email address.

Therefore, further normalisation is required.

## 4. Third Normal Form (3NF)

Third Normal Form requires a table to satisfy 2NF and removes transitive dependencies, where a non-key attribute depends on another non-key attribute.

In the 2NF Account table:

`account_id → customer_id → customer_name, email`

The customer's name and email depend on `customer_id`, rather than directly on the account itself.

To resolve this, customer information is moved into a separate Customer table.

PurpleBank's final design also separates external bank and beneficiary information from transactions.

### Customer Table

| customer_id (PK) | full_name | email | phone_number |
|---|---|---|---|
| 1 | Ada Okafor | ada@example.com | 08000000001 |
| 2 | Tunde Bello | tunde@example.com | 08000000002 |

### Account Table

| account_id (PK) | customer_id (FK) | account_number | balance (NGN) | currency | status |
|---|---|---|---:|---|---|
| 101 | 1 | 0123456789 | 85,000.00 | NGN | active |
| 102 | 2 | 0987654321 | 45,000.00 | NGN | active |

### Bank Table

| bank_id (PK) | bank_name | bank_code |
|---|---|---|
| 11 | Example Commercial Bank | 011 |

### Beneficiary Table

| beneficiary_id (PK) | customer_id (FK) | bank_id (FK) | account_number | account_name |
|---|---|---|---|---|
| 501 | 1 | 11 | 1234567890 | Chidi Eze |

### Transaction Table

| transaction_id (PK) | reference | source_account_id (FK) | destination_account_id (FK) | beneficiary_id (FK) | transaction_type | amount (NGN) |
|---|---|---|---|---|---|---:|
| 1001 | TXN001 | 101 | 102 | NULL | internal_transfer | 15,000.00 |
| 1002 | TXN002 | 101 | NULL | 501 | interbank_transfer | 10,000.00 |
| 1003 | TXN003 | 102 | NULL | NULL | deposit | 20,000.00 |

The Transaction table also includes `currency`, `status`, `created_at`, and the optional `original_transaction_id` for reversals. These columns are omitted from this example table for readability.

### Transaction Audit Table

| audit_id (PK) | transaction_id (FK) | action | description |
|---|---|---|---|
| 9001 | 1001 | CREATED | Internal transfer recorded |
| 9002 | 1002 | CREATED | Interbank transfer recorded |
| 9003 | 1003 | CREATED | Deposit recorded |

The Transaction Audit table also includes `recorded_at`, which records when each audit event occurred.

### How the Tables Remain Connected

Relationships are maintained using primary and foreign keys.

- `customer_id` connects Customer to Account and Beneficiary.
- `bank_id` connects Bank to Beneficiary.
- `source_account_id` connects Transaction to the relevant PurpleBank account.
- `destination_account_id` references the receiving PurpleBank account for internal transfers.
- `beneficiary_id` identifies the external transfer recipient when applicable.
- `transaction_id` connects Transaction Audit records to their transactions.
- `original_transaction_id` allows a reversal to reference its original transaction.

### Replacement of the Illustrative Composite Key

The earlier Transaction table used (`account_id`, `event_no`) as a composite primary key.

In the final design, `transaction_id` is used as the primary key, and `reference` is unique. The earlier event sequence is no longer required.

This makes individual transactions easier to identify while maintaining account relationships through foreign keys.

Using a generated transaction ID does not, by itself, establish 3NF. The improvement comes from separating attributes according to their functional dependencies.

## 5. Benefits of Normalisation for PurpleBank

The normalised database design provides several benefits:

1. **Reduced redundancy:** Customer information is stored once instead of being repeated across transactions.
2. **Improved data integrity:** Foreign keys ensure that related records reference valid customers, accounts, banks, and transactions.
3. **Simpler updates:** Customer details can be updated without modifying multiple transaction records.
4. **Improved consistency:** Beneficiary bank information is maintained separately from financial transactions.
5. **Preserved transaction history:** Transaction and audit records remain linked without duplicating customer information.

## Conclusion

PurpleBank's proposed relational database is organised into six entities: Customer, Account, Bank, Beneficiary, Transaction, and Transaction Audit.

The normalisation process demonstrates how repeated values, partial dependencies, and transitive dependencies can be addressed through table separation and appropriate primary and foreign keys.

The resulting design follows Third Normal Form under the stated business rules and assumptions, providing a structured foundation for the database implementation.

**Example assumptions:** Each example event belongs to one account, event numbers are unique within an account, and the illustrated transactions are fictional records rather than executed database results. The balance values are illustrative snapshots and are not calculated from the three example transactions alone.