library(psych)

divorce <- read.csv("divorce.csv")
dim(divorce)
set.seed(112)
#-------------------------------------------------

pca <- prcomp(divorce[,-55])
var <- (pca$sdev)^2
var_ratio <- var/sum(var)
cumu <- cumsum(var_ratio)
plot(cumu, type = "b")


each_k_tot <- c(1:10)
for (i in 1:length(each_k_tot)){
  k_m <- kmeans(pca$x[,1:4], i, nstart = 100)
  each_k_tot[i] <- k_m$tot.withinss
}
plot(each_k_tot, type = "b")
diff_k <- c(0, abs(diff(each_k_tot))) 
best_k <- which.max(diff_k)

final_k <- kmeans(pca$x[,1:4], best_k, nstart = 100)
plot(pca$x[,1:4], col = final_k$cluster+1 ,pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')
k_table <- table(final_k$cluster - 1, divorce$Divorce)
k_tp <- k_table[2,2]
k_tn <- k_table[1,1]
k_fp <- k_table[2,1]
k_fn <- k_table[1,2]
k_acc <- mean(final_k$cluster - 1 == divorce$Divorce)
k_pre <- k_tp/(k_tp + k_fp)
k_rec <- k_tp/(k_tp + k_fn)
k_f1 <- (2*k_pre*k_rec)/(k_pre + k_rec)

conf_mat <- data.frame(matrix(c("k_tp", "k_tn", "k_fp", "k_fn",
                                k_tp, k_tn, k_fp, k_fn), byrow = FALSE, nrow = 4))

conf_mat2 <- data.frame(matrix(c("k_acc", "k_pre", "k_rec", "k_f1",
              k_acc, k_pre, k_rec, k_f1), byrow = FALSE, nrow = 4))
conf_mat2$X2 <- round(as.numeric(conf_mat2$X2), digits = 3)

