library(dplyr)
library(ggplot2)
library(ggpubr)
library(imager)
# generate data
library(mvtnorm)
# Clustering Algorithm
library(e1071)
library(mclust)
# CVI
library(UniversalCVI)
library(BayesCVI)
library(corrplot)
library(psych)
library(glmnet)
library(factoextra)


ibm <- read.csv("data/IBM_train.csv")
sum(is.na(ibm))

str(ibm)
colnames(ibm)
# delete "over18" ,"standard hours", "employee count" for uniqueness
ibm <- ibm[,-c(9,22,27)]

ibm_cate <- ibm[,c('BusinessTravel', 'Department', 'EducationField', 'Gender', 'JobRole',
                   'MaritalStatus', 'OverTime')]
ibm_num <- ibm[,c('Age', 'Attrition', 'DailyRate', 'DistanceFromHome', 'Education',
                  'EmployeeNumber', 'EnvironmentSatisfaction',
                  'HourlyRate', 'JobInvolvement', 'JobLevel', 'JobSatisfaction',
                  'MonthlyIncome', 'MonthlyRate', 'NumCompaniesWorked',
                  'PercentSalaryHike', 'PerformanceRating', 'RelationshipSatisfaction',
                  'StockOptionLevel', 'TotalWorkingYears',
                  'TrainingTimesLastYear', 'WorkLifeBalance', 'YearsAtCompany',
                  'YearsInCurrentRole', 'YearsSinceLastPromotion',
                  'YearsWithCurrManager')]

str(ibm_cate)
str(ibm_num)

str(ibm)

# target variable
ibm$Attrition <- as.factor(ibm$Attrition)
table(ibm$Attrition)
set.seed(2417)
train_idx <- sample(1:nrow(ibm), size = 0.8 * nrow(ibm))
ibm_train <- ibm[train_idx, ]
ibm_test <- ibm[-train_idx, ]

dim(ibm_train)
dim(ibm_test)


ibm_mat <- model.matrix(Attrition~., data = ibm_train)

ibm_mat_att <- cbind(ibm_train$Attrition, ibm_mat[,-1])
colnames(ibm_mat_att)[1] <- "Attrition"
ibm_mat_att <- data.frame(ibm_mat_att)
ibm_mat_att$Attrition <- as.factor(ibm_mat_att$Attrition - 1)


test <- model.matrix(Attrition~., data = ibm_test)

mat_test <- cbind(ibm_test$Attrition, test[,-1])
colnames(mat_test)[1] <- "Attrition"
mat_test <- data.frame(mat_test)
mat_test$Attrition <- as.factor(mat_test$Attrition - 1)

library(smotefamily)

sm <- BLSMOTE(ibm_mat_att[,-1], ibm_mat_att$Attrition, K=5 ,C=5)

table(sm$data$class)

smt <- sm$data

smt$class <- as.factor(smt$class)


# สำหรับ Random Forest (ใช้ factor)
smt_rf <- smt
smt_rf$class <- as.factor(smt_rf$class)

# สำหรับ XGBoost (ใช้ numeric 0,1)
smt_xg <- smt
smt_xg$class <- as.numeric(as.character(smt_xg$class))
smt_xg$class <- ifelse(smt_xg$class == 1, 1, 0)

table(smt_rf$class)
table(smt_xg$class)

library(caret)
library(randomForest)

rf_cv <- function(data, target_var, n_iter = 10, test_size = 0.2) {
  acc <- c(); prec <- c(); rec <- c(); f1 <- c()
  
  for (i in 1:n_iter) {
    set.seed(i)
    train_idx <- sample(1:nrow(data), size = floor((1 - test_size) * nrow(data)))
    train <- data[train_idx, ]
    test <- data[-train_idx, ]
    
    rf_model <- randomForest(as.formula(paste(target_var, "~ .")), data = train, ntree = 100)
    pred <- predict(rf_model, test)
    
    cm <- confusionMatrix(pred, test[[target_var]])
    
    acc[i] <- cm$overall["Accuracy"]
    prec[i] <- cm$byClass["Precision"]
    rec[i] <- cm$byClass["Recall"]
    f1[i] <- cm$byClass["F1"]
  }
  
  result <- data.frame(
    Accuracy = mean(acc),
    Precision = mean(prec),
    Recall = mean(rec),
    F1_Score = mean(f1)
  )
  return(result)
}

library(xgboost)

