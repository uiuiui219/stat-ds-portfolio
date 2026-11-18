# Statistics & Data Science Portfolio — KMUTT

[![Render reports](https://github.com/uiuiui219/stat-ds-portfolio/actions/workflows/render-reports.yml/badge.svg)](https://github.com/uiuiui219/stat-ds-portfolio/actions/workflows/render-reports.yml) · **Portfolio site: [uiuiui219.github.io/stat-ds-portfolio](https://uiuiui219.github.io/stat-ds-portfolio/)**

**ปิยพัทธ์ จันทร์ทวี (Piyapat Jantawee)** · B.Sc. Statistics and Data Science · King Mongkut's University of Technology Thonburi (KMUTT)

> พอร์ตโฟลิโอรวมโปรเจกต์ด้านสถิติและวิทยาการข้อมูลที่ทำระหว่างเรียน — แต่ละโปรเจกต์มี **โค้ดจริง** และ **รายงานฉบับเต็ม** กำกับ พร้อมคำอธิบายแหล่งข้อมูลและวิธีทำซ้ำ (reproduce) เพื่อให้ตรวจสอบผลได้เอง

A portfolio of statistics and data-science projects. Every entry ships its **code** and its **full report**, so results can be read and reproduced rather than taken on trust. The repository is organised into two groups: one graduate project, and course projects from specific classes.

---

## 1) Graduate project · โปรเจกต์จบปริญญาตรี

The single project with a completed, reviewed thesis-style report (รูปเล่มพร้อม).

### [F1 Driver Points Prediction](projects/f1-driver-points-prediction/)

Predicting whether a Formula 1 driver finishes in the points (Top 10) from race-weekend features — driver history, grid position, circuit characteristics and race-day weather — with clustering of circuits and SHAP-based interpretation.

ทำนายว่านักขับ F1 จะจบการแข่งขันในกลุ่มคะแนน (Top 10) หรือไม่ จากผลงานย้อนหลัง ตำแหน่งออกสตาร์ท ลักษณะสนาม และสภาพอากาศวันแข่ง พร้อมจัดกลุ่มสนามด้วย hierarchical clustering และอธิบายโมเดลด้วย SHAP

| Metric (test = 2024 season) | XGBoost |
|---|---|
| ROC-AUC | **0.883** |
| Accuracy | **0.810** |
| Precision | **0.775** |
| Recall | **0.875** |
| F1-Score | **0.822** |

**Deliverables:** [full report (PDF, TH)](projects/f1-driver-points-prediction/report/Full-Report-F1-Driver-Points-Prediction-TH.pdf) · [poster (PDF)](projects/f1-driver-points-prediction/report/F1-Graduate-Poster.pdf) · [Power BI dashboard](projects/f1-driver-points-prediction/dashboard/f1-dashboard.pbix) · [code & data](projects/f1-driver-points-prediction/)

**Methods:** feature engineering from Ergast F1 API + Open-Meteo weather + Pirelli track data · Gower distance → hierarchical clustering on 128 circuits (5 clusters) · Random Forest vs XGBoost · expanding-window time-series cross-validation (4 folds, train 2019–2023 → test 2024) · SHAP.

---

## 2) Course projects · โปรเจกต์รายวิชา

> **Disclaimer — โปรเจกต์เหล่านี้เป็นงานเรียนรู้ภาคปฏิบัติในรายวิชา**
> Each project below was built as a hands-on learning exercise for a specific course. They were graded on the process of applying a method correctly, not on production readiness, so **some points may not fully follow best practice** (for example simplified data cleaning, small samples, model choices driven by the assignment's requirements, or results that would need more validation before real-world use). They are shared as evidence of applied coursework, with that caveat in mind.

| Project | Course | What it is | Methods & tools |
|---|---|---|---|
| [**IBM Employee Attrition**](projects/ibm-attrition-prediction/) | STD 371 — Statistical Learning for Data Science I | Predict who leaves, then profile the highest-risk employee segment for an HR audience | One-hot encoding, SMOTE, PCA (>80 % variance), clustering with 4 CVI indices, Random Forest / XGBoost / glmnet selected on F1 |
| [**Texas Accident Severity**](projects/texas-accident-severity/) | STD 471 — Statistical Learning for Data Science II | Predict road-crash severity in San Antonio, TX, and find high-risk locations/times | PCA, k-means & EM clustering (UniversalCVI), Random Forest / XGBoost / BART under 5-fold CV, SHAP, hot-spot wait-time analysis |
| [**Power BI Dashboards**](projects/power-bi-dashboards/) | CSS 475 — Business Intelligence | A four-source BI dashboard (e-commerce, retail, telecom, entertainment) | Power Query, DAX, star-schema modelling |

**Headline results**

- **IBM attrition** — Random Forest had the highest F1; the highest-risk cluster attrites at **38.18 %** (21 of 55 employees), driven by low job involvement, stock-option level and job satisfaction.
- **Texas accident severity** — an asymmetric comparison of RF / XGBoost / BART under 5-fold CV, followed by SHAP variable importance from the winning fit.
- **Power BI** — [view the live dashboard](https://app.powerbi.com/view?r=eyJrIjoiYTkwYmEyZTQtMjUzZS00M2JkLWJjMTgtZTY1YWZlODc0Nzc3IiwidCI6IjZmNDQzMmRjLTIwZDItNDQxZC1iMWRiLWFjMzM4MGJhNjMzZCIsImMiOjEwfQ%3D%3D) · [BI report (PDF)](projects/power-bi-dashboards/final/BI_Final.pdf).

---

## Tech stack

- **R** — tidyverse (dplyr/ggplot2), caret, randomForest, xgboost, BART, mclust, glmnet, e1071, factoextra, psych, SHAPforxgboost, iml, arrow, fpp2
- **Python** — pandas, scikit-learn (exploratory work; see the notebook in the Texas project)
- **BI & data** — Power BI (DAX, Power Query), Excel, Git
- **Data sources used** — Ergast F1 API, Open-Meteo API, Kaggle (US Accidents, IBM HR Analytics, BankChurners), UCI ML Repository

## About the data in this repo

Raw datasets over 10 MB (US-Accidents parquet, MNIST/CIFAR/IMDB, large retail transactions, etc.) are **not** committed — each project README documents where to download them and how the code expects them to be laid out. Lecture slides and course materials authored by instructors are excluded; only my own reports, code and data dictionaries are kept.

## Repo layout

```
projects/     → one folder per project: report + code + data dictionary (+ dashboard)
docs/         → portfolio site (GitHub Pages): graduate-project landing page + course-projects tab
docs/reports/ → rendered HTML reports (regenerated by GitHub Actions on every push)
.github/      → CI that re-renders the reports (F1 + IBM; Texas when its dataset is present)
```

---

*Maintained as supporting material for job applications — site: [uiuiui219.github.io/stat-ds-portfolio](https://uiuiui219.github.io/stat-ds-portfolio/)*
