#Data1: oil {fpp2}
library(fpp2)
oiltrain <- window(oil, start=1996,end=2010)
oiltest<- ts(c(525.95,549.83,542.34),start=2011)
autoplot(oiltrain)
#
library(TTR)
#Simple (Single) Moving averages
#SMA(x, n = 10, ...) {TTR}
fsma3<-SMA(oiltrain, n=3)[length(oiltrain)]
#
#Weighted moving average (WMA)
#WMA(x, n = 10, wts = 1:n, ...){TTR}
fwma<-WMA(oiltrain, n=3, wts = c(0.2,0.3,0.5))[length(oiltrain)]
#
#Simple Exponential Smoothing
#SES {fpp}
fses <- ses(oiltrain,h=3)
fses$model
fses$fitted
fses$residuals
#
#model check for ACF and Normality
#SMA model
n<-length(oiltrain)
k<-3
ma3fit<-vector()
ma3fit[(1+k):n]<-SMA(oiltrain, n=3)[k:(n-1)]
etsma3<-oiltrain[(k+1):n]-ma3fit[(k+1):n]
Box.test(etsma3, lag = 7, type = "Box-Pierce", fitdf = 1)
Box.test(etsma3,lag=7,type="Lj",fitdf=1)
shapiro.test(etsma3)

library(forecast)
gghistogram(etsma3) + ggtitle("Histogram of residuals")
ggAcf(etsma3)+ ggtitle("ACF of residuals")
#
#WMA model
n<-length(oiltrain)
k<-3
wma3fit<-vector()
wma3fit[(1+k):n]<-WMA(oiltrain, n=3, wts = c(0.2,0.3,0.5))[k:(n-1)]
etswma3<-oiltrain[(k+1):n]-wma3fit[(k+1):n]
Box.test(etswma3, lag = 7, type = "Box-Pierce", fitdf = 1)
Box.test(etswma3,lag=7,type="Lj",fitdf=1)
shapiro.test(etswma3)
gghistogram(etswma3) + ggtitle("Histogram of residuals")
ggAcf(etswma3)+ ggtitle("ACF of residuals")
#
#SES model
checkresiduals(fses)
shapiro.test(fses$residuals)
#
#plot
autoplot(oiltrain, ylab="Oil (millions of tonnes)",xlab="Year",main="Forecasts from 3 methods") +  
  autolayer(fses, series="SES",PI=F)+  
  autolayer(ts(rep(fsma3,3),start=c(2011)), series="SMA(3)")+  
  autolayer(ts(rep(fwma,3),start=c(2011)), series="WMA(3)")
#
# Accuracy of testing errors
round(accuracy(rep(fsma3,3),oiltest),2)
round(accuracy(rep(fwma,3),oiltest),2)
# Accuracy of one-step-ahead training errors and testing errors
round(accuracy(fses,oiltest),2)
#
## identify optimal alpha parameter
alpha <- seq(.01, .99, by = .01)
RMSE <- NA
for(i in seq_along(alpha)) {
  fit <- ses(oiltrain, alpha = alpha[i], h = 3)
  RMSE[i] <- accuracy(fit, oil)[1,2]
}
# convert to a data frame and idenitify min alpha value
library(tidyverse)
alpha.fit <- data_frame(alpha, RMSE)
alpha.min <- filter(alpha.fit, RMSE == min(RMSE))
# plot RMSE vs. alpha
ggplot(alpha.fit, aes(alpha, RMSE)) +
  geom_line() +
  geom_point(data = alpha.min, aes(alpha, RMSE), size = 2, color = "blue") 
