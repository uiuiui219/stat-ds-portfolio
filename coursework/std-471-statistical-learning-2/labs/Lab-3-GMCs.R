library(dplyr)
#ibrary(FuzzyDatasets)
library(ISLR2)
library(MASS)
library(nnet)
library(e1071)
library(UniversalCVI)
library(klaR)

# Data frame for collect Result
Data = c("R1_data","iris","Carseat")
No.model = 3 # LDA, QDA, NAIVEBAYES
No.data = length(Data) 
Row.name = c(paste0("LDA","_",Data),paste0("QDA","_",Data),paste0("NAIVEBAYES","_",Data))
GMC.result  = matrix(0,nrow = (No.model*No.data)) %>% as.data.frame()
rownames(GMC.result) = Row.name
colnames(GMC.result) = "MEAN ACC"

plot(R1_data[,1:2])

head(iris)
head(Carseats)

# LinCarseats# Linear Discriminant Analysis X k-fold
# Simulated data
K = 1:10
Model.Data = data.frame(R1_data)
Model.Data %>% head() # check data names
plot(Model.Data[,1:2])
label.name = "label" # select label names
folds = sample(K,nrow(Model.Data),replace=TRUE)
Acc1 = data.frame()
for(i in K){
  LDA.Train = lda(label ~., data =  Model.Data[folds!=i,])
  LDA.Vld = predict(LDA.Train, Model.Data[folds==i,])
  LDA.Class = LDA.Vld$class
  # Data frame for record best j based on the highest value of Accuracy prediction.
  Acc1[i,"Round"] = i
  Acc1[i,"Acc"] = mean(LDA.Class == Model.Data[folds==i,label.name])
}
Acc1
mean(Acc1[,2])

LDA.final = lda(label ~., data =  Model.Data)
LDA.final

# ----Iris data----
K = 1:10
Model.Data = data.frame(iris)
Model.Data %>% head() # check data names
plot(Model.Data[,1:2])
label.name = "Species" # select label names
folds = sample(K,nrow(Model.Data),replace=TRUE)
Acc2 = data.frame()
for(i in K){
  LDA.Train = lda(Species ~., data =  Model.Data[folds!=i,])
  LDA.Vld = predict(LDA.Train, Model.Data[folds==i,])
  LDA.Class = LDA.Vld$class
  # Data frame for record best j based on the highest value of Accuracy prediction.
  Acc2[i,"Round"] = i
  Acc2[i,"Acc"] = mean(LDA.Class == Model.Data[folds==i,label.name])
}
Acc2
mean(Acc2[,2])

LDA.final = lda(Species ~., data =  Model.Data)

LDA.final

LDA.pred = predict(LDA.final, Model.Data)
ldahist(data= LDA.pred$x[, 2], g = Model.Data$Species)

partitionPlot <- partimat(Species~., data=Model.Data, method="lda")


# Carseat data
# Select data
K = 1:10
Model.Data = Carseats
head(Model.Data)
#Model.Data = data.frame(Carseats[,-c(10:11)])
label.name = "ShelveLoc" # select label names
folds = sample(K,nrow(Model.Data),replace=TRUE)
Acc3 = data.frame()
for(i in K){
  LDA.Train = lda(ShelveLoc ~., data =  Model.Data[folds!=i,])
  LDA.Vld = predict(LDA.Train, Model.Data[folds==i,])
  LDA.Class = LDA.Vld$class
  # Data frame for record best j based on the highest value of Accuracy prediction.
  Acc3[i,"Round"] = i
  Acc3[i,"Acc"] = mean(LDA.Class == Model.Data[folds==i,label.name])
}
Acc3
mean(Acc3[,2])

LDA.final = lda(ShelveLoc ~., data =  Model.Data)
LDA.final

?lda

#_____________________________________________________________
# Quadratic Discriminant Analysis X K-folds CV
# Simulated data
K = 1:10
Model.Data = data.frame(R1_data)
Model.Data %>% head() # check data names
plot(Model.Data[,1:2])
label.name = "label" # select label names
folds = sample(K,nrow(Model.Data),replace=TRUE)
Acc4 = data.frame()
for(i in K){
  LDA.Train = qda(label ~., data =  Model.Data[folds!=i,])
  LDA.Vld = predict(LDA.Train, Model.Data[folds==i,])
  LDA.Class = LDA.Vld$class
  # Data frame for record best j based on the highest value of Accuracy prediction.
  Acc4[i,"Round"] = i
  Acc4[i,"Acc"] = mean(LDA.Class == Model.Data[folds==i,label.name])
}
Acc4
mean(Acc4[,2])

LDA.final = qda(label ~., data =  Model.Data)
LDA.final

