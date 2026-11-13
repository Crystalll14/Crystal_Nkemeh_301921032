
-- PurpleBank: Portfolio 1 Constraint Tests
-- These INSERT statements are deliberately invalid.
-- Each test should produce an ERROR.
-- Run only after the valid sample data has been inserted.

-- Test 1: Customer name cannot be NULL.
-- Expected: NOT NULL violation.
INSERT INTO public.customer
(full_name, email, phone_number)
VALUES
(NULL, 'missingname@example.com', '08000000003');

-- Test 2: Customer email must be unique.
-- Expected: duplicate key violation.
INSERT INTO public.customer
(full_name, email, phone_number)
VALUES
('Another Ada', 'ada@example.com', '08000000004');

-- Test 3: Account must reference an existing customer.
-- Expected: account_customer_fk violation.
INSERT INTO public.account
(customer_id, account_number, balance, currency, status)
VALUES
(-1, '1111111111', 1000.00, 'NGN', 'active');

-- Test 4: Account number must be unique.
-- Expected: duplicate account number.
INSERT INTO public.account
(customer_id, account_number, balance, currency, status)
VALUES
(
    (SELECT customer_id FROM public.customer
     WHERE email = 'ada@example.com'),
    '0123456789', 1000.00, 'NGN', 'active'
);

-- Test 5: Account balance cannot be negative.
-- Expected: account_balance_check violation.
INSERT INTO public.account
(customer_id, account_number, balance, currency, status)
VALUES
(
    (SELECT customer_id FROM public.customer
     WHERE email = 'ada@example.com'),
    '1111111112', -100.00, 'NGN', 'active'
);

-- Test 6: Account currency must be NGN.
-- Expected: account_currency_check violation.
INSERT INTO public.account
(customer_id, account_number, balance, currency, status)
VALUES
(
    (SELECT customer_id FROM public.customer
     WHERE email = 'ada@example.com'),
    '1111111113', 1000.00, 'USD', 'active'
);

-- Test 7: Account status must be valid.
-- Expected: account_status_check violation.
INSERT INTO public.account
(customer_id, account_number, balance, currency, status)
VALUES
(
    (SELECT customer_id FROM public.customer
     WHERE email = 'ada@example.com'),
    '1111111114', 1000.00, 'unknown'
);

-- Test 8: Bank codes must be unique.
-- Expected: duplicate bank code.
INSERT INTO public.bank
(bank_name, bank_code)
VALUES
('Duplicate Example Bank', '991');

-- Test 9: Beneficiary bank must exist.
-- Expected: beneficiary_bank_fk violation.
INSERT INTO public.beneficiary
(customer_id, bank_id, account_number, account_name)
VALUES
(
    (SELECT customer_id FROM public.customer
     WHERE email = 'ada@example.com'),
    -1, '3456789012', 'Test Beneficiary'
);

-- Test 10: Transaction amount must be positive.
-- Expected: transaction_amount_check violation.
INSERT INTO public.bank_transaction
(reference, source_account_id, transaction_type,
 amount, currency, status)
VALUES
(
    'PB-TEST-010',
    (SELECT account_id FROM public.account
     WHERE account_number = '0123456789'),
    'deposit', -500.00, 'NGN', 'pending'
);

-- Test 11: Transaction status must be valid.
-- Expected: transaction_status_check violation.
INSERT INTO public.bank_transaction
(reference, source_account_id, transaction_type,
 amount, currency, status)
VALUES
(
    'PB-TEST-011',
    (SELECT account_id FROM public.account
     WHERE account_number = '0123456789'),
    'deposit', 500.00, 'NGN', 'cancelled'
);

-- Test 12: Transaction type must be supported.
-- Expected: transaction_type_check violation.
INSERT INTO public.bank_transaction
(reference, source_account_id, transaction_type,
 amount, currency, status)
VALUES
(
    'PB-TEST-012',
    (SELECT account_id FROM public.account
     WHERE account_number = '0123456789'),
    'loan', 500.00, 'NGN', 'pending'
);

-- Test 13: Internal transfers require a destination.
-- Expected: transaction_destination_check violation.
INSERT INTO public.bank_transaction
(reference, source_account_id, transaction_type,
 amount, currency, status)
VALUES
(
    'PB-TEST-013',
    (SELECT account_id FROM public.account
     WHERE account_number = '0123456789'),
    'internal_transfer', 500.00, 'NGN', 'pending'
);

-- Test 14: A successful transaction can only
-- have one reversal record.
-- Expected: transaction_one_reversal duplicate key error.
INSERT INTO public.bank_transaction
(reference, source_account_id, original_transaction_id,
 transaction_type, amount, currency, status)
VALUES
(
    'PB-TEST-014',
    (SELECT source_account_id
     FROM public.bank_transaction
     WHERE reference = 'PB-TXN-002'),
    (SELECT transaction_id
     FROM public.bank_transaction
     WHERE reference = 'PB-TXN-002'),
    'reversal', 5000.00, 'NGN', 'successful'
);

-- Test 15: Audit must reference an existing transaction.
-- Expected: audit_transaction_fk violation.
INSERT INTO public.transaction_audit
(transaction_id, action, description)
VALUES
(-1, 'CREATED', 'Invalid audit test');

-- Final verification: count surviving valid records.
SELECT 'customer' AS table_name, COUNT(*) AS row_count
FROM public.customer
UNION ALL
SELECT 'bank', COUNT(*) FROM public.bank
UNION ALL
SELECT 'account', COUNT(*) FROM public.account
UNION ALL
SELECT 'beneficiary', COUNT(*) FROM public.beneficiary
UNION ALL
SELECT 'bank_transaction', COUNT(*) FROM public.bank_transaction
UNION ALL
SELECT 'transaction_audit', COUNT(*) FROM public.transaction_audit;
