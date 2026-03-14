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

