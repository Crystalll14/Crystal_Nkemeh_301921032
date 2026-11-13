# Portfolio 4: NoSQL and Advanced Data Models

## Project Overview

This portfolio demonstrates the use of MongoDB for document-based storage and querying of fictional banking activity events in PurpleBank, a Nigerian digital bank.

PostgreSQL is used for core relational banking records, while MongoDB is evaluated as a complementary database for flexible transaction activity and event-history records.

## Document Model

A MongoDB database named `purplebank_events` contains a collection called `transaction_events`.

Each document represents one banking activity event and includes a unique event identifier, event type, timestamp, embedded customer information, embedded transaction details, and event-specific metadata.

The main fields are:

- `_id`: Unique event identifier.
- `event_type`: Type of banking activity.
- `occurred_at`: Timestamp of the activity.
- `customer`: Embedded customer identifier and name.
- `transaction`: Embedded transaction reference, type, amount, and currency.
- `details`: Additional information such as processing status, channel, destination bank, processing time, or failure reason.

The model uses embedded documents to group related information within individual event records.

## Implementation and Results

Four fictional banking activity documents were inserted into MongoDB using `insertMany()`.

The events represent an initiated interbank transfer, a completed interbank transfer, a completed withdrawal, and a failed interbank transfer attempt.

Three MongoDB queries were used to demonstrate document retrieval:

1. **Document count:** `countDocuments()` returned four records.
2. **Transaction history:** A query filtering by `transaction.reference` returned two events for `PB-TXN-004`, representing initiation and completion.
3. **Failed events:** A query filtering by `details.status` returned one failed interbank transfer event.

These operations demonstrate document insertion, querying embedded fields, filtering, and chronological sorting.

All records and event metadata are fictional. The MongoDB events were created independently and do not automatically update or synchronise with the PostgreSQL database.

## Why MongoDB Is Suitable

MongoDB provides a flexible document model for storing event information that varies between different banking activities.

For example, completed transfers may contain processing times, while failed transfers may contain error reasons. These fields can be stored within the `details` document without requiring identical attributes for every event.

Embedding related customer and transaction information also allows individual events to be retrieved as complete documents.

MongoDB is therefore suitable for demonstrating flexible activity logging and event-history storage in PurpleBank.

However, PostgreSQL remains more appropriate for the project's core account balances and transactional records because those operations depend on clearly defined relationships, constraints, and coordinated financial updates.

## Portfolio Files and Evidence

- [MongoDB Setup](Nkemeh_Crystal_P4_Setup.md)
- [MongoDB Implementation Script](Nkemeh_Crystal_P4_MongoDB.js)
- [MongoDB Connection Evidence](screenshots/Nkemeh_Crystal_P4_MongoDBConnection.png)
- [MongoDB Event Queries](screenshots/Nkemeh_Crystal_P4_EventsAndQueries.png)
- [Additional Query Results](screenshots/Nkemeh_Crystal_P4_EventsAndQueries_2.png)

## References

MongoDB. (n.d.). *Documents*. MongoDB documentation. https://www.mongodb.com/docs/manual/core/document/

MongoDB. (n.d.). *Query documents*. MongoDB documentation. https://www.mongodb.com/docs/manual/tutorial/query-documents/