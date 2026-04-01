# 🏥 Healthcare Patient Analytics — End-to-End Data Analyst Project


---

## 📋 Table of Contents
- [Project Overview](#project-overview)
- [Problem Statement](#problem-statement)
- [Objectives](#objectives)
- [Dataset Description](#dataset-description)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Steps Involved](#steps-involved)
- [Key Findings](#key-findings)
- [Dashboard Previews](#dashboard-previews)
- [How to Run](#how-to-run)
- [Business Recommendations](#business-recommendations)
- [Skills Demonstrated](#skills-demonstrated)

---

## 🔍 Project Overview

An end-to-end data analytics project analysing **2,000 patient records** across 5 hospitals and 7 departments to uncover operational inefficiencies, financial drivers, and patient experience gaps. The project covers the full analyst pipeline: data cleaning in Excel → SQL-based clinical analysis → Python EDA → Tableau dashboards → executive presentation.

---

## ❗ Problem Statement

A hospital group's management team lacks a unified, data-driven view of clinical and financial performance across sites. Key pain points:

- **No visibility** into which departments drive readmissions and why
- **Revenue leakage** from unoptimised insurance billing and LOS management
- **Low satisfaction scores** in specific departments with no root-cause analysis
- **Staff allocation** decisions made without productivity or workload data

---

## 🎯 Objectives

| # | Objective |
|---|-----------|
| 1 | Identify departments with highest readmission rates and quantify revenue impact |
| 2 | Analyse revenue contribution by hospital, department, and insurance type |
| 3 | Measure average Length of Stay (LOS) and its correlation with cost and satisfaction |
| 4 | Profile patient demographics (age, gender, diagnosis) to guide resource planning |
| 5 | Build interactive Tableau dashboards for clinical, financial, and patient-experience views |

---

## 📊 Dataset Description

**File:** `Healthcare_DA_Project.xlsx`

| Sheet | Rows | Description |
|-------|------|-------------|
| `Patient_Records` | 2,000 | Core patient data — admits, LOS, revenue, readmission, satisfaction |
| `Staff_Data` | ~300 | Hospital staff records by role and department |
| `Dept_Summary` | 7 | Department-level aggregated KPIs |

### Key Columns

| Column | Type | Description |
|--------|------|-------------|
| `Patient_ID` | Text | Unique patient identifier |
| `Hospital` | Category | One of 5 hospital sites |
| `Department` | Category | Clinical department (Cardiology, Neurology, etc.) |
| `Admit_Date` / `Discharge_Date` | Date | Admission and discharge timestamps |
| `Length_Of_Stay` | Integer | Days admitted |
| `Total_Revenue` | Currency (₹) | Billing amount per patient visit |
| `Insurance_Type` | Category | Private / Government / Self-Pay |
| `Readmission_Flag` | Binary (0/1) | 1 = readmitted within 30 days |
| `Satisfaction_Score` | 0–10 | Post-discharge patient satisfaction rating |
| `Diagnosis` | Text | Primary diagnosis category |
| `Age_Group` | Category | Patient age band |

---

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| **Microsoft Excel** | Data cleaning, pivot tables, conditional formatting |
| **SQL** (SQLite/PostgreSQL) | 14 analytical queries, 2 views, window functions |
| **Python 3.8+** | EDA, 7-panel dashboard, matplotlib/seaborn visualisations |
| **Tableau Desktop / Public** | 3 interactive dashboards |
| **PowerPoint** | 9-slide executive presentation |

---

## 📁 Project Structure

```
healthcare-patient-analytics/
│
├── data/
│   └── Healthcare_DA_Project.xlsx       # Raw + cleaned dataset (3 sheets)
│
├── sql/
│   └── Healthcare_SQL_Queries.sql       # 14 queries + 2 Tableau views
│
├── python/
│   └── Healthcare_Python_EDA.py         # Full EDA script
│
├── tableau/
│   └── Healthcare_Tableau.twbx          # Tableau workbook (data embedded)
│
├── powerbi/
│   └── Healthcare_PowerBI_Scripts.m     # Power Query M + DAX measures
│
├── presentation/
│   └── Healthcare_Analytics_Presentation.pptx
│
├── outputs/                             # Auto-created by Python script
│   ├── Healthcare_EDA_Dashboard.png
│   └── Healthcare_Financial_Analysis.png
│
└── README.md
```

---

## 🔢 Steps Involved

### Phase 1 — Data Collection & Excel Cleaning
1. Load raw patient records into Excel
2. Standardise date formats on `Admit_Date` and `Discharge_Date`
3. Remove 23 duplicate `Patient_ID` entries
4. Fill missing `Insurance_Type` values using department-level mode imputation
5. Create calculated column: `Length_Of_Stay = Discharge_Date - Admit_Date`
6. Build pivot tables: Revenue by Hospital × Department, Readmission by Dept
7. Apply conditional formatting: red cells for `Readmission_Flag = 1` + LOS > 10 days

### Phase 2 — SQL Analysis
8. Create schema and load all three sheets into database
9. Run data quality checks (Q1–Q2): null counts, invalid LOS, date anomalies
10. Clinical analysis (Q3–Q6): readmission rates, LOS by dept/diagnosis, patient volume trend
11. Financial analysis (Q7–Q10): revenue by hospital/insurance, revenue per patient, cost drivers
12. Advanced queries (Q11–Q14): window functions for monthly trend, RANK() by readmission rate, LAG() MoM revenue change
13. Create `vw_KPI_Summary` and `vw_Financial_Summary` views for Tableau connection

### Phase 3 — Python EDA
14. Load data from Excel using `pandas.read_excel()`
15. Profile dataset: shape, nulls, dtypes, descriptive statistics
16. Generate 7-panel main dashboard (revenue trend, LOS distribution, readmission by dept, satisfaction scatter, insurance mix, age distribution, department comparison)
17. Generate financial deep-dive: revenue heatmap, insurance revenue comparison, cost-per-stay analysis
18. Save all charts to `outputs/` folder

### Phase 4 — Tableau Dashboards
19. Connect Tableau to `Healthcare_Tableau.twbx` (data pre-embedded)
20. Build Dashboard 1 — Clinical Overview: monthly admissions line, LOS bar, readmission heatmap
21. Build Dashboard 2 — Financial Performance: revenue by hospital, insurance donut, dept revenue matrix
22. Build Dashboard 3 — Patient Experience: satisfaction bar, age/gender demographics, high-risk patient table
23. Add cross-dashboard filter actions and date range slicer

### Phase 5 — Presentation
24. Compile 9-slide executive deck with KPI cards, key findings, and data-backed recommendations

---

## 📈 Key Findings

| Finding | Detail |
|---------|--------|
| 🔴 Neurology has 16.1% readmission rate | Highest in the network — 4pp above average |
| 💰 Private Insurance generates 34% more revenue per patient | vs Government/Self-Pay |
| 😞 Oncology satisfaction is 6.4/10 | Lowest department, driven by long LOS (avg 8.3 days) |
| ⏱️ Average LOS is 5.2 days | Cardiology patients stay 2.1 days longer than average |
| 📊 Total Network Revenue: ₹27.1M | Top hospital contributes 28% of total |

---

## 💼 Business Recommendations

1. **Launch Neurology care-gap programme** — target the 16.1% readmission cohort with structured 7-day post-discharge follow-up
2. **Maximise private insurance billing** — audit coding accuracy; private patients generate 34% more revenue per visit
3. **Oncology satisfaction improvement** — reduce LOS through palliative care integration and family liaison programme
4. **LOS management protocol** — implement department-level LOS targets; 1-day reduction = ~₹1.2M annual saving

---

## 🧠 Skills Demonstrated

`Data Cleaning` · `Pivot Tables` · `SQL Window Functions` · `CTEs` · `Python EDA` · `matplotlib` · `seaborn` · `Tableau Dashboards` · `DAX Measures` · `Power Query M` · `Executive Storytelling` · `Healthcare KPIs` · `Readmission Analysis` · `Revenue Analytics`
