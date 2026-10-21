# IBM Employee Attrition Prediction

**STD 371 — Statistical Learning for Data Science I (final project)** · Predicting employee attrition and profiling the highest-risk segment.

> **โปรเจกต์รายวิชา STD 371** — ทำนายการลาออกของพนักงาน พร้อมจำแนกกลุ่มพนักงานที่มีความเสี่ยงสูงสุดและวิเคราะห์ปัจจัยที่ส่งผล

**Team:** 65090502414 ธนวินท์ แสงวิสุทธิ์ · 65090502417 ปิยพัทธ์ จันทร์ทวี

## Deliverables

| File | What it is |
|---|---|
| [`report/Final-Report-2414_2417.html`](report/Final-Report-2414_2417.html) | Full report, rendered — opens directly in the browser ([also on the site](https://uiuiui219.github.io/stat-ds-portfolio/reports/ibm-full-report.html)) |
| [`code/01_full-report.Rmd`](code/01_full-report.Rmd) | Full report source — read it for the complete narrative (knit to HTML/Word/PDF) |
| [`code/02_eda-experiments.R`](code/02_eda-experiments.R) | EDA + clustering experiments |
| [`code/03_encoding-experiments.R`](code/03_encoding-experiments.R) | Categorical encoding experiments |
| [`code/04_smote-experiments.R`](code/04_smote-experiments.R) | SMOTE resampling experiments |
| [`data/`](data/) | `IBM_train.csv` (1,058 rows), `IBM_test.csv` |

## Objective

Identify employees likely to leave, and characterise the riskiest group well enough that an HR team could act on it.

## Data

IBM HR Analytics Employee Attrition & Performance (public HR dataset): 1,058 employees, mixed numeric/categorical features (age, tenure, satisfaction, income, overtime, …). Provided inside [`data/`](data/). Columns with zero variance (`Over18`, `StandardHours`, `EmployeeCount`, `EmployeeNumber`) are dropped at load time.

## Method

1. **Preprocessing** — drop non-informative columns, one-hot encode categoricals with `model.matrix()`, 80/20 train-test split (`set.seed(2417)`).
2. **Class imbalance** — **SMOTE** oversampling experiments (`smotefamily`).
3. **Unsupervised** — clustering with multiple validity indices (`UniversalCVI`, `BayesCVI`), plus **PCA** keeping components that explain **> 80 %** of variance for interpretability.
4. **Modelling** — Random Forest, XGBoost, glmnet and a logistic baseline, each with k-fold cross-validation; **selected on F1-score** because both missing a likely leaver (recall) and falsely flagging a stayer (precision) matter.
5. **Profiling** — variable importance + cluster-level interpretation of the highest-risk segment.

## Result

- **Random Forest achieved the highest F1-score** among the compared models → used for variable-importance analysis.
- The highest-risk cluster (cluster 2) shows **38.18 % attrition (21 of 55 employees)**; its drivers are low **JobInvolvement** (β ≈ −0.758), low **StockOptionLevel** (β ≈ −0.776) and low **JobSatisfaction** (β ≈ −0.520).

Full tables and figures: [`code/01_full-report.Rmd`](code/01_full-report.Rmd), or the [rendered report](report/Final-Report-2414_2417.html).

## Reproduce

```r
# from projects/ibm-attrition-prediction/ (working directory must be the project root)
install.packages(c("dplyr","ggplot2","psych","factoextra","caret","glmnet",
                   "randomForest","xgboost","mclust","UniversalCVI","BayesCVI","smotefamily"))
rmarkdown::render("code/01_full-report.Rmd", knit_root_dir = normalizePath("."))
```

**Packages:** `dplyr`, `ggplot2`, `ggpubr`, `imager`, `mvtnorm`, `e1071`, `mclust`, `UniversalCVI`, `BayesCVI`, `corrplot`, `psych`, `glmnet`, `factoextra`, `caret`, `randomForest`, `xgboost`, `performanceEstimation`, `smotefamily`, `MASS`, `Ckmeans.1d.dp`.
