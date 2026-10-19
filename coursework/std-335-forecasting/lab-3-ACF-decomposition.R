library(fpp2)
#
DAX<-EuStockMarkets[,1]
autoplot(DAX)
ggAcf(DAX,lag=48)
ggAcf(DAX,plot=FALSE)
#
AirPassengers2 <- window(AirPassengers, start=1949)
autoplot(AirPassengers2)
ggAcf(AirPassengers2,lag=48)
ggAcf(AirPassengers2,plot=FALSE)
#
Box.test(DAX, lag=10, type="Ljung-Box")
#
a<-c()
for (i in 1:12) a<-c(a,rep(i,12))
dat<-data.frame(y=c(AirPassengers2),year=a)
bartlett.test(dat$y ~dat$year)
#
autoplot(AirPassengers2)+ ylab("thousand") + xlab("Year") +  ggtitle("Monthly totals of international airline passengers")
autoplot(sqrt(AirPassengers2))+ ylab("thousand") +xlab("Year") +  ggtitle("Square root totals of international airline passengers")
autoplot(AirPassengers2^(1/3))+ ylab("thousand") + xlab("Year") +  ggtitle("Cube root totals of international airline passengers")
autoplot(log(AirPassengers2))+ ylab("thousand") + xlab("Year") +  ggtitle("Logarithm totals of international airline passengers")
lambda <- BoxCox.lambda(AirPassengers2,lower=0)
autoplot(BoxCox(AirPassengers2,lambda))

fit <- snaive(AirPassengers2, lambda=lambda) 
autoplot(fit)
autoplot(fit, include=60)

fit1 <- snaive(BoxCox(AirPassengers2,lambda))
autoplot(fit1)

autoplot(AirPassengers2)+ ylab("thousand") + xlab("Year") + ggtitle("Monthly totals of international airline passengers")
AirPassengers2 %>% log() %>% autoplot()
AirPassengers2 %>% log() %>% diff(lag=12) %>% autoplot()
AirPassengers2 %>% log() %>% diff(lag=12) %>% diff(lag=1) %>% autoplot()

library("urca")
DAX %>% ur.kpss() %>%   summary()
summary(ur.kpss(DAX))
AirPassengers2 %>% ur.kpss() %>%   summary()

ndiffs(DAX) 
DAX %>% diff(differences = 2) %>% ur.kpss() %>% summary()

library("tseries")
adf.test(diff(DAX,differences = 2))
DAX %>% diff(differences = 2) %>% autoplot()

nsdiffs(AirPassengers2) 
AirPassengers2  %>% diff(lag=12) %>% ur.kpss() %>% summary()
AirPassengers2  %>% diff(lag=12) %>% ndiffs()
AirPassengers2  %>% diff(lag=12) %>% diff(lag=1) %>% ur.kpss() %>% summary()
adf.test(diff(diff(AirPassengers2,lag=12),lag=1))
AirPassengers2 %>% diff(lag=12) %>% diff(lag=1) %>% autoplot()



dat4 <-read.csv("datexpo5.csv")

tsdat4 <- ts(dat4[,2])
ets(tsdat4)

autoplot(tsdat4)
ggAcf(tsdat4,lag = 12)
ggAcf(tsdat4,plot=FALSE)
ggPacf(tsdat4,lag = 12)
ggPacf(tsdat4,plot=FALSE)

Box.test(tsdat4, lag=7, type="Ljung-Box")

bart4 <- cbind(dat4[,2],data.frame(c(rep(1,4), rep(2,4), rep(3,4))))
colnames(bart4) <- c("y", "group")

bartlett.test(bart4$y ~bart4$group)

summary(ur.kpss(tsdat4))

adf.test(tsdat4)

ndiffs(tsdat4)
summary(ur.kpss(diff(tsdat4, differences = 1)))
adf.test(diff(tsdat4, differences = 1))

ggAcf(diff(tsdat4, differences = 1),lag = 12)
ggAcf(diff(tsdat4, differences = 1),plot = FALSE)

ggPacf(diff(tsdat4, differences = 1),lag = 12)
ggPacf(diff(tsdat4, differences = 1),plot = FALSE)


auto.arima(tsdat4)
austtrain <- window(tsdat4, start = 1,end = 9)
austtest <- window(tsdat4, start= 10, )

ggAcf(austtrain,plot = FALSE)
ggPacf(diff(austtrain, differences = 1),plot = FALSE)

forecast(arima(austtrain, c(1,0,0)),h=3)
accuracy(arima(austtrain, c(2,1,0)),h=3)

mean(austtrain)


#TEST

dat4

data <- dat4[,-1]

ts.data <- ts(data,start = 2013)

ts.data

data.train <- window(ts.data , start = 2013 , end = 2021)

arima(data.train ,  c = (1,0,0))
