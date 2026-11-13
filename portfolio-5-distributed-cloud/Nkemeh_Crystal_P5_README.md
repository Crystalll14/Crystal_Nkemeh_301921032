# Portfolio 5 Distributed and Cloud Database Exercise

## Current setup

PurpleBank is a fictional Nigerian digital bank that uses PostgreSQL for customer accounts, balances, financial transactions, and related banking records. MongoDB is used to store fictional transaction activity events, including initiated, completed, and failed transfers.

Both databases were configured within a single GitHub Codespace for practical demonstrations. This is a development environment, not a distributed database deployment. No MongoDB replica set, sharding configuration, cloud database cluster, or failover experiment has been implemented.

## Proposed replication

To improve the availability of PurpleBank's transaction activity records, a three-member MongoDB replica set is proposed.

| Member | Starting role | Location |
|---|---|---|
| A | Primary – accepts event writes | Host 1 / Failure Zone A |
| B | Secondary – replicates events | Host 2 / Failure Zone B |
| C | Secondary – replicates events | Host 3 / Failure Zone C |

The primary server would accept new event records, while the secondary servers would asynchronously replicate changes.

For example, when PurpleBank records a `transfer_completed` event for transaction `PB-TXN-004`, the primary would store the event and the secondaries would replicate it.

Placing members in separate failure zones would reduce dependence on a single server or infrastructure location.

Reference: [MongoDB Replication](https://www.mongodb.com/docs/manual/replication/).

## Failure and consistency

If the primary server becomes unavailable, the remaining members could elect an eligible secondary as the new primary, provided a majority of voting members remains reachable.

During an election, new writes may be temporarily interrupted. If fewer than two members of the proposed three-member replica set can communicate, a writable primary cannot be elected.

For important banking events, the proposed system would use majority write acknowledgement, requiring acknowledgement from at least two data-bearing voting members before considering a write successful.

This improves protection against losing acknowledged event records during a single-member failure but introduces additional acknowledgement overhead.

Because replication is asynchronous, secondary servers may temporarily contain older information. Recent event queries would therefore prefer the primary.

PostgreSQL would remain the authoritative system for account balances and financial transactions. MongoDB event copies would not independently determine customer balances or transaction settlement.

References: [Replica Set Elections](https://www.mongodb.com/docs/v8.0/core/replica-set-elections/) and [Write Concern](https://www.mongodb.com/docs/v8.0/reference/write-concern/).

## Sharding and cloud deployment

Replication copies data across servers, while sharding divides data across multiple groups of servers.

PurpleBank's small MongoDB demonstration contains four fictional events, so sharding is unnecessary.

If event volumes increased substantially, sharding could be evaluated using actual workload measurements and query patterns to select an appropriate shard key.

A future cloud deployment could use a managed MongoDB service with database authentication, encrypted connections, restricted network access, monitoring, and scheduled backups.

Backup recovery should be tested through restoration exercises, since replication alone does not protect against accidental deletion or data corruption. Cloud deployment costs and service capabilities would also require evaluation.

MongoDB replication would protect MongoDB event records only. PostgreSQL would require a separate availability and recovery strategy, and synchronisation between both databases would need to be designed explicitly.

References: [MongoDB Sharding](https://www.mongodb.com/docs/manual/sharding/) and [MongoDB Atlas Backup](https://www.mongodb.com/docs/atlas/backup-restore-cluster/).