bank <- read.csv('BankChurners.csv')

bank <- bank[2:length(bank)]

number <- dim(bank)[1] 
bank$Attrition_Flag <- factor(bank$Attrition_Flag, levels = c("Attrited Customer","Existing Customer"))

monte_acc <- seq(20)
each_threshold <- seq(0.1,0.9,by = 0.1)

tp_each_monte <- seq(20)
tn_each_monte <- seq(20)
fp_each_monte <- seq(20)
fn_each_monte <- seq(20)

pre_each_monte <- seq(20)
rec_each_monte <- seq(20)

f_1_each_monte <- seq(20)

for (i in 1:20){
  for_train <- sample(number, size = (0.8 * number),replace = FALSE)
  for (j in 1:length(each_threshold)){
    fin_model <- glm(Attrition_Flag ~ 
                       Gender + Dependent_count + 
                       Total_Relationship_Count + Months_Inactive_12_mon + Contacts_Count_12_mon +
                       Total_Revolving_Bal + Total_Trans_Amt + Total_Trans_Ct,
                     data = bank, subset = for_train, family = 'binomial' )
    fin_prob <- predict(fin_model, newdata = bank[-for_train,], type = 'response')
    
    fin_pred <- rep("Attrited Customer",length(fin_prob))
    fin_pred[fin_prob > (j/10)] = "Existing Customer"
    
    each_threshold[j] = mean(fin_pred == bank[-for_train, ]$Attrition_Flag)
  }
  fin_prob <- predict(fin_model, newdata = bank[-for_train,], type = 'response')
  fin_pred <- rep("Attrited Customer",length(fin_prob))
  fin_pred[fin_prob > (which.max(each_threshold)/10)] = "Existing Customer"
  
  monte_acc[i] =  mean(fin_pred == bank[-for_train, ]$Attrition_Flag)
  
  fin_table <- table(fin_pred, bank[-for_train, ]$Attrition_Flag)
  tp_each_monte[i] <- fin_table[2,2]
  tn_each_monte[i] <- fin_table[1,1]
  fp_each_monte[i] <- fin_table[2,1]
  fn_each_monte[i] <- fin_table[1,2]
  
  pre_each_monte[i] <- tp_each_monte[i]/(tp_each_monte[i]+fp_each_monte[i])
  rec_each_monte[i] <- tp_each_monte[i]/(tp_each_monte[i]+fn_each_monte[i])
  
  f_1_each_monte[i] <- 2*(pre_each_monte * rec_each_monte)/(pre_each_monte + rec_each_monte)
}


plot(sort(fin_prob))

plot(each_threshold)
k = which.max(each_threshold)/10

tp_each_monte
tn_each_monte
fp_each_monte
fn_each_monte

pre_each_monte
rec_each_monte

avg_acc <- mean(monte_acc)

avg_tp <- mean(tp_each_monte)
avg_tn <- mean(tn_each_monte)
avg_fp <- mean(fp_each_monte)
avg_fn <- mean(fn_each_monte)

avg_precision <- mean(pre_each_monte)
avg_recall <- mean(rec_each_monte)

avg_f_1_score <- mean(f_1_each_monte)

summary(fin_model)