# ----Iris data----
K = 1:10
Model.Data = data.frame(iris)
Model.Data %>% head() # check data names
plot(Model.Data[,1:2])
label.name = "Species" # select label names
folds = sample(K,nrow(Model.Data),replace=TRUE)
Acc5 = data.frame()
for(i in K){
  LDA.Train = qda(Species ~., data =  Model.Data[folds!=i,])
  LDA.Vld = predict(LDA.Train, Model.Data[folds==i,])
  LDA.Class = LDA.Vld$class
  # Data frame for record best j based on the highest value of Accuracy prediction.
  Acc5[i,"Round"] = i
  Acc5[i,"Acc"] = mean(LDA.Class == Model.Data[folds==i,label.name])
}
Acc5
mean(Acc5[,2])

LDA.final = qda(Species ~., data =  Model.Data)
LDA.final


# Carseat data
# Select data
K = 1:10
Model.Data = Carseats
head(Model.Data)
Model.Data = data.frame(Carseats[,-c(10:11)])
label.name = "ShelveLoc" # select label names
folds = sample(K,nrow(Model.Data),replace=TRUE)
Acc6 = data.frame()
for(i in K){
  LDA.Train = qda(ShelveLoc ~., data =  Model.Data[folds!=i,])
  LDA.Vld = predict(LDA.Train, Model.Data[folds==i,])
  LDA.Class = LDA.Vld$class
  # Data frame for record best j based on the highest value of Accuracy prediction.
  Acc6[i,"Round"] = i
  Acc6[i,"Acc"] = mean(LDA.Class == Model.Data[folds==i,label.name])
}
Acc6
mean(Acc6[,2])

LDA.final = qda(ShelveLoc ~., data =  Model.Data)
LDA.final

#_________________________________________________________________
# Naive Bayes Analysis X k fold CV
# Generated data 
# Simulated data
K = 1:10
Model.Data = data.frame(R1_data)
Model.Data %>% head() # check data names
plot(Model.Data[,1:2])
label.name = "label" # select label names
folds = sample(K,nrow(Model.Data),replace=TRUE)
Acc7 = data.frame()
for(i in K){
  LDA.Train = naiveBayes(label ~., data =  Model.Data[folds!=i,])
  LDA.Vld = predict(LDA.Train, Model.Data[folds==i,])
  LDA.Class = LDA.Vld
  # Data frame for record best j based on the highest value of Accuracy prediction.
  Acc7[i,"Round"] = i
  Acc7[i,"Acc"] = mean(LDA.Class == Model.Data[folds==i,label.name])
}
Acc7
mean(Acc7[,2])

LDA.final = naiveBayes(label ~., data =  Model.Data)
LDA.final

# ----Iris data----
K = 1:10
Model.Data = data.frame(iris)
Model.Data %>% head() # check data names
plot(Model.Data[,1:2])
label.name = "Species" # select label names
folds = sample(K,nrow(Model.Data),replace=TRUE)
Acc8 = data.frame()
for(i in K){
  LDA.Train = naiveBayes(Species ~., data =  Model.Data[folds!=i,])
  LDA.Vld = predict(LDA.Train, Model.Data[folds==i,])
  LDA.Class = LDA.Vld
  # Data frame for record best j based on the highest value of Accuracy prediction.
  Acc8[i,"Round"] = i
  Acc8[i,"Acc"] = mean(LDA.Class == Model.Data[folds==i,label.name])
}
Acc8
mean(Acc8[,2])

LDA.final = naiveBayes(Species ~., data =  Model.Data)
LDA.final


# Carseat data
# Select data
K = 1:10
Model.Data = Carseats
head(Model.Data)
Model.Data = data.frame(Carseats[,-c(10:11)])
label.name = "ShelveLoc" # select label names
folds = sample(K,nrow(Model.Data),replace=TRUE)
Acc9 = data.frame()
for(i in K){
  LDA.Train = naiveBayes(ShelveLoc ~., data =  Model.Data[folds!=i,])
  LDA.Vld = predict(LDA.Train, Model.Data[folds==i,])
  LDA.Class = LDA.Vld
  # Data frame for record best j based on the highest value of Accuracy prediction.
  Acc9[i,"Round"] = i
  Acc9[i,"Acc"] = mean(LDA.Class == Model.Data[folds==i,label.name])
}
Acc9
mean(Acc9[,2])

LDA.final = naiveBayes(ShelveLoc ~., data =  Model.Data)
LDA.final
# Record result
GMC.result[,"MEAN ACC"] = unlist(lapply(mget(paste0("Acc",seq(No.model*No.data))),colMeans))[seq(2,18,2)]
GMC.result



#Draw discrimination lines
LDA.final = lda(label ~., data =  data.frame(R1_data))
np <- 500
nd.var1 <- seq(from = min(R1_data[,1]), to = max(R1_data[,1]), length.out = np)
nd.var2 <- seq(from = min(R1_data[,2]), to = max(R1_data[,2]), length.out = np)
nd <- expand.grid(var1 = nd.var1, var2 = nd.var2)
names(nd) = names(R1_data)[1:2]
dim(nd)
prd <- as.numeric(predict(LDA.final,data.frame(nd))$class)
plot(R1_data[,1:2], col = R1_data$label)
contour(x = nd.var1, y = nd.var2, z = matrix(prd, nrow = np, ncol = np), 
        levels = 1:9, add = TRUE, drawlabels = FALSE)

