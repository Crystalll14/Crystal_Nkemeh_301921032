-- PurpleBank: Portfolio 3 - Session A
-- Execute interactively. STOP and switch sessions where marked.

-- Check that the test reference is unused before beginning.
SELECT COUNT(*) AS existing_records FROM public.bank_transaction WHERE reference = 'PB-P3-CONCURRENT-001';

SET application_name = 'p3_session_a';
BEGIN ISOLATION LEVEL READ COMMITTED;
SHOW transaction_isolation;
INSERT INTO public.bank_transaction (reference, source_account_id, transaction_type, amount, currency, status)
SELECT 'PB-P3-CONCURRENT-001', account_id, 'deposit', 1000.00, 'NGN', 'pending'
FROM public.account WHERE account_number = '0123456789';

-- STOP: Do not commit. Switch to Session B.
-- After Session B starts its conflicting INSERT, return here.
SELECT application_name, wait_event_type FROM pg_stat_activity WHERE application_name = 'p3_session_b';

-- Capture waiting screenshot, then save Session A's insert.
COMMIT;
