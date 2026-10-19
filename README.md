# Statistics & Data Science Portfolio — KMUTT

**ปิยพัทธ์ จันทร์ทวี (Piyapat Jantawee)** · B.Sc. Statistics and Data Science · King Mongkut's University of Technology Thonburi (KMUTT) · Student ID 65090502417

> พอร์ตโฟลิโอรวมงานจากชั้นเรียนและโปรเจกต์ระหว่างเรียน สาขา Statistics and Data Science — ทั้งงานกลุ่มและงานเดี่ยว เก็บเป็นส่วนตัวระหว่างพัฒนา (private repo)

A curated collection of coursework and project work from my B.Sc. in Statistics and Data Science. Each entry links to the full report (PDF/HTML), the code, and the data dictionary needed to reproduce it.

---

## Featured Projects

| Project | What it is | Methods & tools | Headline result |
|---|---|---|---|
| [**F1 Driver Points Prediction**](projects/f1-driver-points-prediction/) | Graduate project (ป.ตรี): predict whether an F1 driver finishes in the points, from race-weekend features | Feature engineering from Ergast API + Open-Meteo weather + Pirelli track data, Gower distance + hierarchical clustering on 128 circuits, Random Forest & XGBoost, time-series CV (expanding 4-fold), SHAP, Power BI | XGBoost: **ROC-AUC 0.883 · Accuracy 0.81 · F1 0.822** (test = 2024 season) |
| [**Texas Accident Severity**](projects/texas-accident-severity/) | Predict road-crash severity in San Antonio, TX (STD 471) | PCA, k-means & EM clustering (cluster count via UniversalCVI), Random Forest / XGBoost / BART, 5-fold CV, SHAP, hot-spot wait-time analysis | XGBoost gave the highest **F1-score** among the three models |
| [**IBM Employee Attrition**](projects/ibm-attrition-prediction/) | Predict attrition + segment risk profiles (STD 371) | One-hot encoding, SMOTE, PCA (>80 % variance), clustering with 4 CVI indices, Random Forest / XGBoost / glmnet, F1-driven model selection | **Random Forest** had the highest F1; highest-risk segment attrited at **38.18 %** |
| [**Power BI Dashboards**](projects/power-bi-dashboards/) | Business-intelligence final project + lab dashboards (CSS 475) | Power Query, DAX, star-schema modelling, map visuals (GeoJSON/shapefile) | Multi-source retail/telecom/entertainment dashboard + report PDF |

---

## Coursework

Homework, lab reports and assignments — grouped by course. Full index in [`coursework/README.md`](coursework/README.md).

| Folder | Course | Contents |
|---|---|---|
| [`std-371-statistical-learning-1`](coursework/std-371-statistical-learning-1/) | Statistical Learning for Data Science I | HW2–HW6 + 11 labs (regression, GLM, trees, clustering, association rules) with Rmd/HTML/PDF |
| [`std-471-statistical-learning-2`](coursework/std-471-statistical-learning-2/) | Statistical Learning for Data Science II | HW1–HW3, clustering homework + labs: cross-validation, GLM, SVM, BART, LSTM, neural networks, clustering |
| [`std-334-multivariate`](coursework/std-334-multivariate/) | Multivariate Analysis | PCA, factor analysis, cluster analysis, discriminant analysis (R scripts + data) |
| [`std-335-forecasting`](coursework/std-335-forecasting/) | Forecasting | Exponential smoothing, ACF/PACF, decomposition, stationarity tests (R) |
| [`std-421-design-of-experiment`](coursework/std-421-design-of-experiment/) | Design of Experiment | Assignments I–IV (CRD, RCBD, BIBD, LSD, factorial designs) |
| [`std-496-data-storytelling`](coursework/std-496-data-storytelling/) | Special Topic: Data Storytelling | Drying-mango case (decision tree, data quality) + EDA worksheet answers |

---

## Tech stack

- **R** — tidyverse (dplyr/ggplot2), caret, randomForest, xgboost, BART, mclust, glmnet, e1071, factoextra, psych, SHAPforxgboost, iml, arrow, fpp2
- **Python** — pandas, scikit-learn (exploratory work; see the notebook in the Texas project)
- **BI & data** — Power BI (DAX, Power Query), Excel, Git
- **Data sources used** — Ergast F1 API, Open-Meteo API, Kaggle (US Accidents, IBM HR Analytics, BankChurners), UCI ML Repository

## About the data in this repo

Raw datasets over 10 MB (US-Accidents parquet, MNIST/CIFAR/IMDB, large retail transactions, etc.) are **not** committed — each project README documents where to download them and how the code expects them to be laid out. Lecture slides and course materials authored by instructors are excluded; only my own reports, code and submitted work are kept.

## Repo layout

```
projects/     → 4 flagship projects (report + code + data dictionary + dashboard)
coursework/   → homework & labs per course
docs/         → how to add dashboard screenshots to the READMEs
```

---

*This repository is maintained privately while under development and is intended as supporting material for job applications.*
