# Texas Road-Accident Severity Prediction

**STD 471 — Statistical Learning for Data Science II (final project)** · Predicting road-crash severity in San Antonio, Texas by combining unsupervised and supervised learning.

> **โปรเจกต์รายวิชา STD 471** — ทำนายความรุนแรงของอุบัติเหตุทางถนนในเมืองซานอันโตนิโอ รัฐเท็กซัส ด้วยการผสม PCA + clustering (unsupervised) เข้ากับโมเดลทำนายแบบ supervised

**Team:** 65090502410 ณภัทร เกียรติกอบลาภ · 65090502414 ธนวินท์ แสงวิสุทธิ์ · 65090502417 ปิยพัทธ์ จันทร์ทวี

## Deliverables

| File | What it is |
|---|---|
| [`report/full-report.pdf`](report/full-report.pdf) | Full report (Thai) |
| [`report/full-report.html`](report/full-report.html) | Same report, rendered with all figures — opens directly on GitHub |
| [`code/`](code/) | R pipeline + exploratory Python notebook |
| [`data/texas_variable_descriptions.xlsx`](data/texas_variable_descriptions.xlsx) | Data dictionary for the variables used |

## Objective

Build a model that predicts crash **severity** (levels 1–4) in San Antonio, identify high-risk locations and times, and analyse the factors driving severity — to support traffic-signal planning and emergency resource allocation.

## Data

[US Accidents (Kaggle)](https://www.kaggle.com/datasets/sobhanmoosavi/us-accidents) — ~7.7 M accidents across 49 states, Feb 2016 – Mar 2023; filtered to **San Antonio, Texas**.

The raw file is **not** committed (51 MB parquet / 805 MB national file). To reproduce:

```bash
# download from Kaggle, then place one of these under data/
data/texas_accident.parquet   # state-level extract used in the report
```

Severity classes 1–2 were sampled at 20 %, classes 3–4 at 50 % (`set.seed(123)`) to handle class imbalance before modelling.

## Method

1. **Unsupervised** — PCA for dimensionality reduction, then **k-means** and **EM (mclust)** clustering; the number of clusters chosen with the `UniversalCVI` index family; cluster labels are then fed into the supervised stage as a feature.
2. **Supervised** — train/test split, models: **Random Forest, XGBoost, BART**, evaluated with **5-fold cross-validation** and compared on **F1-score**.
3. **Interpretation** — variable importance / SHAP from the winning model.
4. **Operational follow-up** — the three most common high-impact crash locations are picked and their **wait time** between incidents is estimated.

## Result

**XGBoost produced the highest F1-score** of the three models (accuracy above 50 % on a 4-class imbalanced problem) and was carried forward for variable analysis. Full numbers and plots: [`report/full-report.pdf`](report/full-report.pdf).

## Code

| File | Role |
|---|---|
| [`code/01_full-report.Rmd`](code/01_full-report.Rmd) | Main report source: preprocessing, PCA + clustering, RF/XGBoost/BART, CV, SHAP, wait-time analysis |
| [`code/02_distance-analysis.R`](code/02_distance-analysis.R) | Distance-based checks (Jaccard/Hamming) and PCA exploration |
| [`code/03_modeling-experiments.R`](code/03_modeling-experiments.R) | Scratch experiments: RF, CatBoost, logistic baseline |
| [`code/wine-uci-prototype.ipynb`](code/wine-uci-prototype.ipynb) | Earlier Python prototype on the UCI Wine dataset (method sandbox) |

## Reproduce

```r
# from projects/texas-accident-severity/
install.packages(c("arrow","dplyr","ggplot2","mclust","randomForest","xgboost","BART","SHAPforxgboost","UniversalCVI"))
rmarkdown::render("code/01_full-report.Rmd")
```

**Packages:** `dplyr`, `arrow`, `ggplot2`, `lubridate`, `mgcv`, `mclust`, `randomForest`, `xgboost`, `BART`, `pROC`, `UniversalCVI`, `pheatmap`, `SHAPforxgboost`.
