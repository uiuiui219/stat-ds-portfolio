bank <- read.csv("BankChurners.csv")

bank <- bank[,c(2:8, 10:14, 21)]
bank$Attrition_Flag <- factor(bank$Attrition_Flag, levels = c("Attrited Customer", "Existing Customer"))

table(bank$Attrition_Flag)

str(bank)
Attrition_Flag <- bank$Attrition_Flag
bank <- model.matrix(Attrition_Flag~., data = bank)[,-1]
bank <- data.frame(Attrition_Flag, bank)

library(performanceEstimation)
#bank <- smote(Attrition_Flag~., data = bank, perc.over = 4.7, perc.under = 1.3)
bank <- smote(Attrition_Flag~., data = bank, perc.over = 3.45, perc.under = 1.75)

table(bank$Attrition_Flag)


logis_acc = seq(20)
logis_tp = seq(20)
logis_tn = seq(20)
logis_fp = seq(20)
logis_fn = seq(20)
logis_pre = seq(20)
logis_rec = seq(20)
logis_f1 = seq(20)

for (i in 1:20){
  train <- sample(dim(bank)[1], size = (0.8*dim(bank)[1]), replace = FALSE)
  logis <- glm(Attrition_Flag~.,data = bank, subset = train, family = 'binomial')
  prob <- predict.glm(logis, newdata = bank[-train,], type = "response")
  pred <- rep("Attrited Customer", length(prob))
  pred[prob > median(prob)] = "Existing Customer"
  logis_acc[i] <- mean(bank[-train, ]$Attrition_Flag == pred)
  logis_table <- table(pred, bank[-train, ]$Attrition_Flag)
  logis_tp[i] <- logis_table[1,1]
  logis_tn[i] <- logis_table[2,2]
  logis_fp[i] <- logis_table[1,2]
  logis_fn[i] <- logis_table[2,1]
  logis_pre[i] <- logis_tp[i]/(logis_tp[i] + logis_fp[i])
  logis_rec[i] <- logis_tp[i]/(logis_tp[i] + logis_fn[i])
  logis_f1[i] <- 2*logis_pre[i]*logis_rec[i]/(logis_pre[i] + logis_rec[i])
}

avg_acc <- mean(logis_acc)
avg_tp <- mean(logis_tp)
avg_tn <- mean(logis_tn)
avg_fp <- mean(logis_fp)
avg_fn <- mean(logis_fn)

avg_table <- matrix(c(avg_tp, avg_fp, avg_fn, avg_tn), byrow = TRUE, ncol = 2)
colnames(avg_table) <- c("Attrited Customer", "Existing Customer")
rownames(avg_table) <- c("Pred Attrited Customer", "Pred Existing Customer")

avg_pre <- mean(logis_pre)
avg_rec <- mean(logis_rec)
avg_f1 <- mean(logis_f1)

avg_table

avg_acc
avg_pre
avg_rec
avg_f1

library(ROSE)
roc.curve(bank[-train,]$Attrition_Flag, pred)

#---------------------------------
library(leaps)
library(tictoc)
library(boot)


forward=regsubsets(Attrition_Flag~.,data=bank,nvmax = dim(bank)[2], method = "forward")
backward=regsubsets(Attrition_Flag~.,data=bank,nvmax = dim(bank)[2], method = "backward")
hybrid=regsubsets(Attrition_Flag~.,data=bank,nvmax = dim(bank)[2], method = "seqrep")



forward_summary <- summary(forward)
backward_summary <- summary(backward)
hybrid_summary <- summary(hybrid)

varia_select <- matrix(c("Forward", "Backward", "Hybrid", 
                         which.min(forward_summary$rss),which.min(backward_summary$rss),which.min(hybrid_summary$rss)),
                       ncol = 2, byrow = FALSE)
colnames(varia_select) <- c("Method", "number of variable")
varia_select

hyb_acc <- 1:20
hyb_pre <- 1:20
hyb_rec <- 1:20
hyb_f1 <- 1:20

hyb_tp = seq(20)
hyb_tn = seq(20)
hyb_fp = seq(20)
hyb_fn = seq(20)
hyb_pre = seq(20)
hyb_rec = seq(20)
hyb_f1 = seq(20)


for (i in 1:20){
  train <- sample(dim(bank)[1], size = (0.8*dim(bank)[1]), replace = FALSE)
  hyb_variable <- hybrid_summary$which[which.min(hybrid_summary$rss), ]

  hyb_mod <- glm(Attrition_Flag~., data = bank[ ,hyb_variable], subset = train, family = "binomial" )
  hyb_prob <- predict(hyb_mod, newdata= bank[-train,], type = "response")
  hyb_pred <- rep("Attrited Customer", length(hyb_prob))
  hyb_pred[hyb_prob > median(hyb_prob)] = "Existing Customer"
  hyb_acc[i] <- mean(bank[-train, ]$Attrition_Flag == hyb_pred)
  hyb_table <- table(hyb_pred, bank[-train, ]$Attrition_Flag)
  hyb_tp[i] <- hyb_table[1,1]
  hyb_tn[i] <- hyb_table[2,2]
  hyb_fp[i] <- hyb_table[1,2]
  hyb_fn[i] <- hyb_table[2,1]
  hyb_pre[i] <- hyb_tp[i]/(hyb_tp[i] + hyb_fp[i])
  hyb_rec[i] <- hyb_tp[i]/(hyb_tp[i] + hyb_fn[i])
  hyb_f1[i] <- 2*hyb_pre[i]*hyb_rec[i]/(hyb_pre[i] + hyb_rec[i])
}

