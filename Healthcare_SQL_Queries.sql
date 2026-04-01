-- ============================================================
--  HEALTHCARE ANALYTICS PROJECT - SQL ANALYSIS QUERIES
--  Database: Hospital Patient Records (SQLite compatible)
--  Author: Data Analyst | Year: 2023
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- PHASE 1: DATABASE SETUP
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS patient_records (
    Patient_ID           TEXT PRIMARY KEY,
    Hospital             TEXT,
    Department           TEXT,
    Diagnosis            TEXT,
    Admit_Date           DATE,
    Discharge_Date       DATE,
    Length_of_Stay_Days  INTEGER,
    Age                  INTEGER,
    Gender               TEXT,
    Insurance_Type       TEXT,
    Bill_Amount          REAL,
    Insurance_Paid       REAL,
    Patient_Paid         REAL,
    Readmitted_30Days    INTEGER,  -- 0 or 1
    Patient_Satisfaction_Score REAL,
    Outcome              TEXT
);

CREATE TABLE IF NOT EXISTS staff_data (
    Staff_ID                   TEXT PRIMARY KEY,
    Department                 TEXT,
    Role                       TEXT,
    Hospital                   TEXT,
    Patients_Handled           INTEGER,
    Avg_Patient_Satisfaction   REAL,
    Years_Experience           INTEGER
);

-- ────────────────────────────────────────────────────────────
-- PHASE 2: DATA EXPLORATION & QUALITY CHECKS
-- ────────────────────────────────────────────────────────────

-- Q1: Total record count and date range
SELECT
    COUNT(*)                     AS Total_Patients,
    MIN(Admit_Date)              AS Earliest_Admission,
    MAX(Admit_Date)              AS Latest_Admission,
    COUNT(DISTINCT Hospital)     AS Num_Hospitals,
    COUNT(DISTINCT Department)   AS Num_Departments
FROM patient_records;

-- Q2: Check for any nulls or data quality issues
SELECT
    SUM(CASE WHEN Patient_ID IS NULL THEN 1 ELSE 0 END)          AS Null_PatientIDs,
    SUM(CASE WHEN Bill_Amount <= 0 THEN 1 ELSE 0 END)            AS Invalid_Bills,
    SUM(CASE WHEN Discharge_Date < Admit_Date THEN 1 ELSE 0 END) AS Invalid_Dates,
    SUM(CASE WHEN Age < 0 OR Age > 120 THEN 1 ELSE 0 END)        AS Invalid_Ages,
    SUM(CASE WHEN Patient_Satisfaction_Score NOT BETWEEN 0 AND 10 THEN 1 ELSE 0 END) AS Invalid_Scores
FROM patient_records;

-- ────────────────────────────────────────────────────────────
-- PHASE 3: OPERATIONAL KPIs
-- ────────────────────────────────────────────────────────────

-- Q3: Department-level operational summary
SELECT
    Department,
    COUNT(*)                                            AS Total_Patients,
    ROUND(AVG(Length_of_Stay_Days), 1)                 AS Avg_LOS_Days,
    ROUND(AVG(Bill_Amount), 0)                         AS Avg_Bill_USD,
    ROUND(SUM(Bill_Amount) / 1000000.0, 2)             AS Total_Revenue_M,
    ROUND(AVG(Patient_Satisfaction_Score), 1)          AS Avg_Satisfaction,
    ROUND(AVG(Readmitted_30Days) * 100, 1)             AS Readmission_Rate_Pct,
    SUM(CASE WHEN Outcome = 'Expired' THEN 1 ELSE 0 END) AS Mortalities
FROM patient_records
GROUP BY Department
ORDER BY Total_Revenue_M DESC;

-- Q4: Monthly admissions trend
SELECT
    STRFTIME('%Y-%m', Admit_Date)           AS Month,
    COUNT(*)                                AS Admissions,
    ROUND(AVG(Length_of_Stay_Days), 1)      AS Avg_LOS,
    ROUND(SUM(Bill_Amount) / 1000.0, 1)    AS Revenue_K
FROM patient_records
GROUP BY Month
ORDER BY Month;

-- Q5: Hospital performance comparison
SELECT
    Hospital,
    COUNT(*)                                            AS Total_Patients,
    ROUND(AVG(Bill_Amount), 0)                         AS Avg_Bill,
    ROUND(SUM(Bill_Amount) / 1000000.0, 2)             AS Total_Revenue_M,
    ROUND(AVG(Patient_Satisfaction_Score), 2)          AS Avg_Satisfaction,
    ROUND(AVG(Readmitted_30Days) * 100, 1)             AS Readmission_Pct,
    ROUND(AVG(Length_of_Stay_Days), 1)                 AS Avg_LOS
