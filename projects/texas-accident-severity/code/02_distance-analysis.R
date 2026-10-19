library(vegan)
vegdist(dat |> mutate(Give_Way = as.numeric(Give_Way),
                      Junction = as.numeric(Junction))|> 
          select(Give_Way,Junction) , method = "jaccard")

library(stringdist)
table(stringdist(as.numeric(dat$Give_Way),as.numeric(dat$Junction) , 
                 method = "hamming"))


plot(dat |> mutate(Give_Way = as.numeric(Give_Way),
                   Junction = as.numeric(Junction))|> 
       select(Give_Way,Junction))

tx_pca <- prcomp(scale(dat |> select(Amenity, Bump, Crossing ,Give_Way,Junction, No_Exit,Severity)))
cumsum(tx_pca$sdev^2/sum(tx_pca$sdev^2))

plot(tx_pca$x)

mycolor <- colorRampPalette(c("red", "white", "blue"))(100)
heatmap(cor(dat |> 
              mutate(Sunrise_Sunset = as.numeric(as.factor(Sunrise_Sunset))) |> 
              select(Severity, 
                     where(is.numeric), 
                     where(is.logical),
                     Sunrise_Sunset,
                     -Turning_Loop,
                     -End_Lat,
                     -End_Lng) |> na.omit()),
        col = mycolor)


library(dplyr)
library(arrow)
library(ggplot2)

texas <- read_parquet("data/texas_accident.parquet")  # download link in README
texas$Start_Time <- as.POSIXct(texas$Start_Time, format = "%Y-%m-%d %H:%M:%S")

# แบ่ง 20% มารัน
dat <- texas[sample(1:dim(texas)[1], size = 0.1 * (dim(texas)[1])),]

table(texas$Severity)/sum(table(texas$Severity)) * 100
table(dat$Severity)/sum(table(dat$Severity)) * 100
### แบ่ง 20% ก็ยังรันต่อได้อยู่ เพราะ ratio ของ severity เท่าเดิม ###

colnames(dat)



library(dplyr)

texas_rf <- dat %>%
  mutate(Severity = as.factor(Severity)) %>%
  select(Severity, Start_Lat, Start_Lng, 21:46) %>%
  na.omit()  # ลบทุกแถวที่มี NA

# 1) เตรียมข้อมูล
texas_clean <- texas_rf %>%
  mutate(Severity = as.factor(Severity)) %>%
  mutate(across(where(is.logical), as.numeric)) %>%
  mutate(across(where(is.character), ~ as.numeric(factor(.)))) %>%
  mutate(across(where(is.factor) & !matches("Severity"), ~ as.numeric(.))) %>%
  select(-Turning_Loop,
         -Weather_Condition,
         -Wind_Direction) %>%
  select(where(~ n_distinct(.) > 1) | Severity) %>%
  na.omit()


#texas_clean$Weather_Condition <- as.factor(texas_clean$Wind_Direction)
texas_clean$Sunrise_Sunset <- texas_clean$Sunrise_Sunset - 1
texas_clean$Civil_Twilight <- texas_clean$Civil_Twilight - 1
texas_clean$Nautical_Twilight <- texas_clean$Nautical_Twilight - 1
texas_clean$Astronomical_Twilight <- texas_clean$Astronomical_Twilight - 1

texas_clean$Severity <-  ifelse(texas_clean$Severity %in% c(1,2), 0, 1)


set.seed(123)
train_index <- sample(1:dim(texas_clean)[1], size = 0.8*(dim(texas_clean)[1]))
train_texas <- texas_clean[train_index,]
test_texas <- texas_clean[-train_index,]


# ท่อน cluster
texas_pca <- prcomp(scale(train_texas |> mutate(Severity = as.numeric(Severity))))
cumsum(texas_pca$sdev^2/sum(texas_pca$sdev^2))
pc_select <- which(cumsum(texas_pca$sdev^2/sum(texas_pca$sdev^2)) > 0.8)[1]
plot(texas_pca$x[,1:pc_select])

library(e1071)
library(mclust)

set.seed(123)
max_k <- 10
wss <- numeric(max_k)  # store within-cluster sum of squares

for(k in 1:max_k){
  km <- kmeans(texas_pca$x[,1:pc_select], centers = k, nstart = 10)
  wss[k] <- km$tot.withinss
}

# กำหนดจำนวน cluster สูงสุด     # เลือกจำนวน column ที่ใช้ (เช่น PC1-PC5)
wss_fuzzy <- numeric(max_k)

for(k in 1:max_k){
  fzz <- cmeans(texas_pca$x[, 1:pc_select], centers = k, m = 2, iter.max = 50, verbose = FALSE)
  wss_fuzzy[k] <- fzz$withinerror   # ใช้ค่า within-cluster error ของ fuzzy c-means
}

