BankChurners <- read.csv("BankChurners.csv")
bank_og <- data.frame(BankChurners[,c(2:8, 10:14, 21)])
bank_og$Attrition_Flag <- as.factor(bank_og$Attrition_Flag)

bank <- model.matrix(Attrition_Flag~., data = bank_og)[,-1]
bank <- scale(bank)
bank <- data.frame(bank)
str(bank)
k_mean <- kmeans(bank,2,nstart = 1)
k_check <- 1:10
for (i in 1:length(k_check)){
  k_mean <- kmeans(bank,i,nstart = 50)
  k_check[i] = k_mean$tot.withinss
}

k_check_cut_gender <- 1:10
for (i in 1:length(k_check_cut_gender)){
  k_mean_cut_gender <- kmeans(bank[,-2],i,nstart = 50)
  k_check_cut_gender[i] = k_mean_cut_gender$tot.withinss
}



par(mfrow = c(1,1))
plot(k_check, type = "b")
plot(k_check_cut_gender, type = "b")

k_elbow <- diff(k_check)
k_elbow_cut_gender <- diff(k_check_cut_gender)
plot(k_elbow, type = "b")
plot(k_elbow_cut_gender, type = "b")

# ผลที่เกิด elbow 2 อันนี้น่าจะเป็นเพราะ การ cluster เพศ
k_use <- 2

k_mean_2 <- kmeans(bank,2,nstart = 100)
k_mean_3 <- kmeans(bank,3,nstart = 100)
k_mean_4 <- kmeans(bank,4,nstart = 100)
k_4_cut_gender <- kmeans(bank[,-2],4,nstart = 100)
k_mean_5 <- kmeans(bank,5,nstart = 100)
k_mean_6 <- kmeans(bank,6,nstart = 100)
k_mean_7 <- kmeans(bank,7,nstart = 100)
k_mean_8 <- kmeans(bank,8,nstart = 100)
k_mean_9 <- kmeans(bank,9,nstart = 100)

pca <- prcomp(bank,scale = TRUE)
pc_var <- (pca$sdev)^2
var_ratio <- pc_var/sum(pc_var)
var_cumu <- cumsum(var_ratio)

par(mfrow = c(1,1))
plot(var_cumu)

pc_select <- head(which(var_cumu > 0.8),1)

plot(pca$x[,1:pc_select],col = k_mean_2$cluster+1, pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = k_mean_3$cluster+1, pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = k_mean_4$cluster+1, pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = k_4_cut_gender$cluster+1, pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')

plot(pca$x[,1:pc_select],col = k_mean_5$cluster+1, pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = k_mean_6$cluster+1, pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = k_mean_7$cluster+1, pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = k_mean_8$cluster+1, pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = k_mean_9$cluster+1, pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')

table(k_mean$cluster, bank_og$Gender)


mean(check_bank == bank_og$Attrition_Flag)

bank_complete =hclust(dist(bank), method="complete")
bank_average =hclust(dist(bank), method="average")
bank_single =hclust(dist(bank), method="single")

par(mfrow=c(1,3))
plot(bank_complete ,main="Complete Linkage", xlab="", sub="", cex=.9)
plot(bank_average ,main="Average Linkage", xlab="", sub="", cex=.9)
plot(bank_single ,main="Single Linkage", xlab="", sub="", cex=.9)

sum(cutree(bank_complete, 8)==1)
sum(cutree(bank_complete, 8)==2)
sum(cutree(bank_complete, 8)==3)
sum(cutree(bank_complete, 8)==4)
sum(cutree(bank_complete, 8)==5)
sum(cutree(bank_complete, 8)==6)
sum(cutree(bank_complete, 8)==7)
sum(cutree(bank_complete, 8)==8)

cbind(cutree(bank_complete, 3),bank)

plot(pca$x[,1:pc_select],col = cutree(bank_complete,2), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_complete,3), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_complete,4), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_complete,5), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_complete,6), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_complete,7), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_complete,8), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_complete,9), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_complete,10), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')



plot(pca$x[,1:pc_select],col = cutree(bank_average,3), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_average,4), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_average,5), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_average,6), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_average,7), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_average,8), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')v
plot(pca$x[,1:pc_select],col = cutree(bank_average,9), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_average,10), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')


plot(pca$x[,1:pc_select],col = cutree(bank_single,3), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_single,4), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_single,5), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_single,6), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_single,7), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_single,8), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_single,9), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
plot(pca$x[,1:pc_select],col = cutree(bank_single,10), pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')


plot(sort(rnorm(n = 21, mean = 8.9, sd = 3.9)))

plot(sort(rnorm(n = 24, mean = 10.35, sd = 5.35)))

plot(sort(c(4,rnorm(n = 19, mean = 8.9, sd = 3.9),19)))
plot(sort(c(3,rnorm(n = 22, mean = 10.35, sd = 5.35),21)))

