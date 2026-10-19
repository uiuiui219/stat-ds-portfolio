#pruning check accuracy + f1 using k-fold
#random forest with different cutoff. 
#Check accuracy + f1

bank <- read.csv("BankChurners.csv")
bank <- bank[,-1]
bank <- data.frame(model.matrix(~.,bank))
bank <- bank[,-1]

k=10
folds=sample(1:k,nrow(bank),replace=TRUE)

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
    rf.college = randomForest(Attrition_Flag~.,data=bank[folds!=j,], mtry=m,ntree=100,importance =TRUE)
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

