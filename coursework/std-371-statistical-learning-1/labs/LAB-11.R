college=read.csv("College.csv",header=T,na.strings="?")
rownames(college) = college[,1]
college=data.frame(college[,-1])
college$Private = as.factor(college$Private)
head(college)
dim(college)

sum(is.na(college))
dat <- college

eee = seq(0.03,0.3,0.1)
mdd = 1:5
ppp = seq(0.3,0.6,0.01)

acc3 = matrix(7*length(eee)*length(mdd)*length(ppp),length(eee)*length(mdd)*length(ppp),7)

s=1
for (pp in ppp){
  for (ee in eee){
    for (md in mdd){
      tic()
      xgb_params <- list("eta" = ee, "max_depth" = md , "objective" = "multi:softprob",
                         "eval_metric" = "mlogloss",
                         "num_class" = numberOfClasses)
      nround    <- 40 # number of XGBoost rounds
      acc = 1:K
      tp = 1:K
      pc = 1:K
      f1 = 1:K
      for (j in 1:K){
        # split train data and make xgb.DMatrix
        train_data   <- data_variables[folds!=j,]
        train_label  <- data_label[folds!=j]
        train_matrix <- xgb.DMatrix(data = train_data, label = train_label)
        # split test data and make xgb.DMatrix
        test_data  <- data_variables[folds==j,]
        test_label <- data_label[folds==j]
        test_matrix <- xgb.DMatrix(data = test_data, label = test_label)
        bst_model <- xgb.train(params = xgb_params,
                               data = train_matrix,
                               nrounds = nround)
        # Predict hold-out test set
        test_pred <- predict(bst_model, newdata = test_matrix)
        test_prediction <- matrix(test_pred, nrow = numberOfClasses,
                                  ncol=length(test_pred)/numberOfClasses) %>%
          t() %>%
          data.frame() %>%
          mutate(label = test_label,
                 max_prob = max.col(., "last")-1)
        # confusion matrix of test set
        predprob = rep(0,dim(test_data)[1])
        predprob[test_prediction[,2]>pp] = 1
        table1 = table(test_prediction$label,predprob)
        acc[j]=(table1[1,1]+table1[2,2])/sum(table1)
        tp[j] = table1[2,2]/(table1[1,2]+table1[2,2]) #recall
        #precision
        pc[j] = table1[2,2]/(table1[2,1]+table1[2,2])
        #F1
        f1[j] = 2*tp[j]*pc[j] /(tp[j]+pc[j] )
      }
      acc3[s,1] = mean(pp)
      acc3[s,2] = mean(ee)
      acc3[s,3] = mean(md)
      acc3[s,4] = mean(acc)
      acc3[s,5] = mean(tp)
      acc3[s,6] = mean(pc)
      acc3[s,7] = mean(f1)
      s = s+1
      toc()
    }
  }
}

acc3 = as.data.frame(acc3)
names(acc3) = c('pp','ee','md','acc','tp','pc','f1')
dim(acc3)
acc3

acc3[which.max(acc3$acc),]
best.model = acc3[which.max(acc3$f1),]


confusionMatrix(factor(test_prediction$max_prob),
                factor(test_prediction$label),
                mode = "everything")

ee= as.numeric(best.model[2])
md = as.numeric(best.model[3])
pp = as.numeric(best.model[1])

xgb_params <- list("eta" = ee, "max_depth" = md , "objective" = "multi:softprob",
                   "eval_metric" = "mlogloss",
                   "num_class" = numberOfClasses)
nround    <- 40 # number of XGBoost rounds

tblist = list()
cv.errors = 1:k
cvng = 1:k
cvg = 1:k
for (j in 1:k){
  # split train data and make xgb.DMatrix
  train_data   <- data_variables[folds!=j,]
  train_label  <- data_label[folds!=j]
  train_matrix <- xgb.DMatrix(data = train_data, label = train_label)
  # split test data and make xgb.DMatrix
  test_data  <- data_variables[folds==j,]
  test_label <- data_label[folds==j]
  test_matrix <- xgb.DMatrix(data = test_data, label = test_label)
  
  
  
  bst_model <- xgb.train(params = xgb_params,
                         data = train_matrix,
                         nrounds = nround)
  
  # Predict hold-out test set
  test_pred <- predict(bst_model, newdata = test_matrix)
  test_prediction <- matrix(test_pred, nrow = numberOfClasses,
                            ncol=length(test_pred)/numberOfClasses) %>%
    t() %>%
    data.frame() %>%
    mutate(label = test_label,
           max_prob = max.col(., "last"))
  # confusion matrix of test set
  predprob = rep(2,dim(test_data)[1])
  predprob[test_prediction[,1]>pp] = 1
  tblist[[j]] = table(test_prediction$label,predprob)
}

tblist

cfsum = tblist[[1]]
for (j in 2:k){
  cfsum = cfsum + tblist[[j]]
}
cfsum


xgpre <- cfsum[2,2]/(cfsum[2,2] + cfsum[2,1])
xgrec <- cfsum[2,2]/(cfsum[2,2] + cfsum[1,2])
xgf1 <- (2*xgpre*xgrec)/(xgpre + xgrec)

# get the feature real names
names <-  colnames(dat[,-ncol(dat)])
# compute feature importance matrix
importance_matrix = xgb.importance(feature_names = names, model = bst_model)
head(importance_matrix)


gp = xgb.ggplot.importance(importance_matrix)
print(gp) 


#----random forest-----------------------
library(randomForest)
varImp(rf.college)
varImpPlot(rf.college ,type=2)
varImpPlot(rf.college ,type=1)

k=10
folds=sample(1:k,nrow(college2),replace=TRUE)

cv.acc.rf = 1:15
cv.tp.rf = 1:15
cv.pc.rf = 1:15
cv.f1.rf = 1:15
for (m in 2:16){
  acc = 1:k
  tp = 1:k
  pc = 1:k
  f1 = 1:k
  for(j in 1:k)
  {
    rf.college = randomForest(Grad.Rate~.,data=college2[folds!=j,], mtry=m,ntree=100,importance =TRUE)
    rf.pred=predict(rf.college,college2[folds==j,],type="class")
    table1 = table(rf.pred,college2$Grad.Rate[folds==j])
    acc[j]=(table1[1,1]+table1[2,2])/sum(table1)
    tp[j] = table1[2,2]/(table1[1,2]+table1[2,2]) #recall
    
    #precision
    pc[j] = table1[2,2]/(table1[2,1]+table1[2,2])
    
    #F1
    f1[j] = 2*tp*pc/(tp+pc)
    cvv[j] = mean(as.numeric(rf.pred) == as.numeric(college2$Grad.Rate[folds==j]))
  }
  cv.acc.rf[m-1] = sqrt(mean(acc))
  cv.tp.rf[m-1] = sqrt(mean(tp))
  cv.pc.rf[m-1] = sqrt(mean(pc))
  cv.f1.rf[m-1] = sqrt(mean(f1))
}
cv.acc.rf
which.max(cv.acc.rf)+1
max(cv.acc.rf)

cv.pc.rf
cv.tp.rf
cv.f1.rf

#--------------------------------------------------------


#random forest ดีกว่า