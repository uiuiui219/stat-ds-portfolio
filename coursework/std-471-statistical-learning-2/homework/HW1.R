library(ISLR2)
library(dplyr)
library(ggplot2)


# ข้อ 1 tune cut-off ได้ว่าเลือกใช้ cutoff > 0.35

data = Default
K = 1:10
folds = sample(K,nrow(data),replace=TRUE)
label.name = "default"
Acc1= data.frame()
for(i in K){
  train= glm(default~., data = data[folds!=i,],
             family = "binomial")
  pred = ifelse(predict(train,newdata = data[folds==i,],type = "response")> 0.35,
                "Yes","No")
  Acc1[i,"Acc"] = mean(Default[folds==i,label.name]==pred)
  tab = table(Default[folds==i,label.name],pred)
  Acc1[i,"TPR"] = tab[2,2]/(tab[2,1]+tab[2,2])
  Acc1[i,"F1"] = 2*tab[2,2]/(tab[1,2]+tab[2,1]+2*tab[2,2])
}
colMeans(Acc1)
summary(glm(default~., data = data,
            family = "binomial"))






creditcard <- read.csv("CreditCard.csv")
creditcard

# ข้อ 2 credit poisson

ggplot(data = creditcard ,
       aes(x = active,)) + 
  geom_histogram() + 
  theme_minimal()


hist(creditcard$active)

rmse_poi <- NA
for (i in 1:10){
  train_idx <- sample(1:dim(creditcard)[1], size = (0.8 * dim(creditcard)[1]))
  credit_train <- creditcard[train_idx,]
  credit_test <- creditcard[-train_idx,]


  poi_mod <- glm(active~.,data = credit_train, 
               family = "poisson")
  poi_pred <- predict.glm(poi_mod, newdata = credit_test, type = "response")

  rmse_poi[i] <-  sqrt(mean((credit_test$active - poi_pred)^2))
}

mean(rmse_poi) # ประมาณ 6



# ข้อ 3 GAMMA (ent,oncology,psychiatry,surgical)

library(dplyr)
pqt <- read.csv("pqt.csv")

library(ggplot2)
ggplot(data = pqt, aes(x = doctor, y = st)) + 
  geom_boxplot() +
  theme_minimal()

library(ggridges)
ggplot(data = pqt, aes(x = st, y = doctor)) + 
  geom_density_ridges() +
  theme_minimal()

ggplot(data = pqt, aes(x = st, y = doctor)) +
  geom_count(aes(colour = Gender)) +
  theme_minimal()

selected_pqt <- pqt |> 
  filter(doctor %in% c("ent",
                       "oncology",
                       "psychiatry",
                       "surgical"))

ggplot(data = selected_pqt, aes(x = doctor, y = st)) + 
  geom_boxplot() +
  theme_minimal()

gam_rmse <- NA
for (i in 1:10){
  train_gam_idx <- sample(1:dim(selected_pqt)[1], 
                        size = (0.8 * dim(selected_pqt)[1]))
  train_selected_pqt <- selected_pqt[train_gam_idx,]
  test_selected_pqt <- selected_pqt[-train_gam_idx,]
  
  gam_mod <- glm(st~., 
               data = train_selected_pqt,
               family = "Gamma")
  gam_pred <- predict(gam_mod,newdata = test_selected_pqt, type = "response")
  gam_rmse[i] <- sqrt(mean((test_selected_pqt$st - gam_pred)^2))
}

mean(gam_rmse)
summary(gam_mod)
fin_table <- cbind(test_selected_pqt, gam_pred) 


fin_table |> 
  group_by(doctor, Gender) |> 
  summarise(mean(gam_pred))




