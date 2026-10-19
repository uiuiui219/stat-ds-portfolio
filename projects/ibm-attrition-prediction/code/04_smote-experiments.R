table(ibm_train$Attrition)

new <- smote(Attrition ~ ., ibm_train, perc.over = 1.91,perc.under= 5.3)

table(new$Attrition)
             
# ติดตั้งและโหลดแพ็กเกจที่จำเป็น
install.packages("smotefamily")  # ถ้ายังไม่มี
library(smotefamily)

# ใช้ Borderline-SMOTE สำหรับสร้าง synthetic data
borderline_data <- BLSMOTE(ibm_train[,-2],ibm_train$Attrition,K=5,C=5)

# ตรวจสอบจำนวนตัวอย่างที่ถูก oversampling
table(borderline_data$data$class)
pa <- borderline_data$data
pa$class <- factor(pa$class)


logis <- glm(class~., data = pa, family = "binomial")
logis_prob <- predict.glm(logis, type = "response")
logis_pred <- rep(0, length(logis_prob))
logis_pred[logis_prob > 0.5] <- 1

library(ROSE)
roc.curve(pa$class, logis_pred)


set.seed(123)  # เพื่อให้ผลลัพธ์ reproducible
num_simulations <- 1000  # กำหนดจำนวนรอบของ Monte Carlo
mc_results <- numeric(num_simulations)

set.seed(123)  # เพื่อให้ผลลัพธ์ reproducible
num_simulations <- 1000  # กำหนดจำนวนรอบของ Monte Carlo
mc_results <- numeric(num_simulations)

for (i in 1:num_simulations) {
  # สุ่มตัวอย่าง 80% ของข้อมูล
  sample_index <- sample(1:nrow(pa), size = round(0.8 * nrow(pa)), replace = TRUE)
  sample_data <- pa[sample_index, ]
  
  # สร้าง Logistic Regression บนชุดข้อมูลที่สุ่ม
  logis <- glm(class ~ ., data = sample_data, family = "binomial")
  logis_prob <- predict(logis, type = "response")
  logis_pred <- ifelse(logis_prob > 0.5, 1, 0)
  
  # บันทึกผลลัพธ์ (เช่น accuracy หรือ F1-score)
  mc_results[i] <- mean(logis_pred == sample_data$class)
  mc_results[i] <- mean(logis_pred == sample_data$class)
  mc_results[i] <- mean(logis_pred == sample_data$class)
  mc_results[i] <- mean(logis_pred == sample_data$class)
}

# แสดงผลการกระจายของ Monte Carlo
summary(mc_results)
hist(mc_results, main = "Monte Carlo Simulation Results", xlab = "Accuracy")
sd(mc_results)
