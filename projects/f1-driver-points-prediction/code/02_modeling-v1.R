library(randomForest)
library(xgboost)
library(dplyr)
library(caret)
library(iml)

# setwd() removed — run with the project root as working directory

# ============================================================
# Load & Preprocessing
# ============================================================
final_table_with_cluster <- read.csv("data/final_table_with_cluster.csv")
final_table_with_cluster <- final_table_with_cluster |> select(-X)
final_table_with_cluster$score_group <- as.factor(final_table_with_cluster$score_group)

nationality_threshold <- 10

keep_nationalities <- final_table_with_cluster %>%
  filter(year < 2024) %>%
  count(Nationality) %>%
  filter(n >= nationality_threshold) %>%
  pull(Nationality)

final_table_with_cluster <- final_table_with_cluster %>%
  mutate(Nationality = if_else(Nationality %in% keep_nationalities,
                               Nationality, "Other"))

# ============================================================
# Helper Functions
# ============================================================
align_matrix <- function(test_mat, train_cols) {
  missing <- setdiff(train_cols, colnames(test_mat))
  if (length(missing) > 0) {
    extra <- matrix(0, nrow = nrow(test_mat), ncol = length(missing),
                    dimnames = list(NULL, missing))
    test_mat <- cbind(test_mat, extra)
  }
  test_mat[, train_cols, drop = FALSE]
}

get_metrics <- function(actual, predicted, model_name, yr, rnd) {
  cm <- confusionMatrix(predicted, actual)
  data.frame(
    model           = model_name,
    year            = yr,
    round           = rnd,
    accuracy        = cm$overall["Accuracy"],
    f1_macro        = mean(cm$byClass[, "F1"], na.rm = TRUE),
    f1_weighted     = weighted.mean(cm$byClass[, "F1"],
                                    w = table(actual), na.rm = TRUE),
    precision_macro = mean(cm$byClass[, "Precision"], na.rm = TRUE),
    recall_macro    = mean(cm$byClass[, "Recall"],    na.rm = TRUE)
  )
}

assign_topN <- function(prob_df) {
  final_pred  <- rep(NA, nrow(prob_df))
  podium_idx  <- order(prob_df[, "podium"],   decreasing = TRUE)[1:3]
  scoring_idx <- setdiff(order(prob_df[, "scoring"],  decreasing = TRUE), podium_idx)[1:7]
  nopoint_idx <- setdiff(order(prob_df[, "no_point"], decreasing = TRUE),
                         c(podium_idx, scoring_idx))[1:10]
  final_pred[podium_idx]  <- "podium"
  final_pred[scoring_idx] <- "scoring"
  final_pred[nopoint_idx] <- "no_point"
  final_pred
}

# ============================================================
# Data Split
# ============================================================
data_train_val <- final_table_with_cluster %>% filter(year < 2024)
data_test_2024 <- final_table_with_cluster %>%
  filter(year == 2024, round %in% 1:20) %>%
  arrange(round)

lvls <- levels(final_table_with_cluster$score_group)

# ============================================================
# STEP 1: Expanding Window CV บน 2019-2023 (Default Hyperparameter)
# ============================================================
all_rounds <- data_train_val %>%
  arrange(year, round) %>%
  distinct(year, round) %>%
  mutate(fold_id = row_number())

initial_rounds <- 2
eval_results   <- list()
pred_records   <- list()

