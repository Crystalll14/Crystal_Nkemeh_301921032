
-- Q1: Find internal and interbank transfers
-- together with the customers who initiated them.

SELECT
    c.full_name,
    a.account_number,
    t.reference,
    t.transaction_type,
    t.amount,
    t.status
FROM public.bank_transaction AS t
JOIN public.account AS a
    ON t.source_account_id = a.account_id
JOIN public.customer AS c
    ON a.customer_id = c.customer_id
WHERE t.transaction_type IN (
    'internal_transfer',
    'interbank_transfer'
)
ORDER BY t.reference;


-- Q2: Find accounts without outgoing fund transfers.

SELECT
    a.account_number,
    c.full_name,
    a.balance,
    a.status
FROM public.account AS a
JOIN public.customer AS c
    ON a.customer_id = c.customer_id
WHERE NOT EXISTS (
    SELECT 1
    FROM public.bank_transaction AS t
    WHERE t.source_account_id = a.account_id
      AND t.transaction_type IN (
          'internal_transfer',
          'interbank_transfer'
      )
)
ORDER BY a.account_number;


-- Q3: Count transactions initiated or recorded
-- against each customer's source accounts.
-- Include customers who have zero transactions.

SELECT
    c.full_name,
    COUNT(t.transaction_id) AS total_transactions
FROM public.customer AS c
LEFT JOIN public.account AS a
    ON c.customer_id = a.customer_id
LEFT JOIN public.bank_transaction AS t
    ON a.account_id = t.source_account_id
GROUP BY c.customer_id, c.full_name
ORDER BY c.full_name;
