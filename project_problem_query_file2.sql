use project;

-- Q1. List all distinct status values in incidents, with counts.
SELECT status,COUNT(*) AS total_incidents
FROM   incidents
GROUP  BY status
ORDER  BY total_incidents DESC;

-- Q2. Retrieve all P1 incidents that are still Open.
SELECT incident_id, client_id, asset_id, detected_datetime,
priority, status, detection_source
FROM   incidents
WHERE  priority = 'P1'
AND  status   = 'Open'
ORDER  BY detected_datetime;

-- Q3. Find all clients headquartered in the USA.
SELECT client_id, client_name, industry, contract_tier,
country, contract_value_usd
FROM   clients
WHERE  country = 'USA'
ORDER  BY contract_value_usd DESC;

-- Q4. Count the total number of incidents per detection_source.
SELECT detection_source,
COUNT(*) AS total_incidents
FROM   incidents
GROUP  BY detection_source
ORDER  BY total_incidents DESC;

-- Q5. Critical assets with a patch older than 180 days, or no patch date at all.
SELECT asset_id, client_id, asset_type, criticality,last_patch_date
FROM  assets
WHERE  criticality = 'Critical'
AND  (last_patch_date IS NULL
OR last_patch_date < CURRENT_DATE - INTERVAL 180 DAY)
ORDER  BY last_patch_date;

-- Q6. Client name, asset type, and priority for every incident in the last 90 days.
SELECT c.client_name, a.asset_type, i.priority,
       i.detected_datetime, i.status
FROM   incidents i
JOIN   clients c ON i.client_id = c.client_id
JOIN   assets  a ON i.asset_id  = a.asset_id
WHERE  i.detected_datetime >= CURRENT_DATE - INTERVAL 90 DAY
ORDER  BY i.detected_datetime DESC;

-- Q7. Bucket records_affected using CASE WHEN.
SELECT incident_id, records_affected,
CASE
WHEN records_affected = 0 THEN 'No Impact'
WHEN records_affected BETWEEN 1  AND 1000 THEN 'Low'
WHEN records_affected BETWEEN 1001  AND 50000 THEN 'Medium'
WHEN records_affected > 50000 THEN 'High'
ELSE 'Unknown'
END AS impact_level
FROM   incidents
ORDER  BY records_affected DESC;

-- records affected 
SELECT
MIN(records_affected) AS min_records,
MAX(records_affected) AS max_records,
AVG(records_affected) AS avg_records
FROM incidents;

-- Q8. Total incidents and average records_affected per client.
SELECT client_id,COUNT(*) AS total_incidents,
ROUND(AVG(records_affected), 2) AS avg_records_affected
FROM   incidents
GROUP  BY client_id
ORDER  BY total_incidents DESC;

-- 9.Show the top 5 analysts with the most failures
SELECT ra.analyst_id,
an.analyst_name,
an.shift,
COUNT(*) AS failed_actions
FROM response_actions ra
JOIN analysts an
ON ra.analyst_id = an.analyst_id
WHERE ra.result = 'Failed'
GROUP BY ra.analyst_id, an.analyst_name, an.shift
ORDER BY failed_actions DESC
LIMIT 5;

-- Q10. Top 5 most common threat_type values among P1 incidents.
SELECT t.threat_type,
COUNT(*) AS total_p1_incidents
FROM   incidents i
JOIN   threat_intel t ON i.threat_id = t.threat_id
WHERE  i.priority = 'P1'
GROUP  BY t.threat_type
ORDER  BY total_p1_incidents DESC
LIMIT  5;

-- Q11. Clients whose total financial impact exceeds the average across all clients.
WITH client_cost AS (
    SELECT i.client_id,
           ROUND(SUM(f.amount_usd), 2) AS total_impact
    FROM   financial_impact f
    JOIN   incidents i ON f.incident_id = i.incident_id
    GROUP  BY i.client_id
)
SELECT c.client_id, c.client_name, cc.total_impact
FROM   client_cost cc
JOIN   clients c ON cc.client_id = c.client_id
WHERE  cc.total_impact > (SELECT AVG(total_impact) FROM client_cost)
ORDER  BY cc.total_impact DESC;

