-- PurpleBank: Portfolio 3 - Session B
-- Execute interactively, following the A -> B -> A -> B sequence.

SET application_name = 'p3_session_b';
BEGIN ISOLATION LEVEL READ COMMITTED;
SHOW transaction_isolation;
SELECT COUNT(*) AS visible_transactions FROM public.bank_transaction WHERE reference = 'PB-P3-CONCURRENT-001';

-- Expected: 0 visible records before Session A commits.
INSERT INTO public.bank_transaction (reference, source_account_id, transaction_type, amount, currency, status)
SELECT 'PB-P3-CONCURRENT-001', account_id, 'deposit', 2000.00, 'NGN', 'pending'
FROM public.account WHERE account_number = '0987654321';

-- STOP: This INSERT should wait. Switch to A, inspect lock and COMMIT.
-- Expected upon A's COMMIT: duplicate-key error in B.
ROLLBACK;

SELECT reference, transaction_type, amount, currency, status
FROM public.bank_transaction WHERE reference = 'PB-P3-CONCURRENT-001';
SELECT COUNT(*) AS final_transaction_count FROM public.bank_transaction WHERE reference = 'PB-P3-CONCURRENT-001';