for (f in (initial_rounds + 1):nrow(all_rounds)) {
  
  train_folds <- all_rounds %>% filter(fold_id < f)
  test_fold   <- all_rounds %>% filter(fold_id == f)
  
  train_df <- data_train_val %>%
    inner_join(train_folds %>% select(year, round), by = c("year", "round"))
  test_df <- data_train_val %>%
    inner_join(test_fold %>% select(year, round), by = c("year", "round"))
  
  # RF default
  rf_fit  <- randomForest(score_group ~ ., data = train_df, ntree = 500)
  rf_pred <- predict(rf_fit, newdata = test_df)
  
  # XGBoost default
  train_matrix <- model.matrix(score_group ~ . - 1, data = train_df)
  test_matrix  <- align_matrix(
    model.matrix(score_group ~ . - 1, data = test_df),
    colnames(train_matrix)
  )
  xgb_tr <- xgb.DMatrix(data  = train_matrix,
                        label = as.integer(train_df$score_group) - 1)
  xgb_te  <- xgb.DMatrix(data = test_matrix)
  xgb_fit <- xgb.train(
    params  = list(objective = "multi:softmax", num_class = 3,
                   eta = 0.3, max_depth = 6, eval_metric = "merror"),
    data    = xgb_tr, nrounds = 100, verbose = 0
  )
  xgb_pred <- factor(
    levels(train_df$score_group)[predict(xgb_fit, xgb_te) + 1],
    levels = levels(train_df$score_group)
  )
  
  eval_results[[f]] <- bind_rows(
    get_metrics(test_df$score_group, rf_pred,  "RF",
                test_fold$year, test_fold$round),
    get_metrics(test_df$score_group, xgb_pred, "XGBoost",
                test_fold$year, test_fold$round)
  )
  
  pred_records[[f]] <- data.frame(
    year     = test_fold$year,
    round    = test_fold$round,
    actual   = test_df$score_group,
    pred_rf  = rf_pred,
    pred_xgb = xgb_pred
  )
  
  if (f %% 20 == 0) message(sprintf("Fold %d/%d เสร็จแล้ว", f, nrow(all_rounds)))
}

eval_df    <- bind_rows(eval_results)
pred_df_cv <- bind_rows(pred_records)

eval_summary <- eval_df %>%
  group_by(model) %>%
  summarise(across(c(accuracy, f1_macro, f1_weighted, precision_macro, recall_macro),
                   \(x) mean(x, na.rm = TRUE)))
print(eval_summary)

# Confusion Matrix: Validate (2019-2023)
cm_rf_val <- confusionMatrix(
  factor(pred_df_cv$pred_rf,  levels = lvls),
  factor(pred_df_cv$actual,   levels = lvls)
)
cm_xgb_val <- confusionMatrix(
  factor(pred_df_cv$pred_xgb, levels = lvls),
  factor(pred_df_cv$actual,   levels = lvls)
)
message("=== Confusion Matrix: RF (Validate 2019-2023) ===");      print(cm_rf_val)
message("=== Confusion Matrix: XGBoost (Validate 2019-2023) ==="); print(cm_xgb_val)

# ============================================================
# STEP 2: Tune ครั้งเดียว (Random Search + Time-series CV)
# ============================================================
full_train <- data_train_val %>% arrange(year, round)
n_iter     <- 20

ts_index <- list()
for (yr in 2020:2023) {
  ts_index[[as.character(yr)]] <- which(full_train$year < yr)
}

ts_ctrl <- trainControl(
  method          = "cv",
  index           = ts_index,
  classProbs      = TRUE,
  summaryFunction = multiClassSummary,
  verboseIter     = TRUE,
  allowParallel   = TRUE
)

library(doParallel)
cl <- makeCluster(detectCores() - 1)
registerDoParallel(cl)

set.seed(42)
rf_tune <- train(
  score_group ~ ., data = full_train,
  method     = "rf",
  trControl  = ts_ctrl,
  tuneLength = n_iter,
  ntree      = 200,
  metric     = "Mean_F1"
)
best_rf_params <- rf_tune$bestTune
message("Best RF params:"); print(best_rf_params)

set.seed(42)
xgb_grid <- data.frame(
  nrounds          = sample(c(100, 200), n_iter, replace = TRUE),
  max_depth        = sample(3:8,  n_iter, replace = TRUE),
  eta              = runif(n_iter, 0.05, 0.3),
  gamma            = runif(n_iter, 0, 2),
  colsample_bytree = runif(n_iter, 0.6, 1),
  min_child_weight = sample(1:6,  n_iter, replace = TRUE),
  subsample        = runif(n_iter, 0.6, 1)
) %>% distinct()

xgb_tune <- train(
  score_group ~ ., data = full_train,
  method    = "xgbTree",
  trControl = ts_ctrl,
  tuneGrid  = xgb_grid,
  metric    = "Mean_F1"
)
best_xgb_params <- xgb_tune$bestTune
message("Best XGBoost params:"); print(best_xgb_params)

stopCluster(cl)
registerDoSEQ()

