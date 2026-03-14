# Neonatal CPAP Coverage Analysis (NEST360)

## Overview

This project analyzes neonatal admissions data to assess **Continuous Positive Airway Pressure (CPAP) coverage among neonates weighing 1000–1499 grams**, a high-risk group of **very low birthweight (VLBW) infants** who frequently require respiratory support.

The analysis was conducted in **R** using a reproducible workflow and focuses on:

- Data Quality Assessment
- Creation of derived analytical variables
- Descriptive analysis of neonatal admissions
- Hospital-level CPAP coverage variation
- Benchmark-based target setting for **December 2028**

The objective is to support **data-driven decision making for neonatal care programs**, particularly within the **NEST360 initiative**.

---

# Repository Structure

nest360-cpap-analysis
│
├── data
│ └── NID.xlsx
│
├── scripts
│ └── cpap_analysis.R
│
├── outputs
│ ├── NEST360_outputs.xlsx
│ ├── CPAP_hospital_ranking.png
│ ├── CPAP_coverage_histogram.png
│ └── NESTO360_targets_plot.png
│
└── README.md


---

# Analytical Workflow

The analysis is organized into four sections:

**A. Data Quality Assessment**  
**B. Derived Variables**  
**C. Descriptive CPAP Coverage Analysis**  
**D. Target Setting for 2028**

All analyses were conducted using **R** with a reproducible workflow.

---

# A. Data Quality Assessment

## Data Validation

The dataset was assessed for:

- Missing values
- Implausible weight measurements
- Date inconsistencies
- Logical inconsistencies between variables

### Data Quality Flags

The following validation checks were implemented:

| Flag | Description |
|-----|-------------|
| Birthweight outside 100–6000 g | Implausible neonatal weight |
| Admission weight outside range | Potential data entry error |
| Admission weight greater than birthweight | Measurement inconsistency |
| Discharge before admission | Impossible timeline |
| Admission before birth | Data entry error |
| Discharge before birth | Impossible timeline |

These checks allow problematic records to be flagged without removing them from the dataset.

---

## Missing Data

Important missing values were observed in:

- CPAP administration (`in_cp_admin`)
- Admission weight (`in_admwt`)
- Birthweight (`in_bwt`)

To mitigate loss of information:

- Records with missing CPAP status were excluded from coverage denominators
- Birthweight was used as a substitute when admission weight was missing

---

## Data Quality Improvement Recommendations

To strengthen future datasets:

1. Implement **real-time validation rules** in electronic neonatal registers.
2. Standardize **weight measurement procedures**.
3. Make CPAP recording **mandatory in data collection tools**.
4. Conduct **routine facility-level data quality audits**.

---

# B. Derived Variables

Several analytical variables were created to support the analysis.

## Age at Admission


Records with impossible timelines were excluded.

---

## Length of Stay (LOS)

Negative values were flagged as invalid.

---

## Neonatal Weight Categories

| Category | Definition |
|---|---|
| <1000 g | Extremely low birthweight |
| 1000–1499 g | Very low birthweight |
| 1500–1999 g | Low birthweight |
| ≥2000 g | Higher birthweight |

The **1000–1499 g category** was selected for CPAP coverage analysis.

---

## Weight Used for CPAP Analysis

A variable `weight_for_cpap` was created using the following rule:

Negative values were flagged as invalid.

---

## Neonatal Weight Categories

| Category | Definition |
|---|---|
| <1000 g | Extremely low birthweight |
| 1000–1499 g | Very low birthweight |
| 1500–1999 g | Low birthweight |
| ≥2000 g | Higher birthweight |

The **1000–1499 g category** was selected for CPAP coverage analysis.

---

## Weight Used for CPAP Analysis

A variable `weight_for_cpap` was created using the following rule:

An additional variable `weight_source` tracks which measurement was used.

---

# C. CPAP Coverage Analysis

## Definition of Coverage

An additional variable `weight_source` tracks which measurement was used.

---

# C. CPAP Coverage Analysis

## Definition of Coverage



Eligibility criteria:

- Neonates weighing **1000–1499 g**
- Known CPAP administration status

---

## Hospital-Level Coverage

CPAP coverage was calculated for each hospital.

The **hospital ranking plot** shows substantial variation between facilities.

Some hospitals report **coverage above 90%**, while others fall below **30%**.

Possible explanations include:

- Differences in CPAP equipment availability
- Clinical training and staffing
- Neonatal unit capacity
- Clinical treatment protocols

---

# Visualization

## Hospital Ranking

![Hospital Ranking](outputs/CPAP_hospital_ranking.png)

This figure ranks hospitals from **lowest to highest CPAP coverage**, highlighting performance variation across facilities.

---

## Coverage Distribution

![Coverage Histogram](outputs/CPAP_coverage_histogram.png)

The histogram illustrates the distribution of CPAP coverage across hospitals.

Most facilities cluster between **30% and 60% coverage**, indicating moderate program performance but significant room for improvement.

---

## Baseline vs Target

![Baseline vs Target](outputs/NESTO360_targets_plot.png)

This figure compares **2025 baseline coverage** with proposed **2028 targets**.

---

# D. Target Setting for 2028

Targets were developed using a **benchmarking and equity-based approach**.

Four rules were applied sequentially.

---

## Rule 1 — Peer Benchmark

The **75th percentile of hospital CPAP coverage in 2025** was used as the benchmark.

This reflects the performance achieved by top-performing hospitals and represents a realistic improvement level.

---

## Rule 2 — Equity Adjustment

Hospitals with baseline coverage below **30%** received a **+30 percentage point increase**.

This helps accelerate progress among low-performing facilities.

---

## Rule 3 — Minimum Floor

A **minimum target of 60% coverage** was applied.

No hospital should aim for coverage below this threshold by 2028.

---

## Rule 4 — Maximum Ceiling

A ceiling of **95% coverage** was applied.

Achieving 100% coverage may not be clinically realistic because some neonates may not require CPAP.

---

# Programmatic Implications

The analysis highlights several important insights.

### Large Variation Across Hospitals

Coverage varies widely between hospitals, indicating unequal access to neonatal respiratory care.

### Learning From High Performers

Hospitals achieving high coverage demonstrate that strong performance is achievable within the program context.

### Monitoring Progress

The target framework allows monitoring of:

- absolute improvement required
- monthly improvement needed to reach targets by 2028

---

# Outputs Generated

| Output | Description |
|---|---|
| `NEST360_outputs.xlsx` | Final dataset with derived variables |
| `CPAP_hospital_ranking.png` | Hospital performance ranking |
| `CPAP_coverage_histogram.png` | Distribution of CPAP coverage |
| `NESTO360_targets_plot.png` | Baseline vs 2028 targets |

---

# Tools Used

The analysis was conducted using:

- **R**
- **dplyr**
- **tidyr**
- **lubridate**
- **ggplot2**
- **readxl**
- **writexl**

---

# Author

**Charles**

Monitoring, Evaluation & Learning (MEAL) Manager  
Data Analytics Specialist

Experience in:

- Digital MEL systems
- Data quality assurance
- Health program analytics
- R, Python, SQL, and Power BI