#
#Trend methods
#Double moving average
#SMA{TTA}
#Holt’s linear trend method
#holt(x) {TTA}
#Additive damped trend methods
#holt(x, damped=TRUE) {TTA}
#Multiplicative damped trend methods
#holt(x, damped=TRUE, exponential=TRUE) {TTA}
#Data2 : ausair {fpp2}
ausairtrain <- window(ausair, start=1996, end= 2009)
ausairtest<-window(ausair, start=2010)
autoplot(ausairtrain)
#Double moving average, k=3
fsma1<-SMA(ausairtrain, n=3)
fsma2<-SMA(fsma1, n=3)
l<-(2*fsma1)-fsma2
b<-(2/(3-1))*(fsma1-fsma2)
fdmatrain<-l+b
fdmatest<-l[length(l)]+(b[length(l)]*c(1:7))
#
#model check
n<-length(ausairtrain)
k<-3
etdma<-ausairtrain[(k*2-1):n]-fdmatrain[(k*2-1):n]
Box.test(etdma, lag = 7, type = "Box-Pierce", fitdf = 4)
Box.test(etdma,lag=7,type="Lj",fitdf=4)
shapiro.test(etdma)
gghistogram(etdma) + ggtitle("Histogram of residuals")
ggAcf(etdma)+ ggtitle("ACF of residuals")
round(accuracy(fdmatest,ausairtest),2)
#
#Holt’s linear trend method
fh <- holt(ausairtrain, h=7)
#
#model check
checkresiduals(fh)
Box.test(fh$residuals, lag = 7, type = "Box-Pierce", fitdf = 4)
shapiro.test(fh$residuals)
#
round(accuracy(fh,ausairtest),2)
#
#Holt’s exponential trend method
fhexp <- holt(ausairtrain, h=7,exponential=T)
#model check
checkresiduals(fhexp)
Box.test(fhexp$residuals, lag = 7, type = "Box-Pierce", fitdf = 4)
shapiro.test(fhexp$residuals)
#
round(accuracy(fhexp,ausairtest),2)
#
#Additive Damped trend methods
fdamp <- holt(ausairtrain, h=7,damped =   TRUE)
#model check
checkresiduals(fdamp)
Box.test(fdamp$residuals, lag = 7, type = "Box-Pierce", fitdf = 5)
shapiro.test(fdamp$residuals)
#
round(accuracy(fdamp,ausairtest),2)
#
#Multiplicative Damped trend methods
fdampexp <- holt(ausairtrain, h=7,damped = TRUE,exponential=T)
#model check
checkresiduals(fdampexp)
Box.test(fdampexp$residuals, lag = 7, type = "Box-Pierce", fitdf = 5)
shapiro.test(fdampexp$residuals)
#
round(accuracy(fdampexp,ausairtest),2)
#
#Plot
autoplot(ausairtrain) +  
  autolayer(ausairtest, series="Total annual air passengers ") +  
  autolayer(ts(fdmatest,start=2010), series="Double moving average method") +  
  autolayer(fh, series="Holt's method", PI=FALSE) +  
  autolayer(fdamp, series="Additive Damped trend method", PI=FALSE) +  
  autolayer(fhexp, series="Exponential trend method", PI=FALSE)
#
#Trend-Seasonal methods
#Holt- winter’s Additive method
#hw(x,seasonal="additive") {forecast}
#Damped Holt-Winters' Additive method
#hw(x,seasonal="additive“, damped=TRUE) {forecast}
#Holt- winter’s Multiplicative method
#hw(x,seasonal="multiplicative") {forecast}
#Damped Holt-Winters' multiplicative method
#hw(y, damped=TRUE, seasonal="multiplicative")
#
#data3 :austourists {fpp2}
austouriststrain <- window(austourists, start=2003,end=c(2010,4))
austouriststest<-window(austourists, start=2011)
autoplot(austouriststrain)
#
#Holt- winter’s Additive method
fhwa <- hw(austouriststrain,seasonal="additive",h=20)
fhwa$model
#
checkresiduals(fhwa)
shapiro.test(fhwa$residuals)
#
round(accuracy(fhwa,austouriststest),2)
#
#Damped Holt-Winters' Additive method
fhwad <- hw(austouriststrain,seasonal="additive",damped =   TRUE,h=20)
fhwad$model
#
checkresiduals(fhwad)
shapiro.test(fhwad$residuals)
#
round(accuracy(fhwad,austouriststest),2)
#
#Holt- winter’s Multiplicative method
fhwm <- hw(austouriststrain,seasonal="multiplicative" ,h=20)
fhwm$model
#
checkresiduals(fhwm)
Box.test(fhwm$residuals, lag = 12, type = "Box-Pierce", fitdf = 8)
shapiro.test(fhwm$residuals)
#
round(accuracy(fhwm,austouriststest),2)
#
#Damped Holt- winter’s Multiplicative method
fhwmd <- hw(austouriststrain,seasonal="multiplicative",damped =TRUE)
fhwmd$model
#
checkresiduals(fhwmd)
Box.test(fhwmd$residuals, lag = 16, type = "Box-Pierce", fitdf = 9)
shapiro.test(fhwmd$residuals)
#
round(accuracy(fhwmd,austouriststest),2)
#
autoplot(austouriststrain) +
  autolayer(austouriststest, series="Quarterly visitor nights spent") +
  autolayer(fhwa, series="Holt- winter's Additive method", PI=FALSE) +
  autolayer(fhwad, series="Damped Holt- winter’s additive method", PI=FALSE) +
  autolayer(fhwm, series="Holt- winter's Multiplicative method", PI=FALSE) +
  ggtitle("Forecasts from Holt-Winters exponential smoothing") + xlab("Year") +
  ylab("Total visitor nights") +
  guides(colour=guide_legend(title="Forecast"))
