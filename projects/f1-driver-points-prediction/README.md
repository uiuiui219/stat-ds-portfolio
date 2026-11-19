# Analyzing Factors Influencing Formula 1 Driver Scores Using Machine Learning

**Graduate project (โปรเจกต์จบปริญญาตรี)** · *การวิเคราะห์ปัจจัยที่ส่งผลต่อการได้คะแนนนักขับฟอร์มูล่าวัน ด้วยเทคนิคการเรียนรู้ของเครื่อง*

**Team:** Thanawin Sangvisut · Piyapat Jantawee · Sirasak Klangsomboon

The study predicts, in a binary setup, whether a Formula 1 driver scores points in a race, then explains which factors drive that outcome. It uses race data from 2019 to 2024 — 2,559 race entries collected from the Ergast API, Open-Meteo and Pirelli Motorsport.

## Objectives

1. Classify and group Formula 1 circuits by their characteristics.
2. Compare the performance of models that predict a driver's points in each race.
3. Analyse and explain how much each factor contributes to a driver scoring points.

## Expected outcomes

1. A prediction model for driver points with acceptable accuracy.
2. An understanding of which factors influence a driver's points most.
3. Input for teams planning strategy under different race conditions.

## Data (2019–2024, 2,559 race entries)

| Source | Used for | In this repository? |
|---|---|---|
| [Ergast F1 API](http://ergast.com/mrd/) | results, grids, pit stops, qualifying, standings, lap times | ✅ [`data/ergast-f1-data.zip`](data/ergast-f1-data.zip) (includes `lap_times.csv`) |
| [Open-Meteo](https://open-meteo.com/) | race-day temperature, rain and wind per circuit | 🔄 sample responses in [`data/weather/`](data/weather/); the full table is rebuilt by [`code/build_weather_circuit.R`](code/build_weather_circuit.R) |
| Pirelli Motorsport track data | tyre stress, lateral load, grip, downforce per Grand Prix | ✅ [`data/F1_pirelli.csv`](data/F1_pirelli.csv), [`data/F1_pirelli_with_turns.csv`](data/F1_pirelli_with_turns.csv) |
| Race weekend schedule | FP / qualifying / sprint session times, used to align weather windows | ✅ [`data/f1_race_schedule.csv`](data/f1_race_schedule.csv) |
| Assembled weather table (`weather_circuit.csv`) | joins weather onto each race | ⚠️ not committed; rebuild with `Rscript code/build_weather_circuit.R` (see [Reproduce](#reproduce)) |

The variables fall into six groups: basic driver and team information, experience and performance, race data, weather and race context, physical circuit characteristics, and technical circuit characteristics. Only information that exists before a race is used as a predictor, which keeps post-race results out of the input and avoids data leakage.

## Method

1. **Feature engineering** — driver age, experience, lagged cumulative podiums and points, constructor wins, and a DNF flag built from weather-overlapping race windows. Every cumulative variable is lagged so the current race cannot leak into its own predictor; a leakage review is part of the pipeline.
2. **Circuit clustering** — 128 circuits described by Pirelli track characteristics plus race-derived rates → Gower distance → hierarchical clustering (complete linkage) → **5 clusters**, chosen with cluster-validity indices including average silhouette width. Cluster membership is then joined back as a feature.
3. **Modelling** — Random Forest and **XGBoost**, tuned by grid search and evaluated with **time-series cross-validation** (expanding window, 4 folds): train 2019–2023, test = **2024 season**.
4. **Interpretation** — SHAP values. The starting grid position has the highest influence, followed by the potential and past performance of the team and the driver; circuit type and weather have low influence.

An extension in `02_modeling-v1.R` and `03_modeling-v2-quota-and-strict.R` assigns a full race field to podium / scoring / no-points slots under the 3 + 7 + 10 quota. It is supplementary analysis, not the main research question.

## Results (test set = 2024)

| Metric | XGBoost (best model) |
|---|---|
| ROC-AUC | **0.883** |
| Accuracy | **0.810** |
| Precision | **0.775** |
| Recall | **0.875** |
| F1-Score | **0.822** |

## Deliverables

| File | What it is |
|---|---|
| [`report/Full-Report-F1-Driver-Points-Prediction-TH.pdf`](report/Full-Report-F1-Driver-Points-Prediction-TH.pdf) | Full project report (Thai) |
| [`report/F1-Graduate-Poster.pdf`](report/F1-Graduate-Poster.pdf) | Project poster (EN/TH). The poster presentation won first place in the department's graduate-project poster session. |
| [`code/`](code/) | R pipeline (see below) |
| [`data/`](data/) | Derived tables, track characteristics, weather extracts, Ergast bundle |

## Code

| File | Role |
|---|---|
| [`code/00_explore-ergast-data.R`](code/00_explore-ergast-data.R) | Unzips the Ergast bundle and explores the raw tables |
| [`code/01_data-prep-and-modeling.Rmd`](code/01_data-prep-and-modeling.Rmd) | Main pipeline: joins, feature engineering, weather alignment, clustering, Random Forest, with a quota-assignment demo |
| [`code/02_modeling-v1.R`](code/02_modeling-v1.R) | RF and XGBoost comparison with expanding-window CV and per-fold metrics |
| [`code/03_modeling-v2-quota-and-strict.R`](code/03_modeling-v2-quota-and-strict.R) | v2: nationality bucketing, strict and non-strict quota assignment, tuned hyperparameters, SHAP |
| [`code/build_weather_circuit.R`](code/build_weather_circuit.R) | Rebuilds `data/weather_circuit.csv` from the Open-Meteo archive API |

`setwd()` calls were removed from the copies in this repository — run everything with this project folder as the working directory.

## Reproduce

```bash
# from projects/f1-driver-points-prediction/
unzip data/ergast-f1-data.zip -d data/ergast     # provides results.csv, lap_times.csv, ...
Rscript code/build_weather_circuit.R             # rebuilds data/weather_circuit.csv from Open-Meteo (~3 min, network)
```

Then in R:

```r
# the working directory must be the project root so data/... paths resolve
rmarkdown::render("code/01_data-prep-and-modeling.Rmd", knit_root_dir = normalizePath("."))
```

Packages: `dplyr`, `lubridate`, `ggplot2`, `randomForest`, `xgboost`, `caret`, `iml`, `tools`.

**Data note.** `data/weather_circuit.csv` is not committed. `code/build_weather_circuit.R` rebuilds it in one step: it fetches a ±3-day hourly window (UTC) around every race from 2010 onwards (~305 windows) from the Open-Meteo archive API and assembles the layout that the parsing logic at the top of `01_data-prep-and-modeling.Rmd` expects (77-location metadata block plus hourly rows tagged by `location_id`).