-- Q12. Average resolution time (hours) per priority.
WITH resolution_cte AS (
    SELECT incident_id, priority,
           TIMESTAMPDIFF(HOUR, detected_datetime, resolved_datetime) AS resolution_hours
    FROM   incidents
    WHERE  resolved_datetime IS NOT NULL
)
SELECT priority,
       COUNT(*)                          AS resolved_incidents,
       ROUND(AVG(resolution_hours), 2)   AS avg_resolution_hours
FROM   resolution_cte
GROUP  BY priority
ORDER  BY priority;

-- Q13. Clients with incidents but NO matching SLA row for that incident's priority.
WITH client_priority AS (
    SELECT DISTINCT client_id, priority
    FROM   incidents
)
SELECT cp.client_id, c.client_name, cp.priority
FROM   client_priority cp
JOIN   clients c ON cp.client_id = c.client_id
LEFT   JOIN sla_contracts s
       ON cp.client_id = s.client_id
      AND cp.priority  = s.priority
WHERE  s.sla_id IS NULL
ORDER  BY cp.client_id, cp.priority;

-- Q14. Threats in threat_intel that never triggered an actual incident.
SELECT t.threat_id, t.threat_type, t.threat_actor, t.severity
FROM   threat_intel t
WHERE  t.threat_id NOT IN (
           SELECT DISTINCT threat_id
           FROM   incidents
           WHERE  threat_id IS NOT NULL
       )
ORDER  BY t.severity DESC;


-- Q15a. VIEW: client_sla_performance
--       Per-client % of incidents that breached target_resolution_hours.
CREATE VIEW client_sla_performance AS
WITH resolved AS (
    SELECT i.incident_id, i.client_id, i.priority,
           TIMESTAMPDIFF(HOUR, i.detected_datetime, i.resolved_datetime) AS actual_hours
    FROM   incidents i
    WHERE  i.resolved_datetime IS NOT NULL
),
breach_flagged AS (
    SELECT r.client_id, r.incident_id,
           CASE WHEN r.actual_hours > s.target_resolution_hours
                THEN 1 ELSE 0 END AS breached
    FROM   resolved r
    JOIN   sla_contracts s
           ON r.client_id = s.client_id
          AND r.priority  = s.priority
)
SELECT client_id,
       COUNT(*)                                   AS total_measured_incidents,
       SUM(breached)                               AS breached_incidents,
       ROUND(SUM(breached) * 100.0 / COUNT(*), 2)  AS breach_rate_pct
FROM   breach_flagged
GROUP  BY client_id;

-- Q15b. FINAL: Top 15 highest-risk clients (SLA breach rate + financial cost).
WITH cost AS (
    SELECT i.client_id,
           ROUND(SUM(f.amount_usd), 2) AS total_cost
    FROM   financial_impact f
    JOIN   incidents i ON f.incident_id = i.incident_id
    GROUP  BY i.client_id
),
normalized AS (
    SELECT p.client_id, p.breach_rate_pct, c.total_cost,
           -- normalize cost to a 0-100 scale so it's comparable to breach_rate_pct
           ROUND(c.total_cost * 100.0 / MAX(c.total_cost) OVER (), 2) AS cost_score
    FROM   client_sla_performance p
    JOIN   cost c ON p.client_id = c.client_id
)
SELECT cl.client_name, n.breach_rate_pct, n.total_cost,
       ROUND(0.6 * n.breach_rate_pct + 0.4 * n.cost_score, 2) AS risk_score,
       RANK() OVER (ORDER BY 0.6 * n.breach_rate_pct + 0.4 * n.cost_score DESC) AS risk_rank
FROM   normalized n
JOIN   clients cl ON n.client_id = cl.client_id
ORDER  BY risk_score DESC
LIMIT  15;

-- Q15c. COMPANION QUERY: Incident load per analyst per shift (staffing input).
SELECT an.shift, an.analyst_id, an.analyst_name,
       COUNT(i.incident_id) AS incidents_handled
FROM   analysts an
LEFT   JOIN incidents i ON an.analyst_id = i.assigned_analyst_id
GROUP  BY an.shift, an.analyst_id, an.analyst_name
ORDER  BY an.shift, incidents_handled DESC;

