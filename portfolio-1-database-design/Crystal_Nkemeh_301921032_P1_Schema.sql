
-- PurpleBank Database Schema
-- Portfolio 1: Database Design and Modelling
-- Creates the core tables for customer accounts, banking transactions, beneficiaries, and audit records.

BEGIN;

-- 1. Customer table
CREATE TABLE public.customer (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL
);

-- 2. Bank table
CREATE TABLE public.bank (
    bank_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    bank_name VARCHAR(120) NOT NULL,
    bank_code VARCHAR(10) NOT NULL UNIQUE
);

-- 3. Account table
CREATE TABLE public.account (
    account_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    account_number VARCHAR(10) NOT NULL UNIQUE,
    balance NUMERIC(18,2) NOT NULL DEFAULT 0.00,
    currency CHAR(3) NOT NULL DEFAULT 'NGN',
    status VARCHAR(20) NOT NULL DEFAULT 'active',

    CONSTRAINT account_customer_fk
        FOREIGN KEY (customer_id)
        REFERENCES public.customer(customer_id),

    CONSTRAINT account_balance_check
        CHECK (balance >= 0),

    CONSTRAINT account_currency_check
        CHECK (currency = 'NGN'),

    CONSTRAINT account_status_check
        CHECK (status IN ('active', 'inactive', 'frozen'))
);

-- 4. Beneficiary table
CREATE TABLE public.beneficiary (
    beneficiary_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    bank_id BIGINT NOT NULL,
    account_number VARCHAR(10) NOT NULL,
    account_name VARCHAR(120) NOT NULL,

    CONSTRAINT beneficiary_customer_fk
        FOREIGN KEY (customer_id)
        REFERENCES public.customer(customer_id),

    CONSTRAINT beneficiary_bank_fk
        FOREIGN KEY (bank_id)
        REFERENCES public.bank(bank_id)
);

-- 5. Transaction table
CREATE TABLE public.bank_transaction (
    transaction_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reference VARCHAR(50) NOT NULL UNIQUE,
    source_account_id BIGINT NOT NULL,
    destination_account_id BIGINT,
    beneficiary_id BIGINT,
    original_transaction_id BIGINT,
    transaction_type VARCHAR(30) NOT NULL,
    amount NUMERIC(18,2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'NGN',
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT transaction_source_fk
        FOREIGN KEY (source_account_id)
        REFERENCES public.account(account_id),

    CONSTRAINT transaction_destination_fk
        FOREIGN KEY (destination_account_id)
        REFERENCES public.account(account_id),

    CONSTRAINT transaction_beneficiary_fk
        FOREIGN KEY (beneficiary_id)
        REFERENCES public.beneficiary(beneficiary_id),

    CONSTRAINT transaction_original_fk
        FOREIGN KEY (original_transaction_id)
        REFERENCES public.bank_transaction(transaction_id),

    CONSTRAINT transaction_amount_check
        CHECK (amount > 0),

    CONSTRAINT transaction_currency_check
        CHECK (currency = 'NGN'),

    CONSTRAINT transaction_type_check
        CHECK (transaction_type IN (
            'deposit',
            'withdrawal',
            'internal_transfer',
            'interbank_transfer',
            'reversal'
        )),

    CONSTRAINT transaction_status_check
        CHECK (status IN (
            'pending',
            'successful',
            'failed',
            'reversed'
        )),

    CONSTRAINT transaction_destination_check
        CHECK (
            (
                transaction_type = 'internal_transfer'
                AND destination_account_id IS NOT NULL
                AND beneficiary_id IS NULL
                AND original_transaction_id IS NULL
                AND source_account_id <> destination_account_id
            )
            OR
            (
                transaction_type = 'interbank_transfer'
                AND destination_account_id IS NULL
                AND beneficiary_id IS NOT NULL
                AND original_transaction_id IS NULL
            )
            OR
            (
                transaction_type IN ('deposit', 'withdrawal')
                AND destination_account_id IS NULL
                AND beneficiary_id IS NULL
                AND original_transaction_id IS NULL
            )
            OR
            (
                transaction_type = 'reversal'
                AND destination_account_id IS NULL
                AND beneficiary_id IS NULL
                AND original_transaction_id IS NOT NULL
            )
        )
);

-- Prevent multiple reversal records for the same transaction
CREATE UNIQUE INDEX transaction_one_reversal
    ON public.bank_transaction(original_transaction_id)
    WHERE original_transaction_id IS NOT NULL;

-- 6. Transaction audit table
CREATE TABLE public.transaction_audit (
    audit_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_id BIGINT NOT NULL,
    action VARCHAR(50) NOT NULL,
    description TEXT,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT audit_transaction_fk
        FOREIGN KEY (transaction_id)
        REFERENCES public.bank_transaction(transaction_id)
);

-- Additional rules requiring transaction logic:
-- Active account checks, balance updates, concurrent spending
-- protection, reversal eligibility, and authorised reversals
-- are not fully enforced by these table definitions.
-- Beneficiary ownership and transaction status transitions
-- also require additional validation.

COMMIT;