xgb_cv <- function(data, target_var, n_iter = 10, test_size = 0.2) {
  acc <- c(); prec <- c(); rec <- c(); f1 <- c()
  
  for (i in 1:n_iter) {
    set.seed(i)
    idx <- sample(1:nrow(data), size = floor((1 - test_size) * nrow(data)))
    train <- data[idx, ]
    test <- data[-idx, ]
    
    dtrain <- xgb.DMatrix(data = as.matrix(train[, -which(names(train) == target_var)]),
                          label = train[[target_var]])
    dtest <- xgb.DMatrix(data = as.matrix(test[, -which(names(test) == target_var)]),
                         label = test[[target_var]])
    
    xgb_model <- xgboost(data = dtrain, nrounds = 100, objective = "binary:logistic", verbose = 0)
    pred_prob <- predict(xgb_model, dtest)
    pred <- ifelse(pred_prob > 0.5, 1, 0)
    
    cm <- confusionMatrix(as.factor(pred), as.factor(test[[target_var]]))
    
    acc[i] <- cm$overall["Accuracy"]
    prec[i] <- cm$byClass["Precision"]
    rec[i] <- cm$byClass["Recall"]
    f1[i] <- cm$byClass["F1"]
  }
  
  result <- data.frame(
    Accuracy = mean(acc),
    Precision = mean(prec),
    Recall = mean(rec),
    F1_Score = mean(f1)
  )
  return(result)
}

rf_result <- rf_cv(smt_rf, "class", n_iter = 10)
xgb_result <- xgb_cv(smt_xg, "class", n_iter = 10)

print(rf_result)
print(xgb_result)

library(randomForest)

# สร้างชุด train/test ชุดเดียว (ใช้ random seed เดียวกันกับใน CV)
set.seed(2417)
idx <- sample(1:nrow(smt_rf), size = floor(0.8 * nrow(smt_rf)))
train_rf <- smt_rf[idx, ]
test_rf <- smt_rf[-idx, ]

train_xg <- smt_xg[idx, ]
test_xg <- smt_xg[-idx, ]

# ===== Train Random Forest Model =====
library(randomForest)
rf_model <- randomForest(class ~ ., data = train_rf, ntree = 100, importance = TRUE)

# ===== Train XGBoost Model =====
library(xgboost)
dtrain <- xgb.DMatrix(data = as.matrix(train_xg[, -which(names(train_xg) == "class")]),
                      label = train_xg$class)
dtest <- xgb.DMatrix(data = as.matrix(test_xg[, -which(names(test_xg) == "class")]),
                     label = test_xg$class)

xgb_model <- xgboost(data = dtrain, nrounds = 100, objective = "binary:logistic", verbose = 0)

# ความสำคัญของตัวแปร
importance(rf_model)

# กราฟความสำคัญ
varImpPlot(rf_model, type = 1)  # MeanDecreaseAccuracy
varImpPlot(rf_model, type = 2)  # MeanDecreaseGini

# สร้างตารางความสำคัญของฟีเจอร์
feature_names <- colnames(train_xg[, -which(names(train_xg) == "class")])
importance_matrix <- xgb.importance(feature_names = feature_names, model = xgb_model)
print(head(importance_matrix))

# สร้างกราฟความสำคัญของฟีเจอร์ด้วย xgb.ggplot.importance
p <- xgb.ggplot.importance(importance_matrix)

# ปรับแต่งกราฟให้เป็นแบบโมโนโครม (ใช้สีเดียวกันทั้งหมด)
p + 
  scale_fill_manual(values = rep("black", nrow(importance_matrix))) +
  theme_minimal() +
  theme(legend.position = "none")


# กราฟ
library(Ckmeans.1d.dp)
library(ggplot2)

# logistic: ใช้ factor สำหรับ target
smt_logi <- smt
smt_logi$class <- as.factor(smt_logi$class)

library(caret)
library(MASS)

