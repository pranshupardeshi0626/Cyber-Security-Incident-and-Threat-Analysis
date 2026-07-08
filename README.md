# **Cyber-Security-Incident-Threat-Analysis**

A SQL analytics project that analyzes security incidents, threat intelligence, SLA performance, and financial impact to support SOC (Security Operations Center) decision-making.

## **🛡️ Cybersecurity Incident & Threat Analysis – SQL Project**


### **📌 Project Overview**

This project analyzes a Managed Security Service Provider's (MSSP) incident data using SQL to help answer a critical business question:

Where should the SOC focus its resources — faster incident triage, stronger asset patching, or better SLA and analyst management — to reduce risk and financial loss across clients?

The project uses real-world SOC scenarios, SQL queries, and data analysis to generate insights that support security operations and account-risk decision-making.

### **🎯 Business Problem**

As organizations face a growing volume of cyber threats, a SOC managing multiple clients must decide how to allocate limited analyst time and budget.

The project answers questions such as:

* Which incidents and clients carry the highest risk and cost?

* Are critical assets being patched on time?

* Is the SOC meeting its SLA commitments?

* Which analysts and shifts need support?

* This project answers these questions through data-driven analysis.


### **📊 Project Objectives**

* Analyze incident volume, severity, and status across clients.
* Identify unpatched critical assets and unresolved threats.
* Evaluate financial impact and SLA breach risk per client.
* Measure analyst and shift-level performance.
* Rank clients by overall risk score (SLA breaches + cost).
* Recommend where the SOC should focus next.

### **🗂️ Database Information**

The project consists of 8 relational tables.

| Table | Description |
|---|---|
| `clients` | Client company details, industry, contract tier & value |
| `analysts` | SOC analyst details, shift, specialization, seniority |
| `threat_intel` | Known threats, actors, CVEs, and severity/CVSS scores |
| `assets` | Client assets (servers, endpoints, etc.), criticality, patch status |
| `sla_contracts` | Per-client SLA targets by priority (response/resolution time) |
| `incidents` | Core incident log (Fact Table) — detection, status, priority |
| `response_actions` | Analyst actions taken per incident and their outcome |
| `financial_impact` | Cost incurred per incident by category |


Database Import Order
```
clients → analysts → threat_intel → assets → sla_contracts → incidents → response_actions → financial_impact
```
Fact Table: `incidents`

All other tables act as Dimension/Supporting Tables.

### **🧩 Entity Relationship Model**

The database follows a relational model where:

* Clients own assets and hold SLA contracts.
* Assets and threat intel feed into incidents.
* Analysts are assigned to incidents and log response actions.
* Incidents generate financial impact records.

### **📈 Project Structure**

The analysis is divided into 4 Modules.

### **🚨 Module 1: Incident Triage & Detection**

Goal
Understand incident volume, status, and detection sources to prioritize triage.

Key Queries
* Incident counts by status
* Open P1 (critical) incidents still unresolved
* Incident counts by detection source
* Incidents from the last 90 days by client and asset
  
  * Business Decision 
* Prioritize clearing the open P1 backlog and strengthen the detection sources generating the most  alerts.

### **🔓 Module 2: Asset & Vulnerability Exposure**

Goal
Identify weak points in client infrastructure before they turn into incidents.

Key Queries
* Critical assets unpatched for 180+ days (or never patched)
* Threat intel entries that never triggered an actual incident

  * Business Decision 
* Fast-track patching for overdue critical assets and review whether stale threat intel feeds are still relevant.

### **💰 Module 3: Threat & Financial Impact**

Goal
Identify which threats and clients drive the most damage and cost.

Key Queries
* Records-affected impact bucketed as No Impact / Low / Medium / High
* Total incidents & average records affected per client
* Top 5 threat types behind P1 incidents
* Clients whose financial impact exceeds the average
  
  * Business Decision 
* Focus threat-hunting on the top recurring threat types and give high-cost clients closer monitoring.

### **📋 Module 4: SLA & Analyst Performance**

Goal
Evaluate whether the SOC is meeting SLA commitments and using analyst time efficiently.

Key Queries
* Average resolution time per priority level
* Clients/priorities with no matching SLA contract on file
* Top 5 analysts with the most failed response actions
* View: per-client SLA breach rate
* Final ranked list of top 15 highest-risk clients (breach rate + cost, weighted)
* Incident load per analyst per shift
  * Business Decision 
* Close SLA contract gaps, coach high-failure analysts, rebalance staffing across shifts, and prioritize account management for the top-ranked risk clients.

### **🛠 SQL Concepts Used**

This project demonstrates practical use of:

* SELECT
* WHERE
* ORDER BY
* GROUP BY
* HAVING logic via subqueries
* CASE (impact bucketing)
* Aggregate Functions (COUNT, SUM, AVG, MIN, MAX)
* INNER JOIN
* LEFT JOIN
* Subqueries (correlated & non-correlated)
* Common Table Expressions (CTEs)
* Views (CREATE VIEW)
* Window Functions
* RANK()
* Aggregate OVER() (normalized scoring)
* Date Functions (TIMESTAMPDIFF, INTERVAL, CURRENT_DATE)
* Conditional Logic
* Risk Scoring
* Business Analytics

### **📊 Business Insights**

The project answers questions such as:

1) What's the current spread of incident statuses?
2) Which P1 incidents are still open and need urgent attention?
3) Which assets are overdue for patching?
4) Which threat types are behind the most critical incidents?
5) Which clients are the costliest to protect?
6) Is the SOC hitting its SLA targets per priority?
7) Which clients have no SLA coverage for a given priority?
8) Which analysts have the most failed response actions?
9) Which clients pose the highest overall risk (breach rate + cost)?
10) How is incident load distributed across analysts and shifts?
    
### **📌 Final Recommendation**

The analysis suggests a balanced strategy:

✅ Fix the highest-leverage gaps first — unpatched critical assets and missing SLA contracts.

✅ Direct analyst effort toward the top recurring threat types and the highest-risk clients identified by the risk-ranking model.

Rather than treating triage, patching, and SLA management separately, the data supports a unified, risk-scored approach to allocating SOC resources.

### **🚀 Skills Demonstrated**

SQL
Relational Database Design
Security/SOC Domain Analysis
Business & Risk Analytics
Window Functions & CTEs
Views for Reusable Metrics
Data Interpretation
Problem Solving
Decision Support Analytics

📂 Project Files
```
Cyber-Security-Incident-Threat-Analysis/
│
├── data tables/                     # CSVs: clients, analysts, threat_intel, assets,
│                                     #  sla_contracts, incidents, response_actions, financial_impact
├── project.sql                      # Database & table creation
├── project_business_problem.sql     # 16 business questions solved in SQL
├── ER diagram.png
└── README.md
```


📄 Conclusion
This project demonstrates how SQL can be used not only to retrieve data but also to solve real-world SOC problems. By analyzing incident triage, asset risk, threat impact, and SLA/analyst performance, the project provides actionable recommendations for reducing risk and improving security operations efficiency.
