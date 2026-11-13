
-- =====================================================
-- PurpleBank: Portfolio 3
-- Transactions and Concurrency
-- Step 14: Demonstrating COMMIT and ROLLBACK
-- =====================================================

-- Database: purplebank_portfolio
-- Purpose:
-- Demonstrate how PostgreSQL uses COMMIT to save
-- successful changes and ROLLBACK to undo changes
-- when a transaction encounters an error.

-- All records are fictional and used for academic testing.


-- =====================================================
-- 1. VERIFY EXISTING ACCOUNT BALANCES
-- =====================================================

-- Check account balances before the experiments.

SELECT
    a.account_id,
    c.full_name,
    a.account_number,
    a.balance,
    a.status
FROM public.account AS a
JOIN public.customer AS c
    ON a.customer_id = c.customer_id
ORDER BY a.account_id;

-- Expected initial balances:
-- Account 1 (Ada Okafor): 100000.00 NGN
-- Account 2 (Tunde Bello): 70000.00 NGN
-- Account 3 (Ada Okafor): 25000.00 NGN


-- =====================================================
-- 2. DEMONSTRATE A SUCCESSFUL TRANSACTION (COMMIT)
-- =====================================================

-- Scenario:
-- Ada Okafor withdraws NGN 10000 from account 1.
-- The transaction should succeed because the account
-- is active and has sufficient funds.

-- Start the transaction.

BEGIN;

-- Deduct NGN 10000 from Ada's account.
-- The WHERE conditions prevent withdrawals
-- from inactive accounts or insufficient balances.

UPDATE public.account
SET balance = balance - 10000.00
WHERE account_id = 1
  AND status = 'active'
  AND balance >= 10000.00;

-- Expected output: UPDATE 1
-- If UPDATE 0 appears, the conditions were not met.

-- View the updated balance before committing.

SELECT
    account_id,
    account_number,
    balance
FROM public.account
WHERE account_id = 1;

-- Expected balance: 90000.00 NGN

-- Save the successful transaction permanently.

COMMIT;

-- Expected output: COMMIT

-- Verify that the updated balance was saved.

SELECT
    account_id,
    account_number,
    balance
FROM public.account
WHERE account_id = 1;

-- Expected balance after COMMIT: 90000.00 NGN


-- =====================================================
-- 3. DEMONSTRATE A FAILED TRANSACTION (ROLLBACK)
-- =====================================================

-- Scenario:
-- A second operation temporarily deducts NGN 5000
-- from Ada's account.
--
-- An invalid account insertion is then attempted.
-- The negative balance violates the existing
-- account_balance_check constraint.
--
-- ROLLBACK should undo the temporary deduction.

-- Start another transaction.

BEGIN;

-- Temporarily deduct NGN 5000.

UPDATE public.account
SET balance = balance - 5000.00
WHERE account_id = 1
  AND status = 'active'
  AND balance >= 5000.00;

-- Expected output: UPDATE 1

-- Check the temporary balance.

SELECT
    account_id,
    account_number,
    balance
FROM public.account
WHERE account_id = 1;

-- Expected temporary balance: 85000.00 NGN

-- Deliberately attempt to insert an invalid account.
-- This should fail because the balance is negative.

INSERT INTO public.account
(
    customer_id,
    account_number,
    balance,
    currency,
    status
)
VALUES
(
    1,
    '1111111199',
    -500.00,
    'NGN',
    'active'
);

-- EXPECTED ERROR:
-- Violates check constraint "account_balance_check".
--
-- PostgreSQL should reject the invalid insertion.
-- The current transaction enters a failed state.

-- Undo all changes made in this transaction.

ROLLBACK;

-- Expected output: ROLLBACK


-- =====================================================
-- 4. VERIFY THE ROLLBACK
-- =====================================================

-- Confirm that Ada's temporary NGN 5000 deduction
-- was undone.

SELECT
    account_id,
    account_number,
    balance
FROM public.account
WHERE account_id = 1;

-- Expected balance: 90000.00 NGN
-- This confirms that the earlier COMMIT remains
-- saved while the later changes were rolled back.


-- =====================================================
-- 5. VERIFY THAT THE INVALID ACCOUNT WAS NOT CREATED
-- =====================================================

SELECT *
FROM public.account
WHERE account_number = '1111111199';

-- Expected result: 0 rows
-- The invalid account should not exist.


-- =====================================================
-- 6. VERIFY ALL ACCOUNT BALANCES
-- =====================================================

SELECT
    a.account_id,
    c.full_name,
    a.account_number,
    a.balance,
    a.status
FROM public.account AS a
JOIN public.customer AS c
    ON a.customer_id = c.customer_id
ORDER BY a.account_id;

-- Expected final balances:
-- Account 1 (Ada Okafor): 90000.00 NGN
-- Account 2 (Tunde Bello): 70000.00 NGN
-- Account 3 (Ada Okafor): 25000.00 NGN


-- =====================================================
-- 7. CONCLUSION
-- =====================================================

-- COMMIT permanently saved the successful NGN 10000
-- balance deduction.

-- ROLLBACK cancelled the subsequent NGN 5000
-- deduction after a constraint violation.

-- PostgreSQL preserved the earlier committed balance
-- and prevented the invalid account from being saved.

-- The experiment demonstrates transaction atomicity
-- and the persistence of committed changes.