#
#ETS
austtrain <- window(austourists, end=c(2010,4))
austtest <- window(austourists, start=c(2011,1))
fit <- ets(austtrain)
summary(fit)
autoplot(fit)
#training error: Additive or multiplicative
#residuals(fit)= residuals(fit,type=“innovation”)
#Forecasted error: 𝑒_𝑡=𝒚_𝒕−̂yhat_(𝑡|𝑡−1)
#residuals(fit,type='response'))
cbind('Residuals' = residuals(fit),'Forecast errors' = residuals(fit,type='response')) %>%  autoplot(facet=TRUE) + xlab("Year") + ylab("")
#
#Prediction
fit %>% forecast(h=20) %>%  autoplot() +  
  ylab("International visitor night in Australia (millions)")
###############################################################################3

#sheet
dat1 <- read.csv("datexpo3(1).csv")
dat1 <- dat1[,2]
tsdat1 <- ts(dat1)
austtrain <- window(tsdat1, start = 1,end = 9)
austtest <- window(tsdat1, start= 10, )
autoplot(tsdat1)

fit <- ets(austtrain)
summary(fit)
qchisq(1-0.05, df = 3)

checkresiduals(fit)
shapiro.test(fit$residuals)

forecast.ets(fit,h=3)
#training error: Additive or multiplicative
#residuals(fit)= residuals(fit,type=“innovation”)
#Forecasted error: 𝑒_𝑡=𝒚_𝒕−̂yhat_(𝑡|𝑡−1)
#residuals(fit,type='response'))
cbind('Residuals' = residuals(fit),'Forecast errors' = residuals(fit,type='response')) %>%  autoplot(facet=TRUE) + xlab("Year") + ylab("")
#
#Prediction
fit %>% forecast(h=3) %>%  autoplot() +  
  ylab("International visitor night in Australia (millions)")

fit %>% forecast(h=3) %>%  accuracy(austtest)


dat2 <- read.csv("datexpo6.csv")
dat2 <- dat2[,2]
tsdat2 <- ts(dat2)
austtrain <- window(tsdat2, start = 1,end = 9)
austtest <- window(tsdat2, start= 10, )
autoplot(tsdat2)

fit <- ets(austtrain)
summary(fit)
qchisq(1-0.05, df = 3)

checkresiduals(fit)
shapiro.test(fit$residuals)

forecast.ets(fit,h=3)
#training error: Additive or multiplicative
#residuals(fit)= residuals(fit,type=“innovation”)
#Forecasted error: 𝑒_𝑡=𝒚_𝒕−̂yhat_(𝑡|𝑡−1)
#residuals(fit,type='response'))
cbind('Residuals' = residuals(fit),'Forecast errors' = residuals(fit,type='response')) %>%  autoplot(facet=TRUE) + xlab("Year") + ylab("")
#
#Prediction
fit %>% forecast(h=3) %>%  autoplot() +  
  ylab("International visitor night in Australia (millions)")

fit %>% forecast(h=3) %>%  accuracy(austtest)



dat3 <- read.csv("datexpo7.csv")
dat3 <- dat3[,3]
tsdat3 <- ts(dat3)
austtrain <- window(tsdat3, start = 9,end = 20)
austtest <- window(tsdat3, start= 21 )
autoplot(tsdat3)

fit <- ets(austtrain)
summary(fit)
qchisq(1-0.05, df = 3)

checkresiduals(fit)
shapiro.test(fit$residuals)

forecast.ets(fit,h=4)
#training error: Additive or multiplicative
#residuals(fit)= residuals(fit,type=“innovation”)
#Forecasted error: 𝑒_𝑡=𝒚_𝒕−̂yhat_(𝑡|𝑡−1)
#residuals(fit,type='response'))
cbind('Residuals' = residuals(fit),'Forecast errors' = residuals(fit,type='response')) %>%  autoplot(facet=TRUE) + xlab("Year") + ylab("")
#
#Prediction
fit %>% forecast(h=4) %>%  autoplot() +  
  ylab("International visitor night in Australia (millions)")

fit %>% forecast(h=4) %>%  accuracy(austtest)

#--------------------------------------------------------
sbux <- read.csv("sbux stock.csv")
ts_sbux <- ts(sbux[,6])


sbux_train <- window(ts_sbux, start = 1, end = 666)
sbux_test <- window(ts_sbux, start = 667)
autoplot(sbux_train)

#ARIMA (check acf/pacf and bartlett --> need to firt difference and Box-Cox)
Acf(sbux_train)
Pacf(sbux_train)
kpss.test(sbux_train)
adf.test(sbux_train)

sbux_bart <- data.frame(cbind(boxcox_train, data.frame(c(rep(1,222),rep(2,222),rep(3,222)))))
colnames(sbux_bart) <- c("y", "group")
bartlett.test(sbux_bart$y~sbux_bart$group)