FROM patient_records
GROUP BY Hospital
ORDER BY Avg_Satisfaction DESC;

-- ────────────────────────────────────────────────────────────
-- PHASE 4: FINANCIAL ANALYSIS
-- ────────────────────────────────────────────────────────────

-- Q6: Revenue breakdown by insurance type
SELECT
    Insurance_Type,
    COUNT(*)                                                AS Num_Patients,
    ROUND(AVG(Bill_Amount), 0)                             AS Avg_Bill,
    ROUND(SUM(Bill_Amount) / 1000000.0, 2)                 AS Total_Billed_M,
    ROUND(SUM(Insurance_Paid) / SUM(Bill_Amount) * 100, 1) AS Coverage_Pct,
    ROUND(AVG(Patient_Paid), 0)                            AS Avg_Patient_OOP
FROM patient_records
GROUP BY Insurance_Type
ORDER BY Total_Billed_M DESC;

-- Q7: Cost analysis segmented by LOS buckets
SELECT
    CASE
        WHEN Length_of_Stay_Days BETWEEN 1 AND 3 THEN '01-03 days'
        WHEN Length_of_Stay_Days BETWEEN 4 AND 7 THEN '04-07 days'
        WHEN Length_of_Stay_Days BETWEEN 8 AND 14 THEN '08-14 days'
        WHEN Length_of_Stay_Days BETWEEN 15 AND 30 THEN '15-30 days'
        ELSE '30+ days'
    END                                             AS LOS_Bucket,
    COUNT(*)                                        AS Patient_Count,
    ROUND(AVG(Bill_Amount), 0)                     AS Avg_Bill,
    ROUND(MAX(Bill_Amount), 0)                     AS Max_Bill,
    ROUND(AVG(Patient_Satisfaction_Score), 1)      AS Avg_Satisfaction
FROM patient_records
GROUP BY LOS_Bucket
ORDER BY LOS_Bucket;

-- ────────────────────────────────────────────────────────────
-- PHASE 5: PATIENT QUALITY & RISK METRICS
-- ────────────────────────────────────────────────────────────

-- Q8: 30-day readmission analysis by diagnosis
SELECT
    Diagnosis,
    COUNT(*)                                            AS Total_Cases,
    SUM(Readmitted_30Days)                              AS Readmissions,
    ROUND(AVG(Readmitted_30Days) * 100, 1)             AS Readmission_Rate_Pct,
    ROUND(AVG(Bill_Amount), 0)                         AS Avg_Bill
FROM patient_records
GROUP BY Diagnosis
HAVING Total_Cases >= 20
ORDER BY Readmission_Rate_Pct DESC
LIMIT 15;

-- Q9: Age group analysis (patient demographics)
SELECT
    CASE
        WHEN Age < 18 THEN 'Pediatric (<18)'
        WHEN Age BETWEEN 18 AND 40 THEN 'Young Adult (18-40)'
        WHEN Age BETWEEN 41 AND 60 THEN 'Middle Age (41-60)'
        WHEN Age BETWEEN 61 AND 75 THEN 'Senior (61-75)'
        ELSE 'Elderly (75+)'
    END                                             AS Age_Group,
    COUNT(*)                                        AS Patients,
    ROUND(AVG(Bill_Amount), 0)                     AS Avg_Bill,
    ROUND(AVG(Length_of_Stay_Days), 1)             AS Avg_LOS,
    ROUND(AVG(Readmitted_30Days) * 100, 1)         AS Readmission_Pct,
    ROUND(AVG(Patient_Satisfaction_Score), 1)      AS Avg_Satisfaction
FROM patient_records
GROUP BY Age_Group
ORDER BY Avg_Bill DESC;

-- Q10: Gender-based outcome analysis
SELECT
    Gender,
    COUNT(*)                                            AS Patients,
    ROUND(AVG(Length_of_Stay_Days), 1)                 AS Avg_LOS,
    ROUND(AVG(Bill_Amount), 0)                         AS Avg_Bill,
    ROUND(AVG(Patient_Satisfaction_Score), 1)          AS Avg_Satisfaction,
    ROUND(AVG(Readmitted_30Days) * 100, 1)             AS Readmission_Rate_Pct
FROM patient_records
GROUP BY Gender;

-- ────────────────────────────────────────────────────────────
-- PHASE 6: ADVANCED SQL (Window Functions + CTEs)
-- ────────────────────────────────────────────────────────────

