# Statistics & Data Science Portfolio — KMUTT

[![Render reports](https://github.com/uiuiui219/stat-ds-portfolio/actions/workflows/render-reports.yml/badge.svg)](https://github.com/uiuiui219/stat-ds-portfolio/actions/workflows/render-reports.yml) · **Portfolio site: [uiuiui219.github.io/stat-ds-portfolio](https://uiuiui219.github.io/stat-ds-portfolio/)**

**Piyapat Jantawee (ปิยพัทธ์ จันทร์ทวี)** · B.Sc. Statistics and Data Science · King Mongkut's University of Technology Thonburi (KMUTT)

A portfolio of statistics and data-science work from my degree. Each entry includes the code that produced the results and the full report, plus notes on the data sources and how to reproduce the analysis.

The repository has two parts: one graduate project, and course projects from specific classes.

> **สรุปภาษาไทย** — รีโปนี้รวมงานสถิติและวิทยาการข้อมูลจากหลักสูตรปริญญาตรี แต่ละโปรเจกต์มีโค้ดจริงและรายงานฉบับเต็มกำกับ พร้อมที่มาของข้อมูลและวิธีทำซ้ำ แบ่งเป็นโปรเจกต์จบ 1 งาน และโปรเจกต์รายวิชา 3 งาน

---

## 1) Graduate project · โปรเจกต์จบปริญญาตรี

### [Analyzing Factors Influencing Formula 1 Driver Scores Using Machine Learning](projects/f1-driver-points-prediction/)

*การวิเคราะห์ปัจจัยที่ส่งผลต่อการได้คะแนนนักขับฟอร์มูล่าวัน ด้วยเทคนิคการเรียนรู้ของเครื่อง*

A binary classification study of whether a Formula 1 driver scores points in a race, built from race-weekend data for 2019–2024 (2,559 race entries). The work has three objectives, as stated in the report:

1. Classify and group Formula 1 circuits by their characteristics.
2. Compare the performance of models that predict a driver's points in each race.
3. Analyse and explain how much each factor contributes to a driver scoring points.

> **สรุปภาษาไทย** — งานนี้ทำนายว่านักขับฟอร์มูล่าวันจะได้คะแนนในเรซหรือไม่ (binary classification) จากข้อมูลปี 2019–2024 จำนวน 2,559 race entries โดยมีสามวัตถุประสงค์: จัดกลุ่มสนามแข่งขันตามลักษณะเฉพาะ เปรียบเทียบประสิทธิภาพตัวแบบพยากรณ์ และวิเคราะห์ความสำคัญของปัจจัยที่ส่งผลต่อการได้คะแนน

**Results (test set = 2024 season, XGBoost)**

| Metric | Value |
|---|---|
| ROC-AUC | **0.883** |
| Accuracy | **0.810** |
| Precision | **0.775** |
| Recall | **0.875** |
| F1-Score | **0.822** |

SHAP analysis ranks the starting grid position as the most influential factor, followed by the potential and past performance of the team and the driver. Circuit type and race-day weather have low influence.

**Methods.** Ergast F1 API, Open-Meteo and Pirelli Motorsport data → feature engineering across six variable groups (driver and team basics, experience and performance, race data, weather and race context, circuit physical characteristics, circuit technical characteristics), using only information available before the race → Gower distance and hierarchical clustering to group 128 circuits into 5 clusters, used as an additional feature → Random Forest vs XGBoost with expanding-window time-series cross-validation (4 folds, train 2019–2023, test 2024) → SHAP for interpretation.

**Deliverables:** [full report (PDF, Thai)](projects/f1-driver-points-prediction/report/Full-Report-F1-Driver-Points-Prediction-TH.pdf) · [poster (PDF)](projects/f1-driver-points-prediction/report/F1-Graduate-Poster.pdf) · [code and data](projects/f1-driver-points-prediction/)

The repository also contains an extension of the analysis that assigns a full race field to podium / scoring / no-points slots under the 3 + 7 + 10 quota. It is a supplementary part of the code (`code/02_modeling-v1.R`, `code/03_modeling-v2-quota-and-strict.R`), not the main research question.

---

## 2) Course projects · โปรเจกต์รายวิชา

> **Disclaimer — these are coursework exercises.**
> Each project below was completed as a hands-on assignment for a specific course. They were assessed on applying the method correctly, not on production readiness, so some parts may not fully follow best practice — for example simplified data cleaning, small samples, or model choices driven by the assignment's requirements. They are shared as evidence of coursework with that caveat.

| Project | Course | What it covers | Methods |
|---|---|---|---|
| [**IBM Employee Attrition**](projects/ibm-attrition-prediction/) | STD 371 — Statistical Learning for Data Science I | Predict which employees leave, then profile the highest-risk segment for an HR audience | One-hot encoding, SMOTE, PCA (>80 % variance), clustering with 4 CVI indices, Random Forest / XGBoost / glmnet compared on F1 |
| [**Texas Accident Severity**](projects/texas-accident-severity/) | STD 471 — Statistical Learning for Data Science II | Predict road-crash severity in San Antonio, TX, and locate high-risk times and places | PCA, k-means and EM clustering (UniversalCVI), Random Forest / XGBoost / BART under 5-fold CV, SHAP, hot-spot wait-time analysis |
| [**Power BI Dashboards**](projects/power-bi-dashboards/) | CSS 475 — Business Intelligence | A four-source BI report (e-commerce, retail, telecom, entertainment) | Power Query, DAX, star-schema modelling |

**Selected results**

- **IBM attrition** — Random Forest had the highest F1; the highest-risk cluster attrites at **38.18 %** (21 of 55 employees), driven by low job involvement, stock-option level and job satisfaction.
- **Texas accident severity** — an asymmetric comparison of RF / XGBoost / BART under 5-fold CV, followed by SHAP variable importance from the winning fit.
- **Power BI** — [view the live dashboard](https://app.powerbi.com/view?r=eyJrIjoiYTkwYmEyZTQtMjUzZS00M2JkLWJjMTgtZTY1YWZlODc0Nzc3IiwidCI6IjZmNDQzMmRjLTIwZDItNDQxZC1iMWRiLWFjMzM4MGJhNjMzZCIsImMiOjEwfQ%3D%3D) · [report (PDF)](projects/power-bi-dashboards/final/BI_Final.pdf)

> **สรุปภาษาไทย** — โปรเจกต์ในกลุ่มนี้เป็นงานเรียนรู้ภาคปฏิบัติในรายวิชา จึงอาจมีบางจุดที่ยังไม่ครบตามหลักการทางวิชาชีพ และมีรายละเอียดของข้อมูลและผลลัพธ์อยู่ใน README ของแต่ละโปรเจกต์

---

## Tech stack

**Used in the projects in this repository**

- **R** — tidyverse (dplyr, ggplot2), caret, randomForest, xgboost, BART, mclust, glmnet, e1071, factoextra, psych, SHAPforxgboost, arrow, R Markdown
- **Python (basic)** — pandas and scikit-learn; used in the Texas project notebook
- **BI and reporting** — Power BI (Power Query, DAX), Excel, Word, PowerPoint, Canva
- **Version control and CI** — Git, GitHub Actions

**Also familiar with (not used in this repository)**

- SQL, DuckDB, Apache Superset, SPSS; Docker (basic)

> **สรุปภาษาไทย** — เครื่องมือที่ใช้จริงในรีโปนี้คือ R เป็นหลัก ร่วมกับ Python พื้นฐาน Power BI Excel และ Git ส่วน SQL, DuckDB, Apache Superset, SPSS และ Docker เป็นเครื่องมือที่เคยใช้แต่ไม่มีโค้ดในรีโปนี้

## Data in this repository

Raw datasets larger than 10 MB (US-Accidents parquet, MNIST/CIFAR/IMDB, large retail transactions, and similar) are not committed. Each project README documents the download source and the layout the code expects. Datasets and course materials written by instructors are excluded; only my own reports, code and data dictionaries are kept.

## Repository layout

```
projects/     one folder per project: report, code, data dictionary, dashboards
docs/         portfolio site (GitHub Pages): graduate project and course projects
docs/reports/ rendered HTML reports, regenerated by GitHub Actions on each push
.github/      CI that re-renders the reports (F1 and IBM; Texas when its dataset is present)
```

---

*Maintained as supporting material for job applications — site: [uiuiui219.github.io/stat-ds-portfolio](https://uiuiui219.github.io/stat-ds-portfolio/)*
