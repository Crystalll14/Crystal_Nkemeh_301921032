
 // PurpleBank - Portfolio 4
 // NoSQL Database Implementation using MongoDB
 // Fictional banking transaction activity records


 // ==========================================
 // 1. SELECT THE PURPLEBANK DATABASE
 // ==========================================

 db = db.getSiblingDB("purplebank_events");


 // ==========================================
 // 2. INSERT FOUR FICTIONAL BANKING EVENTS
 // ==========================================

 db.transaction_events.insertMany([
   {
     _id: "EVT001",
     event_type: "transfer_initiated",
     occurred_at: ISODate("2026-10-15T09:00:00Z"),
     customer: {
       customer_id: 1,
       full_name: "Ada Okafor"
     },
     transaction: {
       reference: "PB-TXN-004",
       type: "interbank_transfer",
       amount: 10000,
       currency: "NGN"
     },
     details: {
       destination_bank: "Example Commercial Bank",
       channel: "mobile_app",
       status: "pending"
     }
   },
   {
     _id: "EVT002",
     event_type: "transfer_completed",
     occurred_at: ISODate("2026-10-15T09:02:00Z"),
     customer: {
       customer_id: 1,
       full_name: "Ada Okafor"
     },
     transaction: {
       reference: "PB-TXN-004",
       type: "interbank_transfer",
       amount: 10000,
       currency: "NGN"
     },
     details: {
       destination_bank: "Example Commercial Bank",
       status: "successful",
       processing_time_seconds: 120
     }
   },
   {
     _id: "EVT003",
     event_type: "withdrawal_completed",
     occurred_at: ISODate("2026-10-16T11:30:00Z"),
     customer: {
       customer_id: 2,
       full_name: "Tunde Bello"
     },
     transaction: {
       reference: "PB-TXN-002",
       type: "withdrawal",
       amount: 5000,
       currency: "NGN"
     },
     details: {
       channel: "agent",
       status: "successful"
     }
   },
   {
     _id: "EVT004",
     event_type: "transfer_failed",
     occurred_at: ISODate("2026-10-17T14:15:00Z"),
     customer: {
       customer_id: 2,
       full_name: "Tunde Bello"
     },
     transaction: {
       reference: "PB-SIM-FAILED-001",
       type: "interbank_transfer",
       amount: 7500,
       currency: "NGN"
     },
     details: {
       destination_bank: "Sample Trust Bank",
       status: "failed",
       failure_reason: "Simulated network timeout"
     }
   }
 ]);


 // ==========================================
 // 3. QUERY 1: COUNT ALL BANKING EVENTS
 // ==========================================

 db.transaction_events.countDocuments({});


 // ==========================================
 // 4. QUERY 2: VIEW TRANSFER EVENT HISTORY
 // ==========================================

 db.transaction_events.find(
   { "transaction.reference": "PB-TXN-004" },
   {
     _id: 1,
     event_type: 1,
     occurred_at: 1,
     details: 1
   }
 ).sort({ occurred_at: 1, _id: 1 }).toArray();


 // ==========================================
 // 5. QUERY 3: VIEW FAILED BANKING EVENTS
 // ==========================================

 db.transaction_events.find(
   { "details.status": "failed" }
 ).toArray();


 // End of PurpleBank MongoDB implementation.
