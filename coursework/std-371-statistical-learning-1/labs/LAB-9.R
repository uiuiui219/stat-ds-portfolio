library(UniversalCVI)
#1 acc ของที่ให้
AccClust(R1_data, label.names = "label",algorithm = c("Kmeans","FCM","EM"), fzm = 2,
         scale = TRUE, nstart = 20,iter = 100)
AccClust(R7_data, label.names = "label",algorithm = c("Kmeans","FCM","EM"), fzm = 2,
         scale = TRUE, nstart = 20,iter = 100)


#2 ลอง dataset อื่น
plot(R3_data[,-3])

cvi_r3_kmean = Hvalid(scale(R3_data[,-3]), kmax = 17, kmin = 2, indexlist = c("NCI", "DI", "DB", "DBs", "CSL", "CH"), method = "kmeans", p = 2, q = 2, corr = "pearson", nstart = 100, NCstart = TRUE)
cvi_r3_hccom = Hvalid(scale(R3_data[,-3]), kmax = 17, kmin = 2, indexlist = c("NCI", "DI", "DB", "DBs", "CSL", "CH"), method = "hclust_complete", p = 2, q = 2, corr = "pearson", nstart = 100, NCstart = TRUE)

AccClust(R3_data, label.names = "label",algorithm = c("Kmeans","FCM","EM"), fzm = 2,
         scale = TRUE, nstart = 20,iter = 100)

plot_idx(re_cvi_r3)

r3plot = ggplot(R3_data,aes(x,y))+
  geom_point(size=2,shape = 16,col=R3_data$label)+
  ggtitle("9 groups or 3 groups")
r3plot


dat.check = d2

colnames(dat.check) = c("x","y","label")
n.clust= length(unique(dat.check[,3]))

# Using kmeans
dat.check = R3_data
kmean_check = kmeans(dat.check[,-3],centers = n.clust, iter.max = 100, nstart = 100)

re.clust = kmean_check$cluster
re.cen = kmean_check$centers
cplot = ggplot(data.frame(dat.check),aes(x,y))+
  geom_point(size=2,shape = 16,col=re.clust)+
  geom_point(size = 2,shape = 19,data = as.data.frame(re.cen), aes(x = x, y = y), color = "yellow")+
  ggtitle("Result from clustering with k = 9")

ggarrange(r3plot,cplot)


#3 ลอง ภาพ
plotTheme <- function() {
  theme(
    panel.background = element_rect(
      linewidth = 3,
      colour = "black",
      fill = "white"),
    axis.ticks = element_line(
      linewidth = 2),
    panel.grid.major = element_line(
      colour = "gray80",
      linetype = "dotted"),
    panel.grid.minor = element_line(
      colour = "gray90",
      linetype = "dashed"),
    axis.title.x = element_text(
      #linewidth = rel(1.2),
      face = "bold"),
    axis.title.y = element_text(
      #linewidth = rel(1.2),
      face = "bold"),
    plot.title = element_text(
      #linewidth = 20,
      face = "bold",
      vjust = 1.5)
  )
}


tumor <- "https://storage.googleapis.com/kagglesdsdata/datasets/165566/377107/yes/Y23.JPG?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=databundle-worker-v2%40kaggle-161607.iam.gserviceaccount.com%2F20250321%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20250321T184843Z&X-Goog-Expires=345600&X-Goog-SignedHeaders=host&X-Goog-Signature=4b2e5ce54839f374066844021a1abe89565d82ae495ccf684c2baba8e9cec8b9fbc81acac8481744e5cf3034d60f4b1f08a4189385c740599faaeafe39c20c434cb358def86828f6bd7506cfd599565dceb420d2e3c38c0fca79c171c0514fc718c33e2f92b0eba5490297ba7f60e26b17ef86c392e326d1033a88d64e04a360506d679ff4c2bde978b1c612e7e06c59bde4b124746261b9b8ff59c84c2aa548c2a270660de9ad6977021468d3f7a0980fa26d3426fa0ae2ca61573c5bf588a7c749e4ea201af33dcf69c1cd6db039f16e24978b44186e9243e70376dd181378d2eb797417fbf992657034e3587cc59af3eacb0c3c51b43ea532b7576459a81c"
download.file(tumor,'y.jpg', mode = 'wb')

IMG1 <- load.image("y.jpg")

IMG.dat = data.frame()

IMG.dat[1,"NAME"] = paste0("IMG",1)
IMG.dat[1,"DIM1"] = dim(IMG1)[1]
IMG.dat[1,"DIM2"] = dim(IMG1)[2]
IMG.dat[1,"DIM3"] = dim(IMG1)[3]

# convert to RGB

img.rgb = data.frame(
  x = rep(1:IMG.dat[1,"DIM2"], each = IMG.dat[1,"DIM1"]),
  y = rep(IMG.dat[1,"DIM1"]:1, IMG.dat[1,"DIM2"]),
  R = as.vector(IMG1[,,1]),
  G = as.vector(IMG1[,,2]),
  B = as.vector(IMG1[,,3]))

img.rgb

ggplot(data = img.rgb, aes(x = x, y = y)) +
  geom_point(colour = rgb(img.rgb[c("R", "G", "B")])) +
  labs(title = "Original Image") +
  xlab("x") +
  ylab("y") +
  plotTheme()



# check main algorithm
c = 2
c.img = kmeans(img.rgb[, c("R", "G", "B")],center = c, iter.max = 100,nstart =20)


chg.col = c("#DC0000","#26C6DA","#FFA000","#9B6BF2","#A50E82")
kColours <- rgb(c.img$centers[c.img$cluster,])
col = kColours %>% unique()
ncolor = kColours %>% unique() %>% length()

for(j in 1:ncolor){
  kColours[kColours==col[j]] =  chg.col[j]
}

# Plot for clustering algorithm
test.group = ggplot(data = img.rgb, aes(x = x, y = y)) +
  geom_point(colour = kColours) +
  labs(title = paste("K-Means Clustering of", c, "Colours")) +
  xlab("x") +
  ylab("y") +
  plotTheme()
test.group


# sample plot 
sample = sample(dim(img.rgb)[1],floor(0.5*dim(img.rgb)[1]),replace = FALSE)


sam.plot = img.rgb[sample,]
ggplot(data = sam.plot, aes(x = x, y = y)) +
  geom_point(colour = rgb(sam.plot[c("R", "G", "B")])) +
  labs(title = paste("Sample plot")) +
  xlab("x") +
  ylab("y") +
  plotTheme()


# Apply CVI

re.cvi = Wvalid(img.rgb[,c("R","G","B")], kmax = 5, kmin = 2, method = "kmeans",
                corr = "pearson", nstart = 100, sampling = 0.3, NCstart = TRUE)
plot_idx(re.cvi)



# Apply CVI

re.cvi = Wvalid(img.rgb[,c("R","G","B")], kmax = 5, kmin = 2, method = "kmeans",
                corr = "pearson", nstart = 100, sampling = 0.3, NCstart = TRUE)
plot_idx(re.cvi)

