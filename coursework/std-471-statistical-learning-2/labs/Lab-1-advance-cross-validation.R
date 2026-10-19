library(ISLR)
library(tictoc)
Auto
head(Auto)


#Set Validation

dim(Auto)
train=sample(dim(Auto)[1],floor(0.8*dim(Auto)[1]))
lm.fit= lm(mpg ~ horsepower, data=Auto, subset=train)
Auto[train,]
lm.fit
summary(lm.fit)
predict(lm.fit ,Auto[-train,])
attach(Auto)
#MSE
mean((mpg[-train]-predict(lm.fit ,Auto[-train,]))^2)
cor(horsepower,mpg)
plot(horsepower,mpg)



x = 1:9
sv.err = rep(NA,9)
for (i in 1:9)
{
  lm.fit=lm(mpg ~ poly(horsepower ,i),data=Auto,subset=train)
  sv.err[i] = mean((mpg-predict(lm.fit,Auto))[-train]^2)
}
par(mfrow=c(1,1))
plot(x,sv.err,type = 'b',ylim=c(10,30))

which.min(sv.err)
min(sv.err)

whichmin = 1:5
whichmin[1] = which.min(sv.err)
for (j in 1:4)
{
  train=sample(dim(Auto)[1],floor(0.8*dim(Auto)[1]))
  for (i in 1:9)
  {
    lm.fit=lm(mpg ~ poly(horsepower ,i),data=Auto,subset=train)
    sv.err[i] = mean((mpg -predict(lm.fit,Auto))[-train]^2)
  }
  whichmin[j+1] = which.min(sv.err)
  lines(x, sv.err, col=j+1, pch=1, type='b')
}
whichmin

#___________________________________________________________________
#Monte Carlo

K=20
pp = 0.8

mmse = matrix(rep(0,9*K),K,9)
for (k in 1:K)
{
  set.seed(k)
  train=sample(dim(Auto)[1],floor(pp*dim(Auto)[1]))
  for (i in 1:9)
  {
    lm.fit=lm(mpg ~ poly(horsepower ,i),data=Auto,subset=train)
    mmse[k,i] = mean((mpg -predict(lm.fit,Auto))[-train]^2)
  }
}
mmse
mtmse = colMeans(mmse)
mtmse
plot(x,mtmse,type = 'b',ylim=c(10,30))
which.min(mtmse)

whichmin[1] = which.min(mtmse)
for (j in 1:4)
{
  K=20
  pp = 0.8
  
  mmse = matrix(rep(0,9*K),K,9)
  for (k in 1:K)
  {
    train=sample(dim(Auto)[1],floor(pp*dim(Auto)[1]))
    for (i in 1:9)
    {
      lm.fit=lm(mpg ~ poly(horsepower ,i),data=Auto,subset=train)
      mmse[k,i] = mean((mpg -predict(lm.fit,Auto))[-train]^2)
    }
  }
  mmse
  mtmse = colMeans(mmse)
  whichmin[j+1] = which.min(mtmse)
  lines(x, mtmse, col=j+1, pch=1, type='b')
}
whichmin



#_________________________________________________________________
#Manual K-fold

dim(Auto)[1]/10
K=10

folds=sample(1:K,dim(Auto)[1],replace=TRUE)
sum(folds == 5) 
sum(folds == 2) 
cv.rmse= matrix(rep(0,K*9),K,9)

for (k in 1:K){
  for (i in 1:9){
    lm.fit= lm(mpg ~ poly(horsepower,i), data=Auto[folds!=k,])
    cv.rmse[k,i] = sqrt(mean((Auto$mpg[folds==k]-predict(lm.fit ,Auto[folds==k,]))^2))
  }
}
cv.rmse
cv.k.rmse = colMeans(cv.rmse)
which.min(cv.k.rmse)

#________________________________________________________________

#Lab1

# For a given dataset
# Write your own kxl cross validation algorithm
# Write your own k-fold cross validation with validation and test sets algorithm

#___________________________________________________________________