-- Q11: Running monthly revenue with cumulative total (Window Function)
WITH MonthlyRevenue AS (
    SELECT
        STRFTIME('%Y-%m', Admit_Date)           AS Month,
        ROUND(SUM(Bill_Amount), 0)              AS Monthly_Revenue,
        COUNT(*)                                AS Admissions
    FROM patient_records
    GROUP BY Month
)
SELECT
    Month,
    Admissions,
    Monthly_Revenue,
    SUM(Monthly_Revenue) OVER (ORDER BY Month)          AS Cumulative_Revenue,
    ROUND(AVG(Monthly_Revenue) OVER (
        ORDER BY Month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 0) AS Rolling_3M_Avg
FROM MonthlyRevenue
ORDER BY Month;

-- Q12: Dept rank by satisfaction using RANK() window function
WITH DeptStats AS (
    SELECT
        Department,
        Hospital,
        ROUND(AVG(Patient_Satisfaction_Score), 2) AS Avg_Satisfaction,
        COUNT(*) AS Patients
    FROM patient_records
    GROUP BY Department, Hospital
)
SELECT
    Department,
    Hospital,
    Patients,
    Avg_Satisfaction,
    RANK() OVER (PARTITION BY Department ORDER BY Avg_Satisfaction DESC) AS Rank_In_Dept,
    RANK() OVER (ORDER BY Avg_Satisfaction DESC) AS Overall_Rank
FROM DeptStats
ORDER BY Department, Rank_In_Dept;

-- Q13: High-risk patient identification (CTE + multi-condition filter)
WITH PatientRisk AS (
    SELECT
        Patient_ID,
        Hospital,
        Department,
        Diagnosis,
        Age,
        Length_of_Stay_Days,
        Bill_Amount,
        Readmitted_30Days,
        Patient_Satisfaction_Score,
        CASE
            WHEN Readmitted_30Days = 1 AND Age > 65 AND Length_of_Stay_Days > 7 THEN 'HIGH'
            WHEN Readmitted_30Days = 1 OR (Age > 65 AND Length_of_Stay_Days > 7)  THEN 'MEDIUM'
            ELSE 'LOW'
        END AS Risk_Level
    FROM patient_records
)
SELECT
    Risk_Level,
    COUNT(*)                                AS Patient_Count,
    ROUND(AVG(Bill_Amount), 0)             AS Avg_Bill,
    ROUND(AVG(Length_of_Stay_Days), 1)     AS Avg_LOS,
    ROUND(AVG(Patient_Satisfaction_Score),1) AS Avg_Satisfaction
FROM PatientRisk
GROUP BY Risk_Level
ORDER BY
    CASE Risk_Level WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 ELSE 3 END;

-- Q14: Staff performance vs patient satisfaction (JOIN)
SELECT
    s.Role,
    s.Department,
    ROUND(AVG(s.Avg_Patient_Satisfaction), 2)   AS Staff_Reported_Satisfaction,
    ROUND(AVG(p.Patient_Satisfaction_Score), 2) AS Patient_Reported_Satisfaction,
    COUNT(DISTINCT s.Staff_ID)                   AS Staff_Count,
    SUM(s.Patients_Handled)                      AS Total_Patients_Handled
FROM staff_data s
JOIN patient_records p ON s.Department = p.Department
GROUP BY s.Role, s.Department
ORDER BY Patient_Reported_Satisfaction DESC
LIMIT 20;

-- ────────────────────────────────────────────────────────────
-- PHASE 7: STORED VIEWS FOR TABLEAU CONNECTION
-- ────────────────────────────────────────────────────────────

CREATE VIEW IF NOT EXISTS vw_KPI_Summary AS
SELECT
    Hospital,
    Department,
    STRFTIME('%Y-%m', Admit_Date)           AS Month,
    COUNT(*)                                AS Admissions,
    ROUND(SUM(Bill_Amount), 0)             AS Total_Revenue,
    ROUND(AVG(Bill_Amount), 0)             AS Avg_Bill,
    ROUND(AVG(Length_of_Stay_Days), 1)     AS Avg_LOS,
    ROUND(AVG(Patient_Satisfaction_Score),1) AS Avg_Satisfaction,
    ROUND(AVG(Readmitted_30Days)*100, 1)   AS Readmission_Rate
FROM patient_records
GROUP BY Hospital, Department, Month;

CREATE VIEW IF NOT EXISTS vw_Financial_Summary AS
SELECT
    Insurance_Type,
    Department,
    ROUND(SUM(Bill_Amount), 0)                             AS Total_Billed,
    ROUND(SUM(Insurance_Paid), 0)                          AS Total_Covered,
    ROUND(SUM(Patient_Paid), 0)                            AS Total_OOP,
    ROUND(AVG(Insurance_Paid / Bill_Amount) * 100, 1)     AS Coverage_Rate_Pct
FROM patient_records
GROUP BY Insurance_Type, Department;
