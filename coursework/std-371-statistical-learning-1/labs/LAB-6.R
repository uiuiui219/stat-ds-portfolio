College = read.csv("College.csv",header=T,na.strings="?")
rownames(College) <- College[,1]
College = College[,-1]
x=model.matrix(Grad.Rate~.,College)[,-1]
y=College$Grad.Rate

#Lab 5

# 1. Apply ridge regression to predict grad.rate. Find best lambda and best MSE error.
grid=10^seq(10,-2, length=100)
grid = c(grid,0)
rid_col_mod <- glmnet(x,y,alpha=0,lambda=grid)

for (i in 1:100){
  lasso.mod$lambda[i]
  }
which.min(lasso.mod$lambda)
#alpha*L1(beta)+(1-alpha)*L2(beta)

# 2. Apply lasso logistic regression to predict grad.rate(high/low). 
#     Find best lambda best on k-fold accuracy and state the best accuracy.
College2 = College
College2$Grad.Rate[College2$Grad.Rate>=70] = "High"
College2$Grad.Rate[College2$Grad.Rate<70] = "Low"
head(College2)
fix(College2)
College2$Grad.Rate = factor(College2$Grad.Rate,levels=c("Low","High"),ordered =TRUE)
x=model.matrix(Grad.Rate~.,College2)[,-1]
y=College2$Grad.Rate

bestlam = seq(18)
for (i in 3:20){
  las <- cv.glmnet(x,y,alpha=1,family = "binomial",nfolds=i)
  bestlam[i] <- las$lambda.min
}

plot(bestlam)
select_best_lanm <- which.min(bestlam)

predict(las,s=bestlam,type="coefficients")[1:18,]
predict(las,s=50,type="coefficients")[1:18,]
predict(las,s=bestlam,newx=x[1:10,])


#___________________________________________________________________