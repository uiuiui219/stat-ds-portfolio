divorce <- read.csv("divorce.csv")
dim(divorce)
#-------------------------------------------------
pc_divorce <- principal(cor(divorce[,-55]), 4, rotate = "varimax")
print(pc_divorce$loadings, cutoff = 0.3)
fa.diagram(pc_divorce)

pca <- prcomp(divorce[,-55])
var <- (pca$sdev)^2
var_ratio <- var/sum(var)
cumu <- cumsum(var_ratio)
plot(cumu, type = "b")

cor(divorce[,-55])
KMO(cor(divorce[,-55]))
cortest.bartlett(cor(divorce[,-55]), n = nrow(divorce[,-55]))

fa_divorce <- fa(divorce[,-55], nfactors = 4,rotate = "varimax",fm="pa")
fa_divorce$loadings
print(fa_divorce)
fa_load <- print(fa_divorce$loadings,cutoff = 0.45)
fa.diagram(fa_divorce, cut = 0.45)

par(mfrow = c(1,1))

mat <- matrix(rep(1,54), nrow = 54, ncol = 1)
rownames(mat) <- c(1:54)
colnames(mat) <- c("pa")

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



