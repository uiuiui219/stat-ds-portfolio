dat7 <-read.csv("datexpo7.csv")

tsdat7 <- ts(dat7[,3],frequency = 4, start = c(2019, 1) ,end = c(2022,4))
ets(tsdat7)

autoplot(tsdat7)
ggAcf(tsdat7,lag = 16)
ggAcf(tsdat7,plot=FALSE)
ggPacf(tsdat7,lag = 16)
ggPacf(tsdat7,plot=FALSE)

Box.test(tsdat7, lag=7, type="Ljung-Box")

bart7 <- cbind(dat7[,3],data.frame(c(rep(1,4), rep(2,4), rep(3,4))))
colnames(bart7) <- c("y", "group")

bartlett.test(bart7$y ~bart7$group)

summary(ur.kpss(tsdat7))

adf.test(tsdat7)

nsdiffs(tsdat7)
summary(ur.kpss(diff(tsdat7, differences = 1)))
adf.test(diff(tsdat7, differences = 1))

auto.arima(tsdat7)
ggAcf(diff(tsdat7, differences = 1),lag = 16)
ggPacf(diff(tsdat7, differences = 1),lag = 16)

auto.arima(tsdat7)

