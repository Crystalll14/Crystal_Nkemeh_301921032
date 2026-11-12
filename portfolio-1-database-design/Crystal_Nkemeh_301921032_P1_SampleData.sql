
-- PurpleBank: Portfolio 1 Sample Data
-- Fictional records for testing the database schema.

BEGIN;

-- 1. Register two customers
INSERT INTO public.customer (full_name, email, phone_number)
VALUES
('Ada Okafor', 'ada@example.com', '08000000001'),
('Tunde Bello', 'tunde@example.com', '08000000002');

-- 2. Register two fictional external banks
INSERT INTO public.bank (bank_name, bank_code)
VALUES
('Example Commercial Bank', '991'),
('Sample Trust Bank', '992');

-- 3. Create three PurpleBank accounts
INSERT INTO public.account
(customer_id, account_number, balance, currency, status)
VALUES
(
    (SELECT customer_id FROM public.customer
     WHERE email = 'ada@example.com'),
    '0123456789', 100000.00, 'NGN', 'active'
),
(
    (SELECT customer_id FROM public.customer
     WHERE email = 'tunde@example.com'),
    '0987654321', 70000.00, 'NGN', 'active'
),
(
    (SELECT customer_id FROM public.customer
     WHERE email = 'ada@example.com'),
    '0234567890', 25000.00, 'NGN', 'active'
);

-- 4. Save two external beneficiaries
INSERT INTO public.beneficiary
(customer_id, bank_id, account_number, account_name)
VALUES
(
    (SELECT customer_id FROM public.customer
     WHERE email = 'ada@example.com'),
    (SELECT bank_id FROM public.bank
     WHERE bank_code = '991'),
    '1234567890', 'Chidi Eze'
),
(
    (SELECT customer_id FROM public.customer
     WHERE email = 'tunde@example.com'),
    (SELECT bank_id FROM public.bank
     WHERE bank_code = '992'),
    '2345678901', 'Ngozi Obi'
);

-- 5. Record a successful deposit
INSERT INTO public.bank_transaction
(reference, source_account_id, transaction_type,
 amount, currency, status)
VALUES
(
    'PB-TXN-001',
    (SELECT account_id FROM public.account
     WHERE account_number = '0123456789'),
    'deposit', 50000.00, 'NGN', 'successful'
);

-- 6. Record a successful withdrawal
INSERT INTO public.bank_transaction
(reference, source_account_id, transaction_type,
 amount, currency, status)
VALUES
(
    'PB-TXN-002',
    (SELECT account_id FROM public.account
     WHERE account_number = '0987654321'),
    'withdrawal', 5000.00, 'NGN', 'successful'
);

-- 7. Record a successful internal transfer
INSERT INTO public.bank_transaction
(reference, source_account_id, destination_account_id,
 transaction_type, amount, currency, status)
VALUES
(
    'PB-TXN-003',
    (SELECT account_id FROM public.account
     WHERE account_number = '0123456789'),
    (SELECT account_id FROM public.account
     WHERE account_number = '0987654321'),
    'internal_transfer', 15000.00, 'NGN', 'successful'
);

-- 8. Record a simulated interbank transfer
INSERT INTO public.bank_transaction
(reference, source_account_id, beneficiary_id,
 transaction_type, amount, currency, status)
VALUES
(
    'PB-TXN-004',
    (SELECT account_id FROM public.account
     WHERE account_number = '0123456789'),
    (SELECT beneficiary_id FROM public.beneficiary
     WHERE account_number = '1234567890'
       AND bank_id = (
           SELECT bank_id FROM public.bank
           WHERE bank_code = '991'
       )),
    'interbank_transfer', 10000.00, 'NGN', 'successful'
);

-- 9. Record a reversal of the withdrawal
INSERT INTO public.bank_transaction
(reference, source_account_id, original_transaction_id,
 transaction_type, amount, currency, status)
VALUES
(
    'PB-TXN-005',
    (SELECT source_account_id
     FROM public.bank_transaction
     WHERE reference = 'PB-TXN-002'),
    (SELECT transaction_id
     FROM public.bank_transaction
     WHERE reference = 'PB-TXN-002'),
    'reversal', 5000.00, 'NGN', 'successful'
);

-- 10. Record audit events
INSERT INTO public.transaction_audit
(transaction_id, action, description)
SELECT transaction_id, 'CREATED',
       'Fictional banking transaction recorded'
FROM public.bank_transaction
WHERE reference IN (
    'PB-TXN-001',
    'PB-TXN-002',
    'PB-TXN-003',
    'PB-TXN-004',
    'PB-TXN-005'
);

COMMIT;
