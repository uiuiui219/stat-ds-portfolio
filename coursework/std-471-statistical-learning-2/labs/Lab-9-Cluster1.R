iris
?cmeans

library(e1071)
library(mclust)
library(BayesCVI)
library(UniversalCVI)

head(iris)

x = iris
xs = scale(x[,1:4])
x$Species = as.numeric(x$Species)
dim(x)
xs = cbind(xs,x$Species)
colnames(xs)[5] = 'Species'

?AccClust

AccClust(xs,label="Species",algorithm = c("FCM", "EM", "Kmeans"), nstart = 20, fzm=4)

?Hvalid
?FzzyCVIs

iris_fcvi = FzzyCVIs(xs[,1:4], 10, indexlist = c('WP', 'PBM'), method = 'FCM', )

plot_idx(iris_fcvi)

iris_cvi = Hvalid(scale(x[,1:4]), 10, indexlist = c('NCI', 'STR'))

plot_idx(iris_cvi)

?kmeans
iris_k = kmeans(xs[,1:4], 3, nstart = 20)
iris_k$cluster

ee = 1e10
for (i in 1:20){
  iris_ct = cmeans(xs[, 1:4],3)
  if (iris_ct$withinerror< ee){
    iris_c = iris_ct
  }
}
iris_c

?Mclust
iris_em = Mclust(xs[,1:4], 3)
iris_em$z
iris_em$classification


par(mfrow=c(2,2))

iris_pca = prcomp(x, scale = TRUE)
iris_pca$x
?plot
plot(iris_pca$x[,1:2], col = x$Species, main = 'True label')
plot(iris_pca$x[,1:2], col = iris_k$cluster, main = 'kmeans')
plot(iris_pca$x[,1:2], col = iris_c$cluster, main = 'cmeans')
plot(iris_pca$x[,1:2], col = iris_em$classification, main = 'EM')

library(foreign)
x = read.arff("3-spiral.arff")

AccClust(x,label="class",algorithm = c("FCM", "EM", "Kmeans"), nstart = 20)


par(mfrow=c(1,1))
plot(x[,1:2])

spiral_k = kmeans(scale(x[,1:2]), 3, nstart = 20)

plot(x[,1:2], col = x[,3])
plot(x[,1:2], col = spiral_k$cluster)

#________________________________________

x = read.arff("cure-t0-2000n-2D.arff")

AccClust(x,label="class",algorithm = c("FCM", "EM", "Kmeans"), nstart = 20)


par(mfrow=c(2,2))
plot(x[,1:2])

xx_k = kmeans(scale(x[,1:2]), 3, nstart = 20)

ee = 1e10
for (i in 1:20){
  xx_ct = cmeans(scale(x[,1:2]),3)
  if (xx_ct$withinerror< ee){
    xx_c = xx_ct
  }
}
xx_c

xx_em = Mclust(scale(x[,1:2]), 3)


plot(x[,1:2], col = x[,3])
plot(x[,1:2], col = xx_k$cluster)
plot(x[,1:2], col = xx_c$cluster)
plot(x[,1:2], col = xx_em$classification)



#________________________________________

x = read.arff("cure-t2-4k.arff")

AccClust(x,label="class",algorithm = c("FCM", "EM", "Kmeans"), nstart = 20,fzm=4)


par(mfrow=c(2,2))
plot(x[,1:2])

xx_k = kmeans(scale(x[,1:2]), 6, nstart = 20)

ee = 1e10
for (i in 1:20){
  xx_ct = cmeans(scale(x[,1:2]),6)
  if (xx_ct$withinerror< ee){
    xx_c = xx_ct
  }
}
xx_c

xx_em = Mclust(scale(x[,1:2]), 6)


plot(x[,1:2], col = x[,3])
plot(x[,1:2], col = xx_k$cluster)
plot(x[,1:2], col = xx_c$cluster)
plot(x[,1:2], col = xx_em$classification)

#________________________________________

x = read.arff("square4.arff")

AccClust(x,label="class",algorithm = c("FCM", "EM", "Kmeans"), nstart = 20,fzm=1.5)


par(mfrow=c(1,1))
plot(x[,1:2])

xx_k = kmeans(scale(x[,1:2]), 4, nstart = 20)

ee = 1e10
for (i in 1:20){
  xx_ct = cmeans(scale(x[,1:2]),4)
  if (xx_ct$withinerror< ee){
    xx_c = xx_ct
  }
}
xx_c

xx_em = Mclust(scale(x[,1:2]), 4)

par(mfrow=c(2,2))
plot(x[,1:2], col = x[,3])
plot(x[,1:2], col = xx_k$cluster)
plot(x[,1:2], col = xx_c$cluster)
plot(x[,1:2], col = xx_em$classification)
