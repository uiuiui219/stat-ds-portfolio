library(dplyr)
library(arrow)
library(ggplot2)

texas <- read_parquet("data/texas_accident.parquet")  # download link in README
texas$Start_Time <- as.POSIXct(texas$Start_Time, format = "%Y-%m-%d %H:%M:%S")

# แบ่ง 20% มารัน
dat <- texas[sample(1:dim(texas)[1], size = 0.2 * (dim(texas)[1])),]

colnames(dat)

pie(table(dat |> select(Severity)))


plot(dat |> select(Start_Lat, Start_Lng), col = dat$Severity, pch = 16)


#pairs(texas |> select(where(is.numeric)))


library(randomForest)

# เตรียมข้อมูล
texas_rf <- texas %>%
  mutate(Severity = as.factor(Severity)) %>%
  select(Severity, 21:46) %>%
  na.omit()  # ลบทุกแถวที่มี NA

# แยก X และ y
y <- texas_rf$Severity
x <- texas_rf[, -1]

# ฝึกโมเดล
rf_mod <- randomForest(x = x, y = y, ntree = 200, importance = TRUE)
print(rf_mod)
varImpPlot(rf_mod)


#------------------------------
library(catboost)

df <- texas_rf

# แปลง chr เป็น factor เพื่อให้ CatBoost มองว่าเป็น categorical
df[] <- lapply(df, function(x) if(is.character(x)) as.factor(x) else x)

# cat_features = index ของคอลัมน์ที่เป็น factor/logical
cat_cols <- which(sapply(df, is.factor) | sapply(df, is.logical))

pool <- catboost.load_pool(
  data  = df[, -1],     # ไม่รวม Severity
  label = as.integer(df$Severity) - 1,  # catboost ต้องเริ่ม label ที่ 0
  cat_features = cat_cols - 1  # zero-based index
)

model <- catboost.train(
  pool,
  params = list(
    loss_function = "MultiClass",
    depth = 8,
    iterations = 300,
    learning_rate = 0.1,
    eval_metric = "TotalF1",
    verbose = 50
  )
)

catboost.get_model_params(model)
plot(model)


pred_prob <- catboost.predict(model, pool, prediction_type = "Probability")
pred_class <- max.col(pred_prob)
table(Predicted = pred_class, Actual = as.integer(df$Severity))
#------------------------------


logis_mod <- glm(Severity ~ ., data = texas_rf, family = "binomial")


#----------------
texas_rf |> select(where(is.logical)) |> as.factor() |> as.numeric()

                   