logistic_cv <- function(data, target_var, method = c("full", "forward", "backward", "stepwise"), n_iter = 1, test_size = 0.2) {
  acc <- c(); prec <- c(); rec <- c(); f1 <- c()
  method <- match.arg(method)
  
  for (i in 1:n_iter) {
    set.seed(i)
    idx <- sample(1:nrow(data), size = floor((1 - test_size) * nrow(data)))
    train <- data[idx, ]
    test <- data[-idx, ]
    
    # Full model
    full_model <- glm(as.formula(paste(target_var, "~ .")), data = train, family = binomial)
    
    # Subset Selection
    if (method == "full") {
      final_model <- full_model
    } else if (method == "forward") {
      null_model <- glm(as.formula(paste(target_var, "~ 1")), data = train, family = binomial)
      final_model <- step(null_model, scope = list(lower = null_model, upper = full_model), direction = "forward", trace = 0)
    } else if (method == "backward") {
      final_model <- step(full_model, direction = "backward", trace = 0)
    } else if (method == "stepwise") {
      null_model <- glm(as.formula(paste(target_var, "~ 1")), data = train, family = binomial)
      final_model <- step(null_model, scope = list(lower = null_model, upper = full_model), direction = "both", trace = 0)
    }
    
    # Predict and evaluate
    prob <- predict(final_model, newdata = test, type = "response")
    pred <- ifelse(prob > 0.5, 1, 0)
    
    cm <- confusionMatrix(as.factor(pred), test[[target_var]])
    
    acc[i] <- cm$overall["Accuracy"]
    prec[i] <- cm$byClass["Precision"]
    rec[i] <- cm$byClass["Recall"]
    f1[i] <- cm$byClass["F1"]
  }
  
  result <- data.frame(
    SubsetMethod = method,
    Accuracy = mean(acc),
    Precision = mean(prec),
    Recall = mean(rec),
    F1_Score = mean(f1)
  )
  return(result)
}
logi_full <- logistic_cv(smt_logi, "class", method = "full")
logi_fwd <- logistic_cv(smt_logi, "class", method = "forward")
logi_bwd <- logistic_cv(smt_logi, "class", method = "backward")
logi_step <- logistic_cv(smt_logi, "class", method = "stepwise")

# รวมผลลัพธ์
logi_results <- rbind(logi_full, logi_fwd, logi_bwd, logi_step)
print(logi_results)








# ==== Step 1: Feature Importance from XGBoost ====
xgb_imp <- xgb.importance(feature_names = colnames(train_xg[, -which(names(train_xg) == "class")]),
                          model = xgb_model)
top_xgb <- head(xgb_imp$Feature, 10)  # เลือก top 10 จาก XGBoost

# ==== Step 2: Feature Importance from Random Forest ====
rf_imp <- importance(rf_model, type = 1)  # MeanDecreaseAccuracy
rf_imp_df <- data.frame(Feature = rownames(rf_imp), Importance = rf_imp[, 1])
rf_imp_df <- rf_imp_df[order(-rf_imp_df$Importance), ]
top_rf <- head(rf_imp_df$Feature, 10)  # เลือก top 10 จาก Random Forest

# ==== Step 3: รวมชื่อฟีเจอร์ที่สำคัญ ====
selected_features <- intersect(top_xgb, top_rf)  # หรือใช้ intersect(top_xgb, top_rf) หากต้องการเฉพาะที่ซ้ำ

# ==== Step 4: Subset ข้อมูลเฉพาะฟีเจอร์สำคัญ ====
data_clustering <- smt_xg[, selected_features]  # ใช้ชุดที่ไม่รวม class

# ==== Optional: Standardize ก่อน clustering ====
data_scaled <- scale(data_clustering)

# ==== Step 5: PCA เพื่อลดมิติ (ถ้าต้องการ) ====
pca_res <- prcomp(data_scaled, center = TRUE, scale. = TRUE)
var <- (pca_res$sdev)^2
var_ratio <- var/sum(var)
cumu <- cumsum(var_ratio)
plot(cumu, type = "b")
pca_data <- as.data.frame(pca_res$x[, 1:4])  # ใช้แค่ 2 principal components

# เลือกว่าจะใช้อะไรดี Kmean or Hclust
k_check <- 1:15
for (i in 1:15){
  km <- kmeans(pca_data, centers = i, nstart = 100)
  k_check[i] <- km$tot.withinss
}
plot(k_check, type = "b")
hc_com <- hclust(dist(pca_data), method = "complete")
hc_avg <- hclust(dist(pca_data), method = "average")
hc_sin <- hclust(dist(pca_data), method = "single")

plot(hc_com)
plot(hc_avg)
plot(hc_sin)

cvi_km <- Hvalid(pca_data, kmax = 10, kmin = 2, indexlist = c("NCI", "DI", "DB", "DBs", "CSL", "CH"), 
                 method = "kmeans", p = 2, q = 2, corr = "pearson", nstart = 100, NCstart = TRUE)

