iris
?cmeans

library(e1071)
library(mclust)
library(BayesCVI)
library(UniversalCVI)
library(dbscan)

head(iris)

x = iris
xs = scale(x[,1:4])
x$Species = as.numeric(x$Species)
dim(x)
xs = cbind(xs,x$Species)
colnames(xs)[5] = 'Species'

?AccClust

AccClust(xs,label="Species",algorithm = c("FCM", "EM", "Kmeans"), nstart = 20)

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


#More clustering
library(foreign)
x = read.arff("3-spiral.arff")

par(mfrow=c(1,1))
plot(x[,1:2])

spiral_k = kmeans(scale(x[,1:2]), 3, nstart = 20)

plot(x[,1:2], col = x[,3])
plot(x[,1:2], col = spiral_k$cluster)

#Hclust
?hclust
spiral_h = hclust(dist(scale(x[,1:2])), method = 'single')
plot(spiral_h)
hcolor = cutree(spiral_h,3)
plot(x[,1:2], col = hcolor)

#DBSCAN

?dbscan
eps = 0.1
minpts = 4
dbc = dbscan(scale(x[,1:2]), eps, minpts)
dbc$cluster
plot(x[,1:2], col = dbc$cluster+1)

?kNNdistplot
kNNdistplot(scale(x[,1:2]),4)

#OPTICS
eps = 5
opc = optics(scale(x[,1:2]), eps, minPts = 4)
opc$order
plot(opc)

opc$predecessor
opc$xi

spiral_opt = extractDBSCAN(opc, 0.2)
spiral_opt$cluster
plot(x[,1:2], col = spiral_opt$cluster+1)


#More data

x = read.arff("cure-t2-4k.arff")

par(mfrow=c(1,1))
plot(x[,1:2])

spiral_k = kmeans(scale(x[,1:2]), 6, nstart = 20)

plot(x[,1:2], col = x[,3])
plot(x[,1:2], col = spiral_k$cluster)

#Hclust
?hclust
spiral_h = hclust(dist(scale(x[,1:2])), method = 'complete')
plot(spiral_h)
hcolor = cutree(spiral_h,6)
plot(x[,1:2], col = hcolor)

#DBSCAN
?optics
?dbscan
eps = 0.03
minpts = 4
dbc = dbscan(scale(x[,1:2]), eps, minpts)
dbc$cluster
plot(x[,1:2], col = dbc$cluster+1)

?kNNdistplot
kNNdistplot()

#OPTICS
eps = 1.5
opc = optics(scale(x[,1:2]), eps, minPts = 5)
opc$order

opc$predecessor
opc$xi

spiral_opt = extractDBSCAN(opc, 0.05)
spiral_opt$cluster
plot(x[,1:2], col = spiral_opt$cluster+1)



#More clustering
library(foreign)
x = read.arff("sizes5.arff")

par(mfrow=c(1,1))
plot(x[,1:2])

spiral_k = kmeans(scale(x[,1:2]), 4, nstart = 20)

plot(x[,1:2], col = x[,3])
plot(x[,1:2], col = spiral_k$cluster)

#Hclust
?hclust
spiral_h = hclust(dist(scale(x[,1:2])), method = 'single')
plot(spiral_h)
hcolor = cutree(spiral_h,4)
plot(x[,1:2], col = hcolor)

#DBSCAN

?dbscan
eps = 0.30
minpts = 8
dbc = dbscan(scale(x[,1:2]), eps, minpts)
dbc$cluster
plot(x[,1:2], col = dbc$cluster+1)

?kNNdistplot
kNNdistplot(scale(x[,1:2]),4)

#OPTICS
eps = 5
opc = optics(scale(x[,1:2]), eps, minPts = 5)
opc$order
plot(opc)

opc$predecessor
opc$xi

spiral_opt = extractDBSCAN(opc, 0.2)
spiral_opt$cluster
plot(x[,1:2], col = spiral_opt$cluster+1)

