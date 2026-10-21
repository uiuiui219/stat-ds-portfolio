# F1 Driver Points Prediction

**Graduate project (โปรเจคจบ ป.ตรี)** · Predicting whether a Formula 1 driver finishes in the points (Top 10) using machine learning, with circuit clustering and explainable AI.

> **โปรเจคจบ ป.ตรี** — ทำนายว่านักขับ F1 จะได้คะแนน (Top 10) หรือไม่จากปัจจัยของสุดสัปดาห์แข่ง จัดกลุ่มสนามด้วย clustering และอธิบายโมเดลด้วย SHAP

**Team:** 65090502414 ธนวินท์ แสงวิสุทธิ์ · 65090502417 ปิยพัทธ์ จันทร์ทวี · +1 teammate

## Deliverables

| File | What it is |
|---|---|
| [`report/Full-Report-F1-Driver-Points-Prediction-TH.pdf`](report/Full-Report-F1-Driver-Points-Prediction-TH.pdf) | Full thesis-style report (Thai) |
| [`report/F1-Graduate-Poster.pdf`](report/F1-Graduate-Poster.pdf) | Graduate poster (EN/TH) |
| [`dashboard/f1-dashboard.pbix`](dashboard/f1-dashboard.pbix) | Power BI dashboard of the analysis |
| [`code/`](code/) | R pipeline (see below) |
| [`data/`](data/) | Derived tables, track characteristics, weather extracts, Ergast bundle |

## Objective

Predict, for each race entry, whether the driver finishes in the points positions (Top 10) — then interpret *why*, to surface which pre-race and in-race factors matter most.

## Data (2019–2024, 2,559 race entries)

| Source | Used for | In this repo? |
|---|---|---|
| [Ergast F1 API](http://ergast.com/mrd/) | results, grids, pit stops, qualifying, standings, lap times | ✅ [`data/ergast-f1-data.zip`](data/ergast-f1-data.zip) (incl. `lap_times.csv`) |
| [Open-Meteo](https://open-meteo.com/) | race-day temperature, rain, wind per circuit | 🔄 sample responses in [`data/weather/`](data/weather/); full table rebuilt by [`code/build_weather_circuit.R`](code/build_weather_circuit.R) |
| Pirelli Motorsport track data | tyre stress, lateral load, grip, downforce per GP | ✅ [`data/F1_pirelli.csv`](data/F1_pirelli.csv), [`data/F1_pirelli_with_turns.csv`](data/F1_pirelli_with_turns.csv) |
| Race weekend schedule | FP/quali/sprint session times (used to align weather windows) | ✅ [`data/f1_race_schedule.csv`](data/f1_race_schedule.csv) |
| Assembled weather table (`weather_circuit.csv`) | join weather onto each race | ⚠️ not committed — rebuild with `Rscript code/build_weather_circuit.R`, see [reproduction](#reproduce) |

## Method

1. **Feature engineering** — driver age, experience, rolling podium/points history, constructor wins, DNF flag built from weather-overlapping race windows; explicit **data-leakage review** (no post-race information leaks into features).
2. **Circuit clustering** — 128 circuits → Gower distance → hierarchical clustering → **5 clusters**, chosen by Average Silhouette Width; cluster membership used as a feature.
3. **Modelling** — Random Forest vs **XGBoost** with grid-search hyperparameters, evaluated with **time-series cross-validation** (expanding window, 4 folds): train 2019–2023, test = **2024 season**.
4. **Interpretation** — SHAP values (beeswarm + interaction effects); weather features and circuit-cluster features both land in the top 5.
5. **Deployment-ish view** — the Rmd also extends to a 3-class "podium / scoring / no points" assignment with quota constraints (3 + 7 + 10) for a full race-result table; Power BI presents the final view.

## Results (test set = 2024)

| Metric | XGBoost (best model) |
|---|---|
| ROC-AUC | **0.883** |
| Accuracy | **0.810** |
| Precision | **0.775** |
| Recall | **0.875** |
| F1-Score | **0.822** |

Feature importance is dominated by experience/podium history, grid position, weather variables and circuit cluster.

## Code

| File | Role |
|---|---|
| [`code/00_explore-ergast-data.R`](code/00_explore-ergast-data.R) | Unzips the Ergast bundle and explores raw tables |
| [`code/01_data-prep-and-modeling.Rmd`](code/01_data-prep-and-modeling.Rmd) | Main pipeline: joins, feature engineering, weather alignment, clustering, RF modelling (knit to HTML) |
| [`code/02_modeling-v1.R`](code/02_modeling-v1.R) | RF/XGBoost experiment (v1) with shared metrics helpers |
| [`code/03_modeling-v2-quota-and-strict.R`](code/03_modeling-v2-quota-and-strict.R) | v2: nationality bucketing + podium/scoring/no-point quota assignment, strict variant |

`setwd()` calls were removed from the copies in this repo — run everything **from this project folder** as the working directory.

## Reproduce

```bash
# from projects/f1-driver-points-prediction/
unzip data/ergast-f1-data.zip -d data/ergast     # provides results.csv, lap_times.csv, ...
Rscript code/build_weather_circuit.R             # rebuilds data/weather_circuit.csv from Open-Meteo (~3 min, network)
```

Then in R:

```r
# working directory must be the project root so data/... paths resolve
rmarkdown::render("code/01_data-prep-and-modeling.Rmd", knit_root_dir = normalizePath("."))
```

Packages: `dplyr`, `lubridate`, `ggplot2`, `randomForest`, `xgboost`, `caret`, `iml`, `tools`.

**Data note:** `data/weather_circuit.csv` (the per-race weather table) is not committed. It is rebuilt in one step by `code/build_weather_circuit.R`, which fetches a ±3-day hourly window (UTC, matching the committed sample responses) around every race from 2010 on (~305 windows) from the Open-Meteo archive API and assembles the exact layout that the parsing logic at the top of `01_data-prep-and-modeling.Rmd` expects (77-location metadata block + hourly rows tagged by `location_id`).