# ============================================================
# STEP 3: Test บน 2024 (Expanding Window ด้วย Best Hyperparameter)
# ============================================================
results_2024 <- list()
varimp_2024  <- list()
train_df     <- full_train

for (r in unique(data_test_2024$round)) {
  
  message(sprintf("--- 2024 Round %d ---", r))
  test_df <- data_test_2024 %>% filter(round == r)
  
  # RF best
  rf_final <- randomForest(
    score_group ~ ., data = train_df,
    ntree = 500, mtry = best_rf_params$mtry
  )
  rf_prob <- predict(rf_final, newdata = test_df, type = "prob")
  
  # XGBoost best
  train_matrix <- model.matrix(score_group ~ . - 1, data = train_df)
  test_matrix  <- align_matrix(
    model.matrix(score_group ~ . - 1, data = test_df),
    colnames(train_matrix)
  )
  xgb_tr <- xgb.DMatrix(data  = train_matrix,
                        label = as.integer(train_df$score_group) - 1)
  xgb_te  <- xgb.DMatrix(data = test_matrix)
  xgb_final <- xgb.train(
    params = list(
      objective        = "multi:softprob",
      num_class        = 3,
      eta              = best_xgb_params$eta,
      max_depth        = best_xgb_params$max_depth,
      gamma            = best_xgb_params$gamma,
      colsample_bytree = best_xgb_params$colsample_bytree,
      min_child_weight = best_xgb_params$min_child_weight,
      subsample        = best_xgb_params$subsample,
      eval_metric      = "merror"
    ),
    data    = xgb_tr,
    nrounds = best_xgb_params$nrounds,
    verbose = 0
  )
  
  xgb_prob_raw <- predict(xgb_final, xgb_te)
  xgb_prob     <- matrix(xgb_prob_raw, ncol = 3, byrow = TRUE)
  colnames(xgb_prob) <- levels(train_df$score_group)
  
  pred_df <- test_df %>%
    mutate(
      pred_rf  = assign_topN(rf_prob),   # ✅ เปลี่ยนกลับเป็น assign_topN
      pred_xgb = assign_topN(xgb_prob)  # ✅ เปลี่ยนกลับเป็น assign_topN
    )
  
  results_2024[[paste0("round_", r)]] <- pred_df
  varimp_2024[[paste0("round_", r)]]  <- list(
    rf  = importance(rf_final),
    xgb = xgb.importance(model = xgb_final)
  )
  
  train_df <- bind_rows(train_df, test_df)
}

all_results_2024 <- bind_rows(results_2024)

# ============================================================
# STEP 4: เปรียบเทียบ RF vs XGBoost บน 2024
# ============================================================
compare_2024 <- bind_rows(
  get_metrics(all_results_2024$score_group,
              factor(all_results_2024$pred_rf,  levels = lvls), "RF",      2024, "all"),
  get_metrics(all_results_2024$score_group,
              factor(all_results_2024$pred_xgb, levels = lvls), "XGBoost", 2024, "all")
)
print(compare_2024)

# Confusion Matrix: Test (2024)
cm_rf_test <- confusionMatrix(
  factor(all_results_2024$pred_rf,     levels = lvls),
  factor(all_results_2024$score_group, levels = lvls)
)
cm_xgb_test <- confusionMatrix(
  factor(all_results_2024$pred_xgb,    levels = lvls),
  factor(all_results_2024$score_group, levels = lvls)
)
message("=== Confusion Matrix: RF (Test 2024) ===");      print(cm_rf_test)
message("=== Confusion Matrix: XGBoost (Test 2024) ==="); print(cm_xgb_test)

# ============================================================
# STEP 5: SHAP ด้วย Best Model (train บน 2019-2023 ทั้งหมด)
# ============================================================
# ← เปลี่ยนเป็น xgb ถ้า XGBoost ชนะจาก compare_2024
shap_train <- full_train  # 2019-2023 ทั้งหมด ไม่รวม 2024

best_model_shap <- randomForest(
  score_group ~ ., data = shap_train,
  ntree = 500, mtry = best_rf_params$mtry
)

predictor <- Predictor$new(
  model = best_model_shap,
  data  = shap_train %>% select(-score_group),
  y     = shap_train$score_group,
  type  = "prob"
)

shap_global <- FeatureImp$new(predictor, loss = "ce")
plot(shap_global)

