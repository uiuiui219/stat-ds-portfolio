library(psych)

divorce <- read.csv("divorce.csv")
dim(divorce)
set.seed(112)
#-------------------------------------------------
cor(divorce[,-55])
KMO(cor(divorce[,-55]))
cortest.bartlett(cor(divorce[,-55]), n = nrow(divorce[,-55]))

pca <- prcomp(divorce[,-55])
var <- (pca$sdev)^2
var_ratio <- var/sum(var)
cumu <- cumsum(var_ratio)
plot(cumu, type = "b")

fa_divorce <- fa(divorce[,-55], nfactors = 4,rotate = "varimax",fm="pa")
print(fa_divorce$loadings,cutoff = 0.45)
fa.diagram(fa_divorce, cut = 0.45)

pa_max_pos <- apply(fa_divorce$loading, 1, which.max)
pa_max_load <- apply(fa_divorce$loading, 1, max)
pa_load_cutoff <- ifelse(pa_max_load >= 0.45, pa_max_pos, NA)


dict <- read.csv("divorce dict.csv")
dict <- dict[,1]
pa_each <- data.frame(pa_max_pos, pa_max_load, dict)
colnames(pa_each) <- c("pa", "loading", "questionaire")

pa1 <- data.frame(which(pa_each$pa == 1),
                  pa_each[which(pa_each$pa == 1),]$loading,
                  pa_each[which(pa_each$pa == 1),]$questionaire)
pa2 <- data.frame(which(pa_each$pa == 3),
                  pa_each[which(pa_each$pa == 3),]$loading,
                  pa_each[which(pa_each$pa == 3),]$questionaire)
pa3 <- data.frame(which(pa_each$pa == 2),
                  pa_each[which(pa_each$pa == 2),]$loading,
                  pa_each[which(pa_each$pa == 2),]$questionaire)
pa4 <- data.frame(which(pa_each$pa == 4),
                  pa_each[which(pa_each$pa == 4),]$loading,
                  pa_each[which(pa_each$pa == 4),]$questionaire)

colnames(pa1) <- c("factor_1", "loading", "questionaire")
colnames(pa2) <- c("factor_2", "loading", "questionaire")
colnames(pa3) <- c("factor_3", "loading", "questionaire")
colnames(pa4) <- c("factor_4", "loading", "questionaire")


each_k_tot <- c(1:10)
for (i in 1:length(each_k_tot)){
  k_m <- kmeans(divorce[,-55], i, nstart = 100)
  each_k_tot[i] <- k_m$tot.withinss
}
plot(each_k_tot, type = "b")
plot(pca$x[,1:4], col = k_m$cluster+1 ,pch=20, cex=1,ann = FALSE,xaxt='n',yaxt='n')


diff_k <- c(0, abs(diff(each_k_tot))) 
best_k <- which.max(diff_k)

final_k <- kmeans(divorce[,-55], best_k, nstart = 100)
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

