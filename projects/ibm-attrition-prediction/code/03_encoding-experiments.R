ibm_train <- read.csv("data/IBM_train.csv")
colnames(ibm_train)
ibm_train <- ibm_train[,-c(9,22,27)]
str(ibm_train)
ibm_train$Attrition <- as.numeric(as.factor(ibm_train$Attrition))-1

table(ibm_train$Attrition)

library(dplyr)

n_varible <- dim(ibm_train)[2]
n_row <- dim(ibm_train)[1]

chr_type <- 1:n_varible
for (i in 1:n_varible){
  chr_type[i] <- is.character(ibm_train[,i])
}
chr <- which(chr_type == 1)

for (i in chr){
  print(table(ibm_train[,i]))
}
for (i in chr){
  ibm_train[,i] <- as.numeric(as.factor(ibm_train[,i]))-1
}

str(ibm_train)

#-----------------------
pca <- prcomp(scale(ibm_train[,-2]))
pca_var <- (pca$sdev)^2
pca_var_ratio <- pca_var/sum(pca_var)
cumu_var <- cumsum(pca_var_ratio)
plot(cumu_var, type = "b")
which(cumu_var > 0.8)

pc <- data.frame(ibm_train$Attrition, pca$x[,1:18])
pc$ibm_train.Attrition <- as.factor(pc$ibm_train.Attrition)
colnames(pc)[1] <- "Attrition"

scale_ibm <- scale(ibm_train[,-2])
scale_ibm <- data.frame(cbind(ibm_train$Attrition,scale_ibm))
colnames(scale_ibm)[1] <- "Attrition"

logis <- glm(Attrition~., data = pc, family = "binomial")
logis_prob <- predict.glm(logis, type = "response")
logis_pred <- rep(0, n_row)
logis_pred[logis_prob > 0.3] <- 1

plot(sort(logis_prob))

logis_pred
plot(sort(logis_prob))

logis_table <- table(logis_pred, ibm_train$Attrition)
logis_tp <- logis_table[2,2]
logis_tn <- logis_table[1,1]
logis_fp <- logis_table[2,1]
logis_fn <- logis_table[1,2]
logis_acc <- mean(logis_pred == ibm_train$Attrition)
logis_pre <- logis_tp/(logis_tp + logis_fp)
logis_rec <- logis_tp/(logis_tp + logis_fn)
logis_f1 <- 2*logis_pre*logis_rec/(logis_pre + logis_rec)

library(ROSE)
roc.curve(ibm_train$Attrition, logis_pred)


iris
head(iris)
dim(iris)
Data_norm = scale(iris[,1:4])

x <- scale(ibm_train[,-2])
km.out2 = kmeans(scale(ibm_train[,-2]),2,nstart = 100)
km.out3 = kmeans(x,3,nstart = 100)
km.out4 = kmeans(x,4,nstart = 100)
km.out5 = kmeans(x,5,nstart = 100)
km.out6 = kmeans(x,6,nstart = 100)
km.out7 = kmeans(x,7,nstart = 100)
km.out8 = kmeans(x,8,nstart = 100)

km_check <- 1:10
for (i in 1:length(km_check)){
  x <- scale(ibm_train[,-2])
  km <- kmeans(x, i, nstart = 100)
  km_check[i] <- km$tot.withinss
}

diff_k <- c(0, abs(diff(km_check))) 
best_k <- which.max(diff_k)
plot(km_check, type = "b")

par(mfrow=c(1,1))
plot(pca$x[,1:18],col = km.out2$cluster+1 ,pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
huh <- data.frame(ibm_train, clus = km.out2$cluster - 1)
table()

plot(pca$x[,1:18],col = km.out3$cluster+1, pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:18],col = km.out4$cluster+1, pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:18],col = km.out6$cluster+1 ,pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:18],col = km.out7$cluster+1, pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:18],col = km.out8$cluster+1, pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')

hc.complete = hclust(dist(scale(ibm_train[,-2])), method="complete")
hc.average = hclust(dist(scale(ibm_train)), method="average")
hc.single = hclust(dist(scale(ibm_train)), method="single")
hc <- hclust(dist(Data_norm), method = "complete")


plot(hc.complete ,main="Complete Linkage", xlab="", sub="", cex=.9)
plot(hc.average ,main="Average Linkage", xlab="", sub="", cex=.9)
plot(hc.single ,main="Single Linkage", xlab="", sub="", cex=.9)

hc.out = hclust(dist(scale(ibm_train)))
hc.clusters = cutree(hc , 6)
plot(pca$x[,1:2], col = hc.clusters + 1, pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
table(hc.clusters)

km.out2$centers
km.out3$centers
km.out4$centers

clus1 <- ibm_train[km.out4$cluster == 1,]
clus2 <- ibm_train[km.out4$cluster == 2,]
clus3 <- ibm_train[km.out4$cluster == 3,]
clus4 <- ibm_train[km.out4$cluster == 4,]

table(clus1$Attrition)
table(clus2$Attrition)
table(clus3$Attrition)
table(clus4$Attrition)


library(cluster)
for (i in )
sil <- silhouette(hc.clusters, dist(Data_norm))
mean(sil[,3])
                  
library(glmnet)

grid=0.1^seq(3,-3, length=100)
lass <- cv.glmnet(scale(ibm_train[,-2]),ibm_train$Attrition, nfolds = 5, alpha=1, lambda = grid)
rid <- cv.glmnet(scale(ibm_train[,-2]),ibm_train$Attrition, nfolds = 5, alpha=0, lambda = grid)

plot(lass)
plot(rid)

bestlamda <- lass$lambda.min
bestlamda2 <- rid$lambda.min
fin_lasso_mod = glmnet(scale(ibm_train[,-2]),ibm_train$Attrition,alpha=1,lambda=bestlamda, family = "binomial") 
fin_lasso_mod$beta

fin_ridge_mod = glmnet(scale(ibm_train[,-2]),ibm_train$Attrition,alpha=0,lambda=bestlamda2, family = "binomial")
fin_ridge_mod$beta

  