library(UniversalCVI)
plot_idx(FzzyCVIs(texas_pca$x[, 1:pc_select], 
                  10, 
                  nstart = 20,
                  indexlist = c("WP", "WPC"),
                  sampling = 0.1))

plot_idx(FzzyCVIs(texas_pca$x[, 1:pc_select], 
                  10, 
                  nstart = 20,
                  indexlist = c("WP", "WPC"),
                  sampling = 0.1,
                  method = "EM"))

plot(1:max_k, wss, type="b", xlab="Number of Clusters K", ylab="Within groups sum of squares")



par(mfrow=c(1,3))
plot(1:max_k, wss, type="b", pch=19, main="K-Means WCSS")
plot(1:max_k, wss_fuzzy, type="b", pch=19, main="Fuzzy WCSS")
plot(1:max_k, bic_vals, type="b", pch=19, main="EM BIC")


set.seed(2417)
km <- kmeans(texas_pca$x[,1:pc_select], centers = 8, nstart = 10)
fzz <- cmeans(texas_pca$x[,1:pc_select], centers = 8)
em <- Mclust(texas_pca$x[,1:pc_select], G = 4)

plot(texas_pca$x[,1:pc_select], col = km$cluster)
plot(texas_pca$x[,1:pc_select], col = fzz$cluster)
plot(texas_pca$x[,1:pc_select], col = em$classification)

plot(texas_clean |> select(Start_Lng, Start_Lat), 
     col = train_texas$km_cluster,
     pch = 19,
     cex = 0.5)

train_texas$km_cluster <- as.factor(km$cluster)

severity_cluster <- train_texas |> 
  mutate(km_cluster = as.factor(km_cluster),
         Severity = as.factor(Severity)) |> 
  group_by(km_cluster, Severity) |> 
  summarise(count = n(), .groups = "drop")

# สร้าง stacked bar chart
ggplot(severity_cluster, aes(x = km_cluster, y = count, fill = Severity)) +
  geom_col() +
  coord_flip() +  # สลับแกน x-y ให้ cluster อยู่แนวตั้ง
  scale_fill_brewer(palette = "Set1") + # สีสวย
  labs(
    x = "Cluster",
    y = "Number of Incidents",
    fill = "Severity",
    title = "Distribution of Severity per Cluster"
  ) +
  theme_minimal(base_size = 14)


# cluster อยู่ข้างล่าง
train_texas$km_cluster <- as.factor(km$cluster)
#texas_clean$fzz_cluster <- fzz$cluster


texas_clean <- data.frame(Severity = texas_clean$Severity,
                          model.matrix(Severity~., 
                                       data = texas_clean)[,-1])
#รวม class 1+2, 3+4


#library(scutr)
#smote_1 <- oversample_smote(train_texas, "1", "Severity", 42924)
#smote_3 <- oversample_smote(train_texas, "3", "Severity", 42924)
#smote_4 <- oversample_smote(train_texas, "4", "Severity", 42924)
#zab <- rbind(train_texas |> filter(Severity == 2),smote_1, smote_3, smote_4)



#library(performanceEstimation)
#exas_smote <- smote(Severity~.,data = train_texas, perc.over = 2, perc.under = 1, k = 100)


library(smotefamily)

# สมมติว่าข้อมูลของคุณคือ train_texas และตัวแปร target คือ Severity
# ต้องแปลง target เป็น factor ก่อน
train_texas$Severity <- as.factor(train_texas$Severity)

# แยก features และ target
X <- train_texas[, setdiff(names(train_texas), "Severity")]
y <- train_texas$Severity

# ใช้ SMOTE จาก smotefamily
# K = จำนวน nearest neighbors, dup_size = จำนวนตัวอย่างเพิ่มขึ้น
set.seed(123)
smote_result <- SMOTE(X, y, K = 5, dup_size = 3.7)

zab <- smote_result$data
colnames(zab)[ncol(zab)] <- "Severity"
zab$Severity <- as.factor(as.numeric(zab$Severity))
zab <- zab[, c("Severity", setdiff(names(zab), "Severity"))]

#zab$km_cluster <- as.factor(zab$km_cluster)
#zab$fzz_cluster <- as.factor(zab$fzz_cluster)
#zab$Weather_Condition <- as.factor(zab$Wind_Direction)


# correlation #############
library(MASS)
library(dplyr)

# -------------------------------
# 1) เตรียมข้อมูลพื้นฐาน
# -------------------------------
severity_num <- as.numeric(zab$Severity)

