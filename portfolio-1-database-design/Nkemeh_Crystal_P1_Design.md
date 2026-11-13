# PurpleBank Database Design

## 1. Entities

I chose six entities to represent PurpleBank's core digital banking operations.

| Entity | Information stored |
|---|---|
| Customer | Personal information about registered customers |
| Account | Customer bank accounts, account status and balances |
| Bank | Details of supported external Nigerian banks |
| Beneficiary | Saved recipients for interbank transfers |
| Transaction | Deposits, withdrawals, internal transfers, interbank transfers and reversals |
| Transaction Audit | Historical records of transaction activities and status changes |

These entities separate customer information, financial records and transaction monitoring while supporting the operations defined in the case study.

## 2. Attributes and Keys

The proposed database uses PostgreSQL data types. Each entity has a primary key (PK), while foreign keys (FKs) establish relationships between entities.

| Entity | Attributes and proposed data types | Keys and constraints |
|---|---|---|
| Customer | customer_id BIGINT, full_name VARCHAR(120), email VARCHAR(254), phone_number VARCHAR(20) | PK: customer_id. Email unique. All fields required. |
| Account | account_id BIGINT, customer_id BIGINT, account_number VARCHAR(10), balance NUMERIC(18,2), currency CHAR(3), status VARCHAR(20) | PK: account_id. FK: customer_id. Account number unique. All fields required. |
| Bank | bank_id BIGINT, bank_name VARCHAR(120), bank_code VARCHAR(10) | PK: bank_id. Bank code unique. All fields required. |
| Beneficiary | beneficiary_id BIGINT, customer_id BIGINT, bank_id BIGINT, account_number VARCHAR(10), account_name VARCHAR(120) | PK: beneficiary_id. FKs: customer_id, bank_id. All fields required. |
| Transaction | transaction_id BIGINT, reference VARCHAR(50), source_account_id BIGINT, destination_account_id BIGINT, beneficiary_id BIGINT, original_transaction_id BIGINT, transaction_type VARCHAR(30), amount NUMERIC(18,2), currency CHAR(3), status VARCHAR(20), created_at TIMESTAMPTZ | PK: transaction_id. Reference unique. Account, beneficiary and original transaction references are FKs. Optional references depend on transaction type. |
| Transaction Audit | audit_id BIGINT, transaction_id BIGINT, action VARCHAR(50), description TEXT, recorded_at TIMESTAMPTZ | PK: audit_id. FK: transaction_id. All fields required except description. |

`BIGINT` stores whole-number identifiers, `VARCHAR` stores text, `NUMERIC(18,2)` stores financial amounts with two decimal places, and `TIMESTAMPTZ` stores timestamps.

The account balance is stored because banking operations require controlled balance updates. Transaction histories and audit records provide supporting evidence for reconciliation.

## 3. Relationships

| Tables linked | Relationship | Explanation |
|---|---|---|
| Customer → Account | One-to-many | A customer may own multiple accounts; each account belongs to exactly one customer. |
| Customer → Beneficiary | One-to-many | A customer may save multiple beneficiaries; each beneficiary belongs to one customer. |
| Bank → Beneficiary | One-to-many | A bank may have multiple saved beneficiaries; each beneficiary references one bank. |
| Account → Transaction | One-to-many | An account may have multiple transactions; each transaction references the relevant source account. |
| Account → Transaction (destination) | One-to-many | An account may receive multiple internal transfers; destination references are optional. |
| Beneficiary → Transaction | One-to-many | A beneficiary may receive multiple interbank transfers; the reference is optional for other transactions. |
| Transaction → Transaction Audit | One-to-many | A transaction may have multiple audit records documenting its activities. |
| Transaction → Transaction (reversal) | Self-referencing | A reversal references the original successful transaction. |

An account can exist without transactions, while a transaction must reference an existing PurpleBank account. Foreign keys maintain these relationships.

## 4. Business Rules and Constraints

1. **Customer uniqueness:** Primary keys identify customers, while a UNIQUE constraint prevents duplicate email addresses.
2. **Account ownership:** Each account has a unique account number and a required foreign key referencing an existing customer.
3. **Transaction identification:** Each transaction has a unique reference and references an existing PurpleBank account.
4. **Currency and amount:** Account currencies are restricted to NGN. Transaction amounts must be positive and denominated in NGN.
5. **Account status:** Account status values are restricted to valid states. Transaction logic prevents inactive accounts from initiating withdrawals or outgoing transfers.
6. **Balance protection:** Balance checks prevent withdrawals or transfers exceeding available funds. Database transactions and row-level locking prevent concurrent overspending.
7. **Transfer destinations:** Internal transfers require a valid PurpleBank destination account. Interbank transfers require a beneficiary linked to a valid destination bank.
8. **Transaction status and reversal:** Timestamps and allowed statuses are validated. Reversal logic allows only one authorised reversal per successful transaction while preserving the original record.

## 5. Design Assumptions

1. PurpleBank operates in Nigerian Naira only, with fictional customer and transaction records.
2. Interbank transfers use simulated external bank responses without connecting to a live payment network.
3. Transaction types determine required account and beneficiary references. Reversals are recorded separately and linked to their original transactions to preserve transaction history.