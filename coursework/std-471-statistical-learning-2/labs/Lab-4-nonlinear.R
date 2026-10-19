

library(splines)
library(dplyr)



# Lab: Non-linear Modeling

###
library(ISLR2)
attach(Wage)

head(Wage)

## Polynomial Regression and Step Functions

###
fit <- lm(wage ~ poly(age, 4), data = Wage)
coef(summary(fit))
###
fit2 <- lm(wage ~ poly(age, 4, raw = T), data = Wage)
coef(summary(fit2))
###
fit2a <- lm(wage ~ age + I(age^2) + I(age^3) + I(age^4),
            data = Wage)
coef(fit2a)
###
fit2b <- lm(wage ~ cbind(age, age^2, age^3, age^4),
            data = Wage)
###
agelims <- range(age)
age.grid <- seq(from = agelims[1], to = agelims[2])
preds <- predict(fit, newdata = list(age = age.grid),
                 se = TRUE)
se.bands <- cbind(preds$fit + 2 * preds$se.fit,
                  preds$fit - 2 * preds$se.fit)
###
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 1, 1),
    oma = c(0, 0, 4, 0))
plot(age, wage, xlim = agelims, cex = .5, col = "darkgrey")
title("Degree-4 Polynomial", outer = T)
lines(age.grid, preds$fit, lwd = 2, col = "blue")
matlines(age.grid, se.bands, lwd = 1, col = "blue", lty = 3)
###
preds2 <- predict(fit2, newdata = list(age = age.grid),
                  se = TRUE)
max(abs(preds$fit - preds2$fit))
###
fit.1 <- lm(wage ~ age, data = Wage)
fit.2 <- lm(wage ~ poly(age, 2), data = Wage)
fit.3 <- lm(wage ~ poly(age, 3), data = Wage)
fit.4 <- lm(wage ~ poly(age, 4), data = Wage)
fit.5 <- lm(wage ~ poly(age, 5), data = Wage)
anova(fit.1, fit.2, fit.3, fit.4, fit.5)
###
coef(summary(fit.5))
###
(-11.983)^2
###
fit.1 <- lm(wage ~ education + age, data = Wage)
fit.2 <- lm(wage ~ education + poly(age, 2), data = Wage)
fit.3 <- lm(wage ~ education + poly(age, 3), data = Wage)
anova(fit.1, fit.2, fit.3)
###
fit <- glm(I(wage > 250) ~ poly(age, 4), data = Wage,
           family = binomial)
###
preds <- predict(fit, newdata = list(age = age.grid), se = T)
###
pfit <- exp(preds$fit) / (1 + exp(preds$fit))
se.bands.logit <- cbind(preds$fit + 2 * preds$se.fit,
                        preds$fit - 2 * preds$se.fit)
se.bands <- exp(se.bands.logit) / (1 + exp(se.bands.logit))
###
preds <- predict(fit, newdata = list(age = age.grid),
                 type = "response", se = T)
###
plot(age, I(wage > 250), xlim = agelims, type = "n",
     ylim = c(0, .2))
points(jitter(age), I((wage > 250) / 5), cex = .5, pch = "|", col = "darkgrey")
lines(age.grid, pfit, lwd = 2, col = "blue")
matlines(age.grid, se.bands, lwd = 1, col = "blue", lty = 3)
###
table(cut(age, 4))
fit <- lm(wage ~ cut(age, 4), data = Wage)
coef(summary(fit))

## Splines\label{Ch7:sec8.2}

###
library(splines)
fit <- lm(wage ~ bs(age, knots = c(25, 40, 60)), data = Wage)
pred <- predict(fit, newdata = list(age = age.grid), se = T)
plot(age, wage, col = "gray")
lines(age.grid, pred$fit, lwd = 2)
lines(age.grid, pred$fit + 2 * pred$se, lty = "dashed")
lines(age.grid, pred$fit - 2 * pred$se, lty = "dashed")
###
dim(bs(age, knots = c(25, 40, 60)))
dim(bs(age, df = 6))
attr(bs(age, df = 6), "knots")
###
fit2 <- lm(wage ~ ns(age, df = 4), data = Wage)
pred2 <- predict(fit2, newdata = list(age = age.grid),
                 se = T)