avg_hyb_tp <- mean(hyb_tp)
avg_hyb_tn <- mean(hyb_tn)
avg_hyb_fp <- mean(hyb_fp)
avg_hyb_fn <- mean(hyb_fn)

avg_hyb_table <- matrix(c(avg_hyb_tp, avg_hyb_fp, avg_hyb_fn, avg_hyb_tn), byrow = TRUE, ncol = 2)
colnames(avg_hyb_table) <- c("Attrited Customer", "Existing Customer")
rownames(avg_hyb_table) <- c("Pred Attrited Customer", "Pred Existing Customer")


avg_hyb_acc <- mean(hyb_acc)
avg_hyb_pre <- mean(hyb_pre)
avg_hyb_rec <- mean(hyb_rec)
avg_hyb_f1 <- mean(hyb_f1)


avg_hyb_table
avg_hyb_acc
avg_hyb_pre
avg_hyb_rec
avg_hyb_f1

roc.curve(bank[-train,]$Attrition_Flag, hyb_pred)

#----------------------------------------------------

pca_ncomp_one = selectNcomp(pca_mod,plot=T,method = "onesigma")
#_____________________________________________________________

bank <- read.csv("BankChurners.csv")

bank <- bank[,c(2:8, 10:14, 21)]
bank$Attrition_Flag <- factor(bank$Attrition_Flag, levels = c("Attrited Customer", "Existing Customer"))

table(bank$Attrition_Flag)

str(bank)
Attrition_Flag <- bank$Attrition_Flag
bank <- model.matrix(Attrition_Flag~., data = bank)[,-1]
bank <- data.frame(Attrition_Flag, bank)

library(performanceEstimation)
#bank <- smote(Attrition_Flag~., data = bank, perc.over = 4.7, perc.under = 1.3)
bank <- smote(Attrition_Flag~., data = bank, perc.over = 3.45, perc.under = 1.75)


library(glmnet)
grid=10^seq(10,-2, length=100)

y <- as.numeric(bank$Attrition_Flag)-1
x <- bank[,-1]
x <- scale(x)

cv_lass <- cv.glmnet(x,y,nfolds = 5, alpha=1, lambda = grid)
plot(cv_lass)

bestlamda <- cv_lass$lambda.min
bestlamda

lass_acc = seq(20)
lass_tp = seq(20)
lass_tn = seq(20)
lass_fp = seq(20)
lass_fn = seq(20)
lass_pre = seq(20)
lass_rec = seq(20)
lass_f1 = seq(20)

for (i in 1:20){
  train <- sample(dim(bank)[1], size = (0.8*dim(bank)[1]), replace = FALSE)
  y_train <- as.numeric(bank[train,]$Attrition_Flag)-1
  x_train <- bank[train,-1]
  x_train <- scale(x_train)
  y_test <- as.numeric(bank[-train,]$Attrition_Flag)-1
  x_test <- bank[-train,-1]
  x_test <- scale(x_test)
  
  
  lasso.mod=glmnet(x_train,y_train,alpha=1,lambda=grid, family = "binomial")  
  lass_class <- predict(lasso.mod,s=bestlamda,newx=x_test,type="class")
  lass_pred <- rep("Attrited Customer", length(lass_class))
  lass_pred[lass_class == 1] = "Existing Customer"
  lass_acc[i] <- mean(bank[-train, ]$Attrition_Flag == lass_pred)
  lass_table <- table(lass_pred, bank[-train, ]$Attrition_Flag)
  lass_tp[i] <- lass_table[1,1]
  lass_tn[i] <- lass_table[2,2]
  lass_fp[i] <- lass_table[1,2]
  lass_fn[i] <- lass_table[2,1]
  lass_pre[i] <- lass_tp[i]/(lass_tp[i] + lass_fp[i])
  lass_rec[i] <- lass_tp[i]/(lass_tp[i] + lass_fn[i])
  lass_f1[i] <- 2*lass_pre[i]*lass_rec[i]/(lass_pre[i] + lass_rec[i])
}

avg_lass_acc <- mean(lass_acc)
avg_lass_tp <- mean(lass_tp)
avg_lass_tn <- mean(lass_tn)
avg_lass_fp <- mean(lass_fp)
avg_lass_fn <- mean(lass_fn)

avg_lass_table <- matrix(c(avg_lass_tp, avg_lass_fp, avg_lass_fn, avg_lass_tn), byrow = TRUE, ncol = 2)
colnames(avg_lass_table) <- c("Attrited Customer", "Existing Customer")
rownames(avg_lass_table) <- c("Pred Attrited Customer", "Pred Existing Customer")

avg_lass_pre <- mean(lass_pre)
avg_lass_rec <- mean(lass_rec)
avg_lass_f1 <- mean(lass_f1)

library(ROSE)
lass_auc <- roc.curve(bank$Attrition_Flag[-train], lass_pred)$auc



