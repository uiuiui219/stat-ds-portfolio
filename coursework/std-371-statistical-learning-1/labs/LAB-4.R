library(carData)
library(MASS)
data(WVS)
unique(WVS$poverty)
head(WVS)
?WVS
#WVS$poverty = factor(WVS$poverty,levels=c("Too Little","About Right","Too Much"),ordered =TRUE)
dim(WVS)
sum(WVS$poverty == "Too Much")
sum(WVS$poverty == "About Right")
summary(WVS)

?polr
full.model <- polr(poverty~religion+degree+country+age+gender, data = WVS, Hess = TRUE)
summary(full.model)
ctable = coef(summary(full.model))
p = pnorm(abs(ctable[, "t value"]), lower.tail = FALSE) * 2
ctable = cbind(ctable, "p value" = p)

pred = predict(full.model,WVS)
prob = predict(full.model,WVS,type = "probs")
pred2 = rep("Too Little",length(pred))
pred2[prob[,2]+0.1>prob[,1]]="About Right"
pred2[prob[,3]>0.215] = "Too Much" 
pred2 = factor(pred2,levels=c("Too Little","About Right","Too Much"),ordered =TRUE)
table(WVS$poverty, pred)
table(WVS$poverty, pred2)
mean(as.character(WVS$poverty)==as.character(pred))
mean(as.character(WVS$poverty)==as.character(pred2))


#k-folds
k=10
folds=sample(1:k,dim(WVS)[1],replace=TRUE)
sum(folds == 10)             
cv.acc= 1:k
c1.acc=1:k
c2.acc=1:k
c3.acc=1:k
c1.pre = 1:k
c2.pre = 1:k
c3.pre = 1:k

for(j in 1:k)
{
  full.model <- polr(poverty~religion+degree+country+age+gender, data = WVS,subset= (folds != j), Hess = TRUE)
  prob = predict(full.model,WVS[folds == j,],type = "probs")
  pred2 = rep("Too Little",sum(folds == j))
  pred2[prob[,2]+0.1>prob[,1]]="About Right"
  pred2[prob[,3]>0.25] = "Too Much" 
  pred2 = factor(pred2,levels=c("Too Little","About Right","Too Much"),ordered =TRUE)
  table3 = table(WVS$poverty[folds == j], pred2)
  cv.acc[j]= mean(pred2==WVS$poverty[folds == j])
  c1.acc[j] = table3[1,1]/(table3[1,1]+table3[1,2]+table3[1,3])
  c2.acc[j] = table3[2,2]/(table3[2,1]+table3[2,2]+table3[2,3])
  c3.acc[j] = table3[3,3]/(table3[3,1]+table3[3,2]+table3[3,3])
  c1.pre[j] = table3[1,1]/(table3[1,1]+table3[2,1]+table3[3,1])
  c2.pre[j] = table3[2,2]/(table3[1,2]+table3[2,2]+table3[3,2])
  c3.pre[j] = table3[3,3]/(table3[1,3]+table3[2,3]+table3[3,3])
 }
cv.acc
mean(cv.acc)
mean(c1.acc)
mean(c2.acc)
mean(c3.acc)

# Precision
mean(c1.pre)
mean(c2.pre)
mean(c3.pre)


k=10
folds=sample(1:k,dim(cmcData)[1],replace=TRUE)
sum(folds == 1)             
cv.acc= matrix(rep(0,2*k),k,2)
c1.acc= matrix(rep(0,2*k),k,2)
c2.acc= matrix(rep(0,2*k),k,2)
c3.acc= matrix(rep(0,2*k),k,2)
for(j in 1:k)
{
  multinom.cmc <- multinom(cmc~., data=cmcData, subset=(folds != j))
  predict.cmc.class <- predict(multinom.cmc, cmcData[folds == j,])
  table3 = table(predict.cmc.class,cmcData$cmc[folds == j])
  knn.pred=knn(cmcData[folds != j,-ncol(cmcData)],cmcData[folds == j,-ncol(cmcData)],cmcData$cmc[folds != j] ,k=10)
  table.knn = table(knn.pred,cmcData$cmc[folds == j])
  
  cv.acc[j,1]= mean(predict.cmc.class==cmcData$cmc[folds == j])
  c1.acc[j,1] = table3[1,1]/(table3[1,1]+table3[1,2]+table3[1,3])
  c2.acc[j,1] = table3[2,2]/(table3[2,1]+table3[2,2]+table3[2,3])
  c3.acc[j,1] = table3[3,3]/(table3[3,1]+table3[3,2]+table3[3,3])
  
  cv.acc[j,2] = mean(knn.pred==cmcData$cmc[folds == j])
  c1.acc[j,2] = table.knn[1,1]/(table.knn[1,1]+table.knn[1,2]+table.knn[1,3])
  c2.acc[j,2] = table.knn[2,2]/(table.knn[2,1]+table.knn[2,2]+table.knn[2,3])
  c3.acc[j,2] = table.knn[3,3]/(table.knn[3,1]+table.knn[3,2]+table.knn[3,3])
}
cv.acc
colMeans(cv.acc)
colMeans(c1.acc)
colMeans(c2.acc)
colMeans(c3.acc)