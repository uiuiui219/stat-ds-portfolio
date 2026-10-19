bank <- read.csv('BankChurners.csv')

bank <- bank[2:length(bank)]

number <- dim(bank)[1] 
bank$Attrition_Flag <- factor(bank$Attrition_Flag, levels = c("Attrited Customer","Existing Customer"))

monte_acc <- seq(20)
each_threshold <- seq(0.1,0.9,by = 0.1)

tp_each_monte <- seq(20)
tn_each_monte <- seq(20)
fp_each_monte <- seq(20)
fn_each_monte <- seq(20)

pre_each_monte <- seq(20)
rec_each_monte <- seq(20)

f_1_each_monte <- seq(20)

for (i in 1:20){
  for_train <- sample(number, size = (0.8 * number),replace = FALSE)
  for (j in 1:length(each_threshold)){
    fin_model <- glm(Attrition_Flag ~ 
                       Gender + Dependent_count + Income_Category +
                       Total_Relationship_Count + Months_Inactive_12_mon + Contacts_Count_12_mon +
                       Total_Revolving_Bal + Total_Trans_Amt + Total_Trans_Ct,
                     data = bank, subset = for_train, family = 'binomial' )
    fin_prob <- predict(fin_model, newdata = bank[-for_train,], type = 'response')
    
    fin_pred <- rep("Attrited Customer",length(fin_prob))
    fin_pred[fin_prob > (j/10)] = "Existing Customer"
    
    each_threshold[j] = mean(fin_pred == bank[-for_train, ]$Attrition_Flag)
  }
  fin_prob <- predict(fin_model, newdata = bank[-for_train,], type = 'response')
  fin_pred <- rep("Attrited Customer",length(fin_prob))
  fin_pred[fin_prob > (which.max(each_threshold)/10)] = "Existing Customer"
  
  monte_acc[i] =  mean(fin_pred == bank[-for_train, ]$Attrition_Flag)
  
  fin_table <- table(fin_pred, bank[-for_train, ]$Attrition_Flag)
  tp_each_monte[i] <- fin_table[2,2]
  tn_each_monte[i] <- fin_table[1,1]
  fp_each_monte[i] <- fin_table[2,1]
  fn_each_monte[i] <- fin_table[1,2]
  
  pre_each_monte[i] <- tp_each_monte[i]/(tp_each_monte[i]+fp_each_monte[i])
  rec_each_monte[i] <- tp_each_monte[i]/(tp_each_monte[i]+fn_each_monte[i])
  
  f_1_each_monte[i] <- 2*(pre_each_monte[i] * rec_each_monte[i])/(pre_each_monte[i] + rec_each_monte[i])
}


plot(sort(fin_prob))

plot(each_threshold)
cut_prob = which.max(each_threshold)/10

tp_each_monte
tn_each_monte
fp_each_monte
fn_each_monte

pre_each_monte
rec_each_monte

avg_acc <- mean(monte_acc)

avg_tp <- mean(tp_each_monte)
avg_tn <- mean(tn_each_monte)
avg_fp <- mean(fp_each_monte)
avg_fn <- mean(fn_each_monte)

avg_precision <- mean(pre_each_monte)
avg_recall <- mean(rec_each_monte)

avg_f_1_score <- mean(f_1_each_monte)

summary(fin_model)



fin_table
avg_fin_table <- matrix(seq(4),ncol = 2)
colnames(avg_fin_table) <- c('Attrited Customer',  'Existing Customer')
rownames(avg_fin_table) <- c('Predict Attrited Customer',  'Predict Existing Customer')
avg_fin_table[1,1] <- avg_tn
avg_fin_table[2,2] <- avg_tp
avg_fin_table[1,2] <- avg_fn
avg_fin_table[2,1] <- avg_fp

avg_fin_table


library(ROSE)
table(fin_pred, bank$Attrition_Flag[-for_train])
roc.curve(bank$Attrition_Flag[-for_train], fin_pred)


#------------------------------------------------------------
#ข้อ2
colnames(iris)
str(iris)

table(iris$Species)
pairs(iris)

n <- dim(iris)[1]

multinom()

#ท่อนลองเอาเข้า loop
library(nnet)
model.acc = seq(20)

model.pre.c1 = seq(20)
model.pre.c2 = seq(20)
model.pre.c3 = seq(20)

model.rec.c1 = seq(20)
model.rec.c2 = seq(20)
model.rec.c3 = seq(20)