lines(age.grid, pred2$fit, col = "red", lwd = 2)
###
plot(age, wage, xlim = agelims, cex = .5, col = "darkgrey")
title("Smoothing Spline")
fit <- smooth.spline(age, wage, df = 20)
fit2 <- smooth.spline(age, wage, cv = TRUE)
fit2$df
lines(fit, col = "red", lwd = 2)
lines(fit2, col = "blue", lwd = 2)
legend("topright", legend = c("16 DF", "6.8 DF"),
       col = c("red", "blue"), lty = 1, lwd = 2, cex = .8)
###
plot(age, wage, xlim = agelims, cex = .5, col = "darkgrey")
title("Local Regression")
fit <- loess(wage ~ age, span = .2, data = Wage)
fit2 <- loess(wage ~ age, span = .5, data = Wage)
lines(age.grid, predict(fit, data.frame(age = age.grid)),
      col = "red", lwd = 2)
lines(age.grid, predict(fit2, data.frame(age = age.grid)),
      col = "blue", lwd = 2)
legend("topright", legend = c("Span = 0.2", "Span = 0.5"),
       col = c("red", "blue"), lty = 1, lwd = 2, cex = .8)

## GAMs

###
gam1 <- lm(wage ~ ns(year, 4) + ns(age, 5) + education,
           data = Wage)
###
library(gam)
gam.m3 <- gam(wage ~ s(year, 4) + s(age, 5) + education,
              data = Wage)
###
par(mfrow = c(1, 3))
plot(gam.m3, se = TRUE, col = "blue")
###
plot.Gam(gam1, se = TRUE, col = "red")
###
gam.m1 <- gam(wage ~ s(age, 5) + education, data = Wage)
gam.m2 <- gam(wage ~ year + s(age, 5) + education,
              data = Wage)
anova(gam.m1, gam.m2, gam.m3, test = "F")
###
summary(gam.m3)
###
preds <- predict(gam.m2, newdata = Wage)
###
gam.lo <- gam(
  wage ~ s(year, df = 4) + lo(age, span = 0.7) + education,
  data = Wage
)
plot(gam.lo, se = TRUE, col = "green")
###
gam.lo.i <- gam(wage ~ lo(year, age, span = 0.5) + education,
                data = Wage)
###
library(akima)
plot(gam.lo.i)
###
gam.lr <- gam(
  I(wage > 250) ~ year + s(age, df = 5) + education,
  family = binomial, data = Wage
)
par(mfrow = c(1, 3))
plot(gam.lr, se = T, col = "green")
###
table(education, I(wage > 250))
###
gam.lr.s <- gam(
  I(wage > 250) ~ year + s(age, df = 5) + education,
  family = binomial, data = Wage,
  subset = (education != "1. < HS Grad")
)
plot(gam.lr.s, se = T, col = "green")
###

# Tune knot and df 
# Natural cubic spline

# Tune using auto knot 
# using 10 fold cross validation 

k = 10
t.knot = c(4:10)
s = 1
folds = sample(1:k,nrow(Wage),replace= TRUE)
result = data.frame()
for(i in 1:k){
  for(j in seq_along(t.knot)){
    fit  = lm(wage ~ ns(age, df = t.knot[j]), data = Wage, subset = (folds!=i))
    pred = predict(fit, newdata = Wage[folds == i,], se = T)
    result[s,"F"] = i
    result[s,"df"] = t.knot[j]
    result[s,"error"] = pred$residual.scale
    s = s+1 
  }
}

sum = data.frame()
for(w in seq(t.knot)){
  sum[w,"df"] = t.knot[w]
  sum[w,"mean.error"] = result %>% filter(df==t.knot[w]) %>% select(error) %>% colMeans()
}
sum[which.min(sum$mean.error),]

# check df = 8 (5 knots)
attr(bs(age, df = 8), "knots")

# 16.66667% 33.33333%       50% 66.66667% 83.33333% 
# 30        37        42        48        54



#College data

#Apply GAMs to college data 

college=read.csv("College.csv",header=T,na.strings="?")
rownames(college) = college[,1]
college=college[,-1]
head(college)
dim(college)

plot(college$Outstate,college$Grad.Rate)


attach(college)

#1 outstate

#2 private, outstate, top25, terminal

