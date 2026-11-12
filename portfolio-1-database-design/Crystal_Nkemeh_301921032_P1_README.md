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