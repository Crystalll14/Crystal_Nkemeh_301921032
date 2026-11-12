# Portfolio 2: Query Processing and Optimisation

## Project Overview

This portfolio focuses on SQL query processing and performance optimisation using PurpleBank, a fictional Nigerian digital bank.

The objective is to demonstrate how SQL queries can retrieve and analyse banking information and how indexing can improve database query performance.

The portfolio uses PostgreSQL to execute queries involving customer accounts, banking transactions, and transaction histories. A separate benchmark dataset containing 100,000 fictional transaction-history records was created to evaluate query performance before and after indexing.

## 1. SQL Queries and Results

Three SQL queries were developed to retrieve and analyse records from PurpleBank's relational database.

### Query 1: Customer Fund Transfers

This query retrieves customers who initiated internal or interbank transfers, including their account numbers, transaction references, transaction types, amounts, and statuses.

The query uses `INNER JOIN` to connect the Customer, Account, and Transaction tables. A `WHERE` condition filters the results to include only internal and interbank transfers.

**Purpose:** To provide visibility into fund transfer activities and support transaction monitoring.

### Query 2: Accounts Without Outgoing Transfers

This query identifies PurpleBank accounts that have not initiated any internal or interbank transfers.

The query uses `NOT EXISTS` to identify accounts without matching outgoing transfer records.

**Purpose:** To identify accounts without recorded outgoing fund transfer activity, which may support customer engagement and account activity analysis.

### Query 3: Customer Transaction Counts

This query calculates the number of transaction records associated with each customer's source accounts.

It uses `LEFT JOIN`, `COUNT`, and `GROUP BY` to aggregate transaction activity while including customers who have no recorded transactions.

**Purpose:** To summarise customer transaction activity and support operational reporting.

The SQL statements and supporting query outputs are documented in the accompanying query script and screenshots.

## 2. Query Optimisation Experiment

### Objective

The optimisation experiment evaluates whether indexing the transaction date column improves the performance of a date-filtered query.

### Benchmark Dataset

A separate PostgreSQL schema named `p2_benchmark` was created for performance testing.

The `transaction_history` table contains 100,000 fictional transaction-history records generated using PostgreSQL's `generate_series()` function.

The records include transaction identifiers, account references, timestamps, amounts, currencies, and statuses. They are used exclusively for performance testing and do not modify actual account balances.

### Query Evaluated

The benchmark query counts transaction-history records created on January 1, 2005.

The query filters the `created_at` column using a date range and returns 24 matching records.

The same query was executed before and after creating an index to ensure a consistent comparison.

### Index Created

A B-tree index named `transaction_history_created_at_idx` was created on the `created_at` column.

```sql
CREATE INDEX transaction_history_created_at_idx
ON p2_benchmark.transaction_history (created_at);
```

The index was introduced to improve the efficiency of retrieving records within a specified date range.

## 3. Execution Plan and Performance Comparison

PostgreSQL's `EXPLAIN (ANALYZE, BUFFERS)` command was used to inspect the execution plans and measure query performance.

One warm-up execution was performed before collecting three measured execution times for each condition.

### Performance Results

| Measurement | Before Indexing | After Indexing |
|---|---|---|
| Scan type | Sequential Scan | Index Only Scan |
| Index used | None | transaction_history_created_at_idx |
| Matching records | 24 | 24 |
| Rows removed by filter | 99,976 | Not applicable |
| Heap fetches | Not applicable | 0 |
| Shared buffer hits | 1,152 | 3 |
| Execution time - Run 1 | 8.652 ms | 0.064 ms |
| Execution time - Run 2 | 7.132 ms | 0.050 ms |
| Execution time - Run 3 | 9.432 ms | 0.049 ms |
| **Median execution time** | **8.652 ms** | **0.050 ms** |

### Performance Analysis

Before indexing, PostgreSQL used a sequential scan (`Seq Scan`) to search the transaction-history table. The execution plan showed that 99,976 rows were removed by the filter, leaving 24 matching records. The three measured execution times were 8.652 ms, 7.132 ms, and 9.432 ms, producing a median execution time of 8.652 ms.

After creating the B-tree index, PostgreSQL switched to an `Index Only Scan` using `transaction_history_created_at_idx`. The execution plan showed 24 matching records, zero heap fetches, and a reduction in shared buffer hits from 1,152 to 3.

The three measured execution times after indexing were 0.064 ms, 0.050 ms, and 0.049 ms, producing a median execution time of 0.050 ms.

This represents an approximately **99.42% reduction in median execution time**, with the indexed query executing approximately **173 times faster** than the unindexed query.

The execution plans demonstrate that the index enabled PostgreSQL to locate matching records more efficiently, reducing the number of database pages accessed during query execution.

However, indexing does not guarantee the same improvement for every query. Its effectiveness depends on factors such as data volume, query selectivity, database statistics, caching, and system resources. Indexes also introduce additional storage requirements and maintenance overhead during data modifications.

## 4. Findings and Conclusion

The results demonstrate the importance of query optimisation in relational database systems.

The three SQL queries showed how banking records can be retrieved, filtered, joined, and aggregated to support operational reporting and transaction monitoring.

The indexing experiment demonstrated a substantial improvement in date-filtered query performance. PostgreSQL changed from a sequential scan to an index-only scan, reducing median execution time from 8.652 ms to 0.050 ms.

For PurpleBank, appropriate indexing strategies can support efficient retrieval of transaction histories, particularly as the volume of financial records increases.

The results are specific to the simulated benchmark environment and should not be interpreted as guaranteed performance improvements under all workloads.

## 5. Portfolio Files and Evidence

### SQL Scripts

- [SQL Queries](Crystal_Nkemeh_301921032_P2_Queries.sql) – Contains the three SQL queries used to retrieve and analyse PurpleBank banking records.
- [Optimisation Script](Crystal_Nkemeh_301921032_P2_Optimisation.sql) – Contains the benchmark dataset generation, execution plan analysis, indexing, and performance comparison SQL statements.

### Screenshots

- [Query Results](screenshots/P2_QueryResults.png) – Results of the SQL queries.
- [Additional Query Results](screenshots/P2_QueryResults_2.png) – Additional SQL query outputs.
- [Benchmark Records](screenshots/P2_BenchmarkRecords.png) – Verification of the 100,000 fictional transaction-history records.
- [Before Indexing](screenshots/P2_BeforeIndex.png) – Execution plans showing sequential scans before indexing.
- [After Indexing](screenshots/P2_AfterIndex.png) – Execution plans showing index-only scans after indexing.
- [Final Transaction Count](screenshots/P2_FinalCount.png) – Verification that the filtered query returns 24 records.

## 6. References

PostgreSQL Global Development Group. (n.d.). *Using EXPLAIN*. PostgreSQL documentation. https://www.postgresql.org/docs/current/using-explain.html

PostgreSQL Global Development Group. (n.d.). *Indexes*. PostgreSQL documentation. https://www.postgresql.org/docs/current/indexes.html

PostgreSQL Global Development Group. (n.d.). *CREATE INDEX*. PostgreSQL documentation. https://www.postgresql.org/docs/current/sql-createindex.html