for (i in 1:length(model.acc)){
  iris_train_index <- sample(n, size = (0.8*n))
  model_iris <- multinom(Species~. ,data = iris, subset = iris_train_index, HESS = TRUE)
  
  iris_probs <- predict(model_iris, newdata = iris[-iris_train_index, ], type = 'probs')
  iris_pred <- predict(model_iris, newdata = iris[-iris_train_index, ], type = 'class')
  
  iris_table <- table(iris_pred,iris$Species[-iris_train_index])
  
  iris_acc <- mean(iris$Species[-iris_train_index] == iris_pred)
  
  model.acc[i] = iris_acc
  model.pre.c1[i] = iris_table[1,1]/(iris_table[1,1]+iris_table[1,2]+iris_table[1,3])
  model.pre.c2[i] = iris_table[2,2]/(iris_table[2,1]+iris_table[2,2]+iris_table[2,3])
  model.pre.c3[i] = iris_table[3,3]/(iris_table[3,1]+iris_table[3,2]+iris_table[3,3])
  
  model.rec.c1[i] = iris_table[1,1]/(iris_table[1,1]+iris_table[2,1]+iris_table[3,1])
  model.rec.c2[i] = iris_table[2,2]/(iris_table[1,2]+iris_table[2,2]+iris_table[3,2])
  model.rec.c3[i] = iris_table[3,3]/(iris_table[1,3]+iris_table[2,3]+iris_table[3,3])
}

model.acc
mean(model.acc)


#----------------------------------------------------------

iris_train_index <- sample(n, size = (0.8*n))


model_iris <- multinom(Species~. ,data = iris, subset = iris_train_index, HESS = TRUE)
summary(model_iris)

iris_probs <- predict(model_iris, newdata = iris[-iris_train_index, ], type = 'probs')
iris_pred <- predict(model_iris, newdata = iris[-iris_train_index, ], type = 'class')

iris_table <- table(iris_pred,iris$Species[-iris_train_index])

iris_acc <- mean(iris$Species[-iris_train_index] == iris_pred)




#ข้อ2.3
library(class)
library(KODAMA)

iris_knn_acc = matrix(seq(1:100), ncol = 2)
colnames(iris_knn_acc) <- c("K", "Avg Accuracy")
iris_knn_monte = seq(20)

plot(iris[, 1:4], col = iris$Species )


#หา best K + MONTE
for (i in 1:length(iris_knn_acc[, 2])){
  iris_knn_acc[i, 1] = i
  for (j in 1:length(iris_knn_monte)){
    iris_train_index <- sample(n, size = (0.8*n))
    
    iris_knn <- knn(iris[iris_train_index, -ncol(iris)], iris[-iris_train_index,-ncol(iris)], 
                    cl = iris[iris_train_index, ]$Species,k = i)
    
    iris_knn_monte[j] <- mean(iris[-iris_train_index, ]$Species == iris_knn)
    iris_knn_acc[i, 2] <- mean(iris_knn_monte)
  }
}

length(iris_knn_acc[,2])
iris_knn_acc[i,2]


iris_knn_acc


k_knn <- which.max(iris_knn_acc[,2])
iris_knn <- knn(iris[iris_train_index, -ncol(iris)], iris[-iris_train_index,-ncol(iris)], 
                cl = iris[iris_train_index, ]$Species,k = k_knn)

table(iris$Species[-iris_train_index], iris_knn)

iris_knn_acc[k_knn, ]

pairs(iris)


par(mfrow = c(2,2))

plot(iris$Sepal.Length ,iris$Species, xlab = "Sepal.Length", ylab = "Species")
plot(iris$Sepal.Width ,iris$Species, xlab = "Sepal.Width", ylab = "Species")
plot(iris$Petal.Length ,iris$Species, xlab = "Petal.Length", ylab = "Species")
plot(iris$Petal.Width ,iris$Species, xlab = "Petal.Width", ylab = "Species")

plot(iris[,1:4], col = iris$Species)



plot(iris$Sepal.Length,iris$Sepal.Width, col = iris$Species)
contour(x = iris$Sepal.Length, y = iris$Sepal.Width, z = iris$Species)

plot(iris$Sepal.Length,iris$Petal.Length, col = iris$Species)
plot(iris$Sepal.Length,iris$Petal.Width,col = iris$Species)
plot(iris$Sepal.Width,iris$Petal.Length,col = iris$Species)
plot(iris$Sepal.Width,iris$Petal.Width,col = iris$Species)
plot(iris$Petal.Length,iris$Petal.Width,col = iris$Species)



#correlated sample
library(colorednoise)
mus <- c(0, 3)
sd <- c(2, 1)
cr <- matrix(c(1, 0.5, 0.5, 1), ncol = 2)
sigmas = diag(sd)%*%cr%*%diag(sd)