# แยกประเภทตัวแปร
num_vars <- c("Temperature(F)", "Wind_Chill(F)", "Humidity(%)",
              "Pressure(in)", "Visibility(mi)", "Wind_Speed(mph)",
              "Precipitation(in)")

bin_vars <- c("Amenity", "Bump", "Crossing", "Give_Way", "Junction",
              "No_Exit", "Railway", "Station", "Stop",
              "Traffic_Calming", "Traffic_Signal",
              "Sunrise_Sunset", "Civil_Twilight",
              "Nautical_Twilight", "Astronomical_Twilight")

# -------------------------------
# 2) Spearman correlation (numeric)
# -------------------------------
cor_num <- sapply(num_vars, function(v) {
  cor(severity_num, zab[[v]], method = "spearman")
})

p_num <- sapply(num_vars, function(v) {
  cor.test(severity_num, zab[[v]], method = "spearman")$p.value
})

# -------------------------------
# 3) Spearman correlation (binary)
# -------------------------------
cor_bin <- sapply(bin_vars, function(v) {
  cor(severity_num, zab[[v]], method = "spearman")
})

p_bin <- sapply(bin_vars, function(v) {
  cor.test(severity_num, zab[[v]], method = "spearman")$p.value
})

# -------------------------------
# 4) ANOVA (numeric ~ severity)
# -------------------------------
anova_num <- sapply(num_vars, function(v) {
  summary(aov(zab[[v]] ~ zab$Severity))[[1]][["Pr(>F)"]][1]
})

# -------------------------------
# 5) Chi-square test (binary ~ severity)
# -------------------------------
chi_bin <- sapply(bin_vars, function(v) {
  chisq.test(table(zab[[v]], zab$Severity))$p.value
})

# -------------------------------
# 6) รวมผลทั้งหมดเป็นตารางเดียว
# -------------------------------
df_num <- data.frame(
  Variable = num_vars,
  Type = "Numeric",
  Spearman = cor_num,
  Spearman_p = p_num,
  ANOVA_p = anova_num,
  ChiSquare_p = NA
)

df_bin <- data.frame(
  Variable = bin_vars,
  Type = "Binary",
  Spearman = cor_bin,
  Spearman_p = p_bin,
  ANOVA_p = NA,
  ChiSquare_p = chi_bin
)

# รวมตารางทั้งหมด
df_all <- rbind(df_num, df_bin)

# เพิ่มคอลัมน์สำคัญ: absolute correlation
df_all$Abs_Spearman <- abs(df_all$Spearman)

# เรียงตามความสัมพันธ์มากที่สุด → น้อยที่สุด
df_all_sorted <- df_all %>% arrange(desc(Abs_Spearman))

df_all_sorted


#####################


# RF
# แยก X และ y
library(randomForest)
y <- zab$Severity
x <- zab[, -1]


# ฝึกโมเดล
rf_mod <- randomForest(x = x, y = y, 
                       ntree = 300, 
                       importance = TRUE)
print(rf_mod)
varImpPlot(rf_mod)



rf_pred_prob <- predict(rf_mod, test_texas |> select(-Severity),type = "prob")
rf_pred <- predict(rf_mod, test_texas |> select(-Severity))

table(rf_pred, test_texas$Severity)

cm <- table(rf_pred, test_texas$Severity)
cm

# คำนวณ Precision, Recall, F1
TP <- cm["1","1"]
FP <- cm["1","0"]
FN <- cm["0","1"]
TN <- cm["0","0"]

precision <- TP / (TP + FP)
recall <- TP / (TP + FN)
F1 <- 2 * precision * recall / (precision + recall)
accuracy <- (TP + TN) / sum(cm)


#------------------------
library(xgboost)

# แปลง target เป็น 0/1 integer
y_xgb <- as.numeric(as.character(zab$Severity))  # ตอนนี้ 0/1
x_xgb <- as.matrix(zab[, -1])
dtrain <- xgb.DMatrix(data = x_xgb, label = y_xgb)

# test set
y_test <- as.numeric(as.character(test_texas$Severity))  # 0/1
x_test <- as.matrix(test_texas[, -1])
dtest <- xgb.DMatrix(data = x_test, label = y_test)

# XGBoost parameters สำหรับ binary classification
params <- list(
  objective = "binary:logistic",  # เปลี่ยนเป็น binary
  eval_metric = "logloss",
  eta = 0.1,
  max_depth = 6
)

# Train
xgb_mod <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = 200,
  watchlist = list(train=dtrain),
  verbose = 1
)

# Predict
xgb_pred_prob <- predict(xgb_mod, dtest)
xgb_pred <- ifelse(xgb_pred_prob > 0.3, 1, 0)  # แปลงเป็น 0/1

