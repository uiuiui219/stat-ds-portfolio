# Generalized Linear Models
# 21/08/2024


library(ISLR2)
library(dplyr)
library(ggplot2)
library(LaplacesDemon)
library(VGAM)


# Logistic 
help(package = "ISLR2")
?Default
# >> predict default 
dim(Default)
head(Default)
str(Default)
sum(Default$default == "Yes")

# ---- Binary logistic regression ---- 

data = Default
K = 1:10
folds = sample(K,nrow(data),replace=TRUE)
label.name = "default"
Acc1= data.frame()
for(i in K){
  train= glm(default~., data = data[folds!=i,],
             family = "binomial")
  pred = ifelse(predict(train,newdata = data[folds==i,],type = "response")>0.5,
                "Yes","No")
  Acc1[i,"Acc"] = mean(Default[folds==i,label.name]==pred)
  tab = table(Default[folds==i,label.name],pred)
  Acc1[i,"TPR"] = tab[2,2]/(tab[2,1]+tab[2,2])
  Acc1[i,"F1"] = 2*tab[2,2]/(tab[1,2]+tab[2,1]+2*tab[2,2])
}
colMeans(Acc1)
summary(glm(default~., data = data,
    family = "binomial"))


# Tune cut off using Nested K-folds and F1 score

# Work on this




# Plot decision boundary
model = glm(default~ balance + income, data = data,
            family = "binomial")

x1 = seq(min(data$balance), max(data$balance), length.out=80)
x2 = seq(min(data$income), max(data$income), length.out=80)
background_grid = expand.grid(x1, x2)
names(background_grid) = c("balance","income")
grid_predictions = predict(model,
                           newdata = background_grid,
                           type = 'response')

plot(background_grid, pch = 20, cex = 0.5, col = ifelse(grid_predictions > 0.5, '#E75A7C', '#5398BE'))
points(data$balance, data$income, pch = 19, col = ifelse(data$default == "Yes", '#E75A7C', '#5398BE'))
slope = coef(model)[2]/(-coef(model)[3])
intercept = coef(model)[1]/(-coef(model)[3])
clip(min(x1),max(x1), min(x2), max(x2))
abline(intercept, slope, lwd = 2, lty = 2)


# ---- Poisson ----
# Data from kaggle 

creditcard = read.csv("CreditCard.csv")
head(creditcard)
dim(creditcard)

x = seq(0,50,1)
var = "active"
pmf <- dpois(x,mean(creditcard[,var]))
plot(
  x,
  pmf,
  type = "h",
  lwd = 3,
  main = "Poisson PMF",
  xlab = "Number of events",
  ylab = "Probability"
)



# checking collinearity
library(car)
# select only numeric and integer column
cre_num = creditcard[,c("reports","age","income","share",
                          "expenditure","dependents","months","active")]

model <- lm(active ~., data = cre_num)
vif_value = vif(model)
barplot(vif_value, col = "pink", main = "Variance Inflation Factor (VIF)")

max(creditcard$active)

barplot(table(creditcard[,var])/sum(table(creditcard[,var])),ylim = c(0,0.5))
lines(seq(1,47,1),(1/(seq(1,47,1)))/sum((1/(seq(1,47,1)))))


lines(dpois(0:max(creditcard$active),1),type = 'l')

plot(dgpois(0:20,1,0.5),type = 'l')


#predict active account using Poisson regression
# Try to adjust by erasing inactive persons first. Then apply Poisson on Y-1.


#---- Gamma -----

pqt = read.csv("pqt.csv")
head(pqt)
unique(pqt$doctor)
str(pqt)

library(fitdistrplus)
fit = fitdist(pqt $st, "gamma")
testks = ks.test(pqt$st, "pgamma", shape = fit$estimate["shape"], rate = fit$estimate["rate"])

x = seq(min(pqt$st), max(pqt$st), length.out = 100)

hist(pqt$st, breaks = 50, probability = TRUE, main = "Histogram with Gamma Fit",
     xlab = "st", col = "lightblue", border = "black")
curve(dgamma(x, shape = fit$estimate[1], rate = fit$estimate[2]), 
      col = "blue", lwd = 2, add = TRUE)


# 10-folds cv
data = pqt
K = 1:10
folds = sample(K,nrow(data),replace=TRUE)
Acc4= data.frame()
for(i in K){
  train= glm(st~., data = data[folds!=i,],
             family = "Gamma")
  pred = predict(train,newdata = data[folds==i,],type="response")
  Acc4[i,"RMSE"] = sqrt(mean((data$st[folds == i]-pred)^2))
}
mean(Acc4$RMSE)
summary(glm(st~., data = data,
    family = "Gamma"))
plot(data$st[folds==i],pred)

#---Poisson---

# 10-folds cv
data = pqt
plot(table(data$st))


Acc5= data.frame()
for(i in K){
  train= glm(st~., data = data[folds!=i,],
             family = "poisson")
  pred = predict(train,newdata = data[folds==i,],type="response")
  Acc5[i,"RMSE"] = sqrt(mean((data$st[folds == i]-pred)^2))
}
mean(Acc5$RMSE)
summary(glm(st~., data = data,
            family = "poisson"))

plot(data$st[folds==i],pred)