class1 <- multi_rnorm(200, mus, sigmas)
colMeans(class1)
cor(class1)

mus <- c(-1, 2)
sd <- c(1, 1)
cr <- matrix(c(1, 0.2, 0.2, 1), ncol = 2)
sigmas = diag(sd)%*%cr%*%diag(sd)

class2 <- multi_rnorm(200, mus, sigmas)
colMeans(class2)
cor(class2)

mus <- c(2, -2)
sd <- c(1, 2)
cr <- matrix(c(1, 0.3, 0.3, 1), ncol = 2)
sigmas = diag(sd)%*%cr%*%diag(sd)

class3 <- multi_rnorm(200, mus, sigmas)
colMeans(class3)
cor(class3)

data = rbind(class1,class2,class3)
data = cbind(data,c(rep(1,200),rep(2,200),rep(3,200)))
colnames(data) = c("var1","var2","class")
data = data.frame(data)
head(data)
plot(data[,1:2],col=data[,3])

library(colorednoise)
mus <- c(0, 3)
sd <- c(2, 1)
cr <- matrix(c(1, 0.5, 0.5, 1), ncol = 2)
sigmas = diag(sd)%*%cr%*%diag(sd)

class1 <- multi_rnorm(200, mus, sigmas)

mus <- c(-1, 2)
sd <- c(1, 1)
cr <- matrix(c(1, 0.2, 0.2, 1), ncol = 2)
sigmas = diag(sd)%*%cr%*%diag(sd)

class2 <- multi_rnorm(200, mus, sigmas)

mus <- c(2, -2)
sd <- c(1, 2)
cr <- matrix(c(1, 0.3, 0.3, 1), ncol = 2)
sigmas = diag(sd)%*%cr%*%diag(sd)

class3 <- multi_rnorm(200, mus, sigmas)

data2 = rbind(class1,class2,class3)
data2 = cbind(data2,c(rep(1,200),rep(2,200),rep(3,200)))
colnames(data2) = c("var1","var2","class")
data2 = data.frame(data2)
plot(data2[,1:2],col=data2[,3])

#multinom
mult=multinom(class ~ var1+var2,data=data)
pred = predict(mult,data2)
pred = as.numeric(pred)
table(pred,data2$class)
mean(pred==data2$class)

# draw discrimination line
np <- 500
nd.var1 <- seq(from = min(data$var1), to = max(data$var1), length.out = np)
nd.var2 <- seq(from = min(data$var2), to = max(data$var2), length.out = np)
nd <- expand.grid(var1 = nd.var1, var2 = nd.var2)
dim(nd)
prd <- as.numeric(predict(mult, newdata = nd))
plot(data2[,1:2], col = data2$class)
contour(x = nd.var1, y = nd.var2, z = matrix(prd, nrow = np, ncol = np), 
        levels = c(1, 2,3), add = TRUE, drawlabels = FALSE)



length(nd.var1)*length(nd.var2)


m1 <- multinom(Species~Sepal.Length+Sepal.Width, data = iris, Hess = TRUE)

nd_var1 <- seq(from = seq(from = min(iris$Sepal.Length), to = max(iris$Sepal.Length), length.out = np))
nd_var2 <- seq(from = seq(from = min(iris$Sepal.Width), to = max(iris$Sepal.Width), length.out = np))

nd_var3 <- seq(from = seq(from = min(iris$Petal.Length), to = max(iris$Petal.Length), length.out = np))
nd_var4 <- seq(from = seq(from = min(iris$Petal.Width), to = max(iris$Petal.Width), length.out = np))

plot(iris$Sepal.Length, iris$Sepal.Width , col = iris$Species)

nf <- expand.grid(Sepal.Length = nd_var1, Sepal.Width = nd_var2)
p_r_d <- as.numeric(predict(m1, newdata = nf))



contour(x = nd_var1, y = nd_var2, z = matrix(p_r_d, nrow = np, ncol = np), 
        levels = c(1, 2,3), add = TRUE, drawlabels = FALSE)

ontour(x  = sep_length, y = sep_width, z = matrix(prd_1_2, nrow = np , ncol = np), 
       levels = c(1, 2,3), add = TRUE, drawlabels = FALSE)


full_iris


plot(iris$Sepal.Length,iris$Sepal.Width, col = iris$Species)
contour(x  = sep_length, y = sep_width, z = matrix(prd_1_2, nrow = np , ncol = np), levels = c(1, 2,3), add = TRUE, drawlabels = FALSE)