# Confusion matrix & F1
table(xgb_pred, test_texas$Severity)
cm <- table(xgb_pred, test_texas$Severity)
cm

# Extract values
TP <- cm["1","1"]
FP <- cm["1","0"]
FN <- cm["0","1"]
TN <- cm["0","0"]

# Metrics
precision <- TP / (TP + FP)
recall <- TP / (TP + FN)
F1 <- 2 * precision * recall / (precision + recall)
accuracy <- (TP + TN) / sum(cm)

#-----------------




















#------------------------
texas_pca <- prcomp(scale(texas_clean |> mutate(Severity = as.numeric(Severity))))
cumsum(texas_pca$sdev^2/sum(texas_pca$sdev^2))
pc_select <- which(cumsum(texas_pca$sdev^2/sum(texas_pca$sdev^2)) > 0.8)[1]
plot(texas_pca$x[,1:pc_select])

library(e1071)
library(mclust)

set.seed(123)
max_k <- 10
wss <- numeric(max_k)  # store within-cluster sum of squares

for(k in 1:max_k){
  km <- kmeans(texas_pca$x[,1:pc_select], centers = k, nstart = 10)
  wss[k] <- km$tot.withinss
}

# กำหนดจำนวน cluster สูงสุด     # เลือกจำนวน column ที่ใช้ (เช่น PC1-PC5)
wss_fuzzy <- numeric(max_k)

for(k in 1:max_k){
  fzz <- cmeans(texas_pca$x[, 1:pc_select], centers = k, m = 2, iter.max = 50, verbose = FALSE)
  wss_fuzzy[k] <- fzz$withinerror   # ใช้ค่า within-cluster error ของ fuzzy c-means
}

library(UniversalCVI)
plot_idx(FzzyCVIs(texas_pca$x[, 1:pc_select], 
                  10, 
                  nstart = 20,
                  indexlist = c("WP", "WPC"),
                  sampling = 0.1))

plot_idx(FzzyCVIs(texas_pca$x[, 1:pc_select], 
                  10, 
                  nstart = 20,
                  indexlist = c("WP", "WPC"),
                  sampling = 0.1,
                  method = "EM"))

plot(1:max_k, wss, type="b", xlab="Number of Clusters K", ylab="Within groups sum of squares")



par(mfrow=c(1,3))
plot(1:max_k, wss, type="b", pch=19, main="K-Means WCSS")
plot(1:max_k, wss_fuzzy, type="b", pch=19, main="Fuzzy WCSS")
plot(1:max_k, bic_vals, type="b", pch=19, main="EM BIC")


set.seed(8)
km <- kmeans(texas_pca$x[,1:pc_select], centers = 7, nstart = 10)
fzz <- cmeans(texas_pca$x[,1:pc_select], centers = 8)
em <- Mclust(texas_pca$x[,1:pc_select], G = 4)

plot(texas_pca$x[,1:pc_select], col = km$cluster)
plot(texas_pca$x[,1:pc_select], col = fzz$cluster)
plot(texas_pca$x[,1:pc_select], col = em$classification)

plot(texas_clean |> select(Start_Lng, Start_Lat), 
     col = texas_clean$km_cluster,
     pch = 19,
     cex = 0.5)

texas_clean$km_cluster <- as.factor(km$cluster)

severity_cluster <- texas_clean |> 
  mutate(km_cluster = as.factor(km_cluster),
         Severity = as.factor(Severity)) |> 
  group_by(km_cluster, Severity) |> 
  summarise(count = n(), .groups = "drop")

# สร้าง stacked bar chart
ggplot(severity_cluster, aes(x = km_cluster, y = count, fill = Severity)) +
  geom_col() +
  coord_flip() +  # สลับแกน x-y ให้ cluster อยู่แนวตั้ง
  scale_fill_brewer(palette = "Set1") + # สีสวย
  labs(
    x = "Cluster",
    y = "Number of Incidents",
    fill = "Severity",
    title = "Distribution of Severity per Cluster"
  ) +
  theme_minimal(base_size = 14)

#-----------------------









#install.packages("iml")
library(iml)


# 1. สร้าง predictor object ของ iml
predictor <- Predictor$new(
  model = rf_mod, 
  data = x,           # features
  y = y,              # target
  type = "prob"       # เพราะ classification
)

# 2. สร้าง SHAP explainer สำหรับ observation แรก (หรือทั้งหมด)
shapley <- Shapley$new(predictor, x.interest = x[1, ])

# 3. แสดงค่า SHAP ของ observation
shapley$results

# 4. plot SHAP ของ observation
plot(shapley)