box_arima <- auto.arima(boxcox_train)
summary(box_arima)
checkresiduals(box_arima)
forebox <- (forecast(box_arima, h = length(sbux_test)))
forebox <- InvBoxCox(forebox$mean, bestlamda)
box_acc <- accuracy(forebox, sbux_test)
box_acc

bestlamda <- BoxCox.lambda(sbux_train)
boxcox_train <- BoxCox(sbux_train, lambda = bestlamda)

box_arima <- auto.arima(boxcox_train)
summary(box_arima)
checkresiduals(box_arima)

Acf(diff(boxcox_train, differences = 1))
Pacf(diff(boxcox_train, differences = 1))

forebox <- (forecast(box_arima, h = length(sbux_test)))
forebox <- InvBoxCox(forebox$mean, bestlamda)
box_acc <- accuracy(forebox, sbux_test)
box_acc



#ETS
sbux_fit <- ets(sbux_train)
summary(sbux_fit)
checkresiduals(sbux_fit)
shapiro.test(sbux_fit$residuals)

bestlamda <- BoxCox.lambda(sbux_train)
boxcox_train <- BoxCox(sbux_train, lambda = bestlamda)

box_fit <- ets(boxcox_train)
summary(box_fit)
checkresiduals(box_fit)

Acf(boxcox_train)
Pacf(boxcox_train)
Acf(diff(boxcox_train, differences = 1))
Pacf(diff(boxcox_train, differences = 1))

forefit <- forecast(box_fit, h = length(sbux_test))
forefit <- InvBoxCox(forefit$mean, bestlamda)
ets_acc <- accuracy(forefit, sbux_test)
ets_acc


#ETS,ARIMA Box-Cox
bestlamda <- BoxCox.lambda(sbux_train)
boxcox_train <- BoxCox(sbux_train, lambda = bestlamda)

box_fit <- ets(boxcox_train)
summary(box_fit)
checkresiduals(box_fit)
forefit <- forecast(box_fit, h = length(sbux_test))
forefit <- InvBoxCox(forefit$mean, bestlamda)
ets_acc <- accuracy(forefit, sbux_test)
ets_acc

box_arima <- auto.arima(boxcox_train)
summary(box_arima)
checkresiduals(box_arima)
forebox <- (forecast(box_arima, h = length(sbux_test)))
forebox <- InvBoxCox(forebox$mean, bestlamda)
box_acc <- accuracy(forebox, sbux_test)
box_acc


#------------------------------
Acf(sbux_train)
Pacf(sbux_train)
Acf(diff(sbux_train, differences = 1))
Pacf(diff(sbux_train, differences = 1))
kpss.test(sbux_train)
adf.test(sbux_train)
adf.test(diff(sbux_train, differences = 1))



checkresiduals(sbux_train)
Box.test(sbux_train, lag = 10, type = "Box-Pierce", fitdf = 10)
shapiro.test(sbux_train)

sbux_bart <- data.frame(cbind(boxcox_train, data.frame(c(rep(1,222),rep(2,222),rep(3,222)))))
colnames(sbux_bart) <- c("y", "group")
bartlett.test(sbux_bart$y~sbux_bart$group)

bestlamda <- BoxCox.lambda(sbux_train)
boxcox_train <- BoxCox(sbux_train, lambda = bestlamda)



sbux_fit <- ets(boxcox_train)
checkresiduals(sbux_fit)
shapiro.test(sbux_fit$residuals)
forecast.ets(sbux_fit,h=4)
summary(sbux_fit)
accuracy(forecast.ets(sbux_fit, h = 85), sbux_fit)
sbux_fit %>% forecast.ets(h=85) %>%  accuracy(sbux_test)
sbux_fit %>% forecast.ets(h=85) %>%  autoplot()


sbux_arima <- auto.arima(boxcox_train)
summary(sbux_arima)
sbux_arima$residuals
sbux_arima %>% forecast(h=85) %>%  accuracy(sbux_test)
sbux_arima %>% forecast(h=85) %>%  autoplot()

Acf(sbux_train)


checkresiduals(auto.arima(boxcox_train))
Acf(sbux_train)
Pacf(sbux_train)
Acf(diff(sbux_train, differences = 1))
Pacf(diff(sbux_train, differences = 1))

Acf(boxcox_train)
Pacf(boxcox_train)
Acf(diff(boxcox_train, differences = 1))
Pacf(diff(boxcox_train, differences = 1))


kpss.test(boxcox_train)
adf.test(boxcox_train)
adf.test(diff(boxcox_train, differences = 1))

shapiro.test(diff(boxcox_train, differences = 1))

checkresiduals(sbux_fit)
checkresiduals(sbux_arima)
shapiro.test(sbux_fit$residuals)
shapiro.test(sbux_arima$residuals)
bartlett.test()

Box.test(sbux_fit$residuals)