cvi_c <- Hvalid(pca_data, kmax = 10, kmin = 2, indexlist = c("NCI", "DI", "DB", "DBs", "CSL", "CH"), 
                method = "hclust_complete", p = 2, q = 2, corr = "pearson", nstart = 100, NCstart = TRUE)

cvi_a <- Hvalid(pca_data, kmax = 10, kmin = 2, indexlist = c("NCI", "DI", "DB", "DBs", "CSL", "CH"), 
                method = "hclust_average", p = 2, q = 2, corr = "pearson", nstart = 100, NCstart = TRUE)
cvi_s <- Hvalid(pca_data, kmax = 2, kmin = 2, indexlist = c("NCI", "DI", "DB", "DBs", "CSL", "CH"), 
                method = "hclust_single", p = 2, q = 2, corr = "pearson", nstart = 100, NCstart = TRUE)

par(mfrow = c(1,1))

plot_idx(cvi_km)
plot_idx(cvi_c)
plot_idx(cvi_a)
plot_idx(cvi_s)


# kmean
set.seed(123)
kmeans_res <- kmeans(pca_data, centers = 3)
fviz_cluster(kmeans_res, data = pca_data, ellipse.type = "convex", geom = "point", palette = "jco")
# hc_com plot
fviz_cluster(list(data = pca_data, cluster = cutree(hc_com, k = 2)), 
             ellipse.type = "convex", geom = "point", palette = "jco")
# hc_avg plot
fviz_cluster(list(data = pca_data, cluster = cutree(hc_avg, k = 2)), 
             ellipse.type = "convex", geom = "point", palette = "jco")
# hc_sin plot
fviz_cluster(list(data = pca_data, cluster = cutree(hc_sin, k = 2)), 
             ellipse.type = "convex", geom = "point", palette = "jco")


# 1. โหลดings matrix: original features x principal components
loadings <- pca_res$rotation[, 1:4]  # PCA loadings

# 2. centers ใน PCA space
centers_pca <- kmeans_res$centers  # cluster centers in PC space

# 3. คำนวณ centers ใน original feature space
# matrix multiplication: cluster_centers_in_original_space = centers_pca %*% t(loadings)
centers_orig <- centers_pca %*% t(loadings)

# 4. เปลี่ยนเป็น data.frame และดู feature ที่เด่นในแต่ละกลุ่ม
centers_orig <- as.data.frame(centers_orig)
rownames(centers_orig) <- paste0("Cluster", 1:nrow(centers_orig))

# วนลูปสร้าง barplot สำหรับ Cluster 1 ถึง Cluster 5
par(mfrow = c(1, 1))  # จัด layout ให้แสดงหลายกราฟพร้อมกัน (3 แถว 2 คอลัมน์)

for (i in 1:3) {
  cluster_values <- centers_orig[paste0("Cluster", i), ]
  cluster_vector <- as.numeric(cluster_values)
  names(cluster_vector) <- colnames(centers_orig)
  sorted_values <- sort(cluster_vector, decreasing = TRUE)
  
  barplot(
    height = sorted_values,
    names.arg = names(sorted_values),
    las = 2,             # หมุนชื่อแกน X แนวตั้ง
    cex.names = 0.6,    # ปรับขนาดตัวอักษรชื่อแกน X ให้เล็กลง
    cex.axis = 0.7,      # ปรับขนาดตัวเลขบนแกน Y
    main = paste("Cluster", i, "Feature Importance"),
    col = "steelblue",
    space = 0.3,          # ลดระยะห่างระหว่างแถบ
    horiz = 1
  )
}


rf_result
xgb_result
logi_results

clus1 <- smt[kmeans_res$cluster == 1, ]
clus2 <- smt[kmeans_res$cluster == 2, ]
clus3 <- smt[kmeans_res$cluster == 3, ]


par(mfrow = c(1,3))
count_class_1 <- table(clus1$class)
barplot(table(clus1$class), names.arg = c("Exist", "Attrited")
        , col = c("green","red") )
count_class_2 <- table(clus2$class)
barplot(table(clus2$class), names.arg = c("Exist", "Attrited")
        , col = c("green","red") )
count_class_3 <- table(clus3$class)
barplot(table(clus3$class), names.arg = c("Exist", "Attrited")
        , col = c("green","red") )


# สร้าง barplot และเก็บตำแหน่ง X ของแต่ละแท่ง
# เพิ่มตัวเลขบนแท่งกราฟ