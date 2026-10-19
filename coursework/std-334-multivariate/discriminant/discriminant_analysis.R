depress <- read.csv("Depression.csv")
depress$Depression <- as.factor(depress$Depression)

depress_numeric <- depress[, c("Age", "Academic.Pressure", "Study.Satisfaction", "Study.Hours", "Financial.Stress", "Depression")]
str(depress_numeric)

summary(depress_numeric)
table(depress$Depression)

library(tidyverse)
library(caret)
set.seed(123)
training.samples <- depress_numeric$Depression %>% createDataPartition(p = 0.8, list = FALSE)
train.data <- depress_numeric[training.samples, ]
test.data <- depress_numeric[-training.samples, ]

preproc.param <- train.data %>%  preProcess(method = c("center", "scale")) 
train.transformed <- preproc.param %>% predict(train.data) 
test.transformed <- preproc.param %>% predict(test.data) 

library(MVN)
result1 <- mvn(data = depress_numeric[train.transformed$Depression == "No", -6], mvnTest = "mardia",multivariatePlot = "qq") 
result1$multivariateNormality 
result2 <- mvn(data = depress_numeric[train.transformed$Depression == "Yes", -6], mvnTest = "mardia",multivariatePlot = "qq") 
result2$multivariateNormality 

library(rstatix) 
box_m(train.transformed[,1:5], train.transformed[,6])



library(MASS) 
model <- lda(Depression~., data = train.transformed) 
model

predtrain <- predict(model) 
lda.datatrain <- cbind(train.transformed, predtrain$x,predtrain$class)  

predtest <- model %>% predict(test.transformed) 
lda.datatest <- cbind(test.transformed, predtest$x,predtest$class)  

ctrain <- table(train.transformed$Depression, predtrain$class)
ctrain
diag(prop.table(ctrain, 1)) 
sum(diag(prop.table(ctrain))) 
ctest <- table(test.transformed$Depression, predtest$class) 
ctest
diag(prop.table(ctest, 1)) 
sum(diag(prop.table(ctest)))
