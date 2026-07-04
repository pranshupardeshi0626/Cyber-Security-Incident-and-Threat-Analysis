create database project;
use project;
-- 1. CLIENTS
CREATE TABLE clients (
    client_id            VARCHAR(10) PRIMARY KEY,
    client_name          VARCHAR(150) NOT NULL,
    industry             VARCHAR(50),
    contract_tier        VARCHAR(20),
    country               VARCHAR(50),
    contract_start_date  DATE,
    contract_value_usd   DECIMAL(12,2),
    employee_count       INT
);

-- 2. ANALYSTS
CREATE TABLE analysts (
    analyst_id        VARCHAR(10) PRIMARY KEY,
    analyst_name      VARCHAR(100) NOT NULL,
    email             VARCHAR(150),
    hire_date         DATE,
    shift             VARCHAR(20),
    specialization    VARCHAR(50),
    seniority_level   VARCHAR(10)
);

-- 3. THREAT_INTEL
CREATE TABLE threat_intel (
    threat_id         VARCHAR(10) PRIMARY KEY,
    threat_type       VARCHAR(50),
    threat_actor      VARCHAR(50),
    severity          VARCHAR(20),
    cve_id            VARCHAR(30),
    cvss_score        DECIMAL(3,1),
    first_seen_date   DATE
);

select * from threat_intel;

-- 4. ASSETS (depends on clients)
CREATE TABLE assets (
    asset_id           VARCHAR(10) PRIMARY KEY,
    client_id          VARCHAR(10) NOT NULL,
    asset_type         VARCHAR(50),
    operating_system   VARCHAR(50),
    criticality        VARCHAR(20),
    ip_address         VARCHAR(50),
    deployed_date      DATE,
    last_patch_date    DATE,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

-- 5. SLA_CONTRACTS (depends on clients)
CREATE TABLE sla_contracts (
    sla_id                     VARCHAR(10) PRIMARY KEY,
    client_id                  VARCHAR(10) NOT NULL,
    priority                   VARCHAR(5),
    target_response_minutes    INT,
    target_resolution_hours    INT,
    breach_penalty_pct         DECIMAL(5,2),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

-- 6. INCIDENTS (depends on clients, assets, threat_intel, analysts)
CREATE TABLE incidents (
    incident_id            VARCHAR(10) PRIMARY KEY,
    client_id              VARCHAR(10) NOT NULL,
    asset_id               VARCHAR(10) NOT NULL,
    threat_id              VARCHAR(10),
    detected_datetime      DATETIME NOT NULL,
    resolved_datetime      DATETIME,
    status                 VARCHAR(20),
    priority               VARCHAR(5),
    detection_source       VARCHAR(50),
    assigned_analyst_id    VARCHAR(10),
    records_affected       INT,
    description            TEXT,
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id),
    FOREIGN KEY (threat_id) REFERENCES threat_intel(threat_id),
    FOREIGN KEY (assigned_analyst_id) REFERENCES analysts(analyst_id)
);

-- 7. RESPONSE_ACTIONS (depends on incidents, analysts)
CREATE TABLE response_actions (
    action_id          VARCHAR(10) PRIMARY KEY,
    incident_id        VARCHAR(10) NOT NULL,
    analyst_id         VARCHAR(10),
    action_type        VARCHAR(50),
    action_datetime    DATETIME,
    result             VARCHAR(20),
    notes              TEXT,
    FOREIGN KEY (incident_id) REFERENCES incidents(incident_id),
    FOREIGN KEY (analyst_id) REFERENCES analysts(analyst_id)
);

-- 8. FINANCIAL_IMPACT (depends on incidents)
CREATE TABLE financial_impact (
    financial_id      VARCHAR(10) PRIMARY KEY,
    incident_id       VARCHAR(10) NOT NULL,
    cost_category     VARCHAR(50),
    amount_usd        DECIMAL(12,2),
    currency          VARCHAR(10),
    recorded_date     DATE,
    FOREIGN KEY (incident_id) REFERENCES incidents(incident_id)
);


select * from  clients;
select * from analysts;
select * from threat_intel;
select * from assets;
select * from sla_contracts;
select * from incidents;
select * from response_actions;
select * from financial_impact;
