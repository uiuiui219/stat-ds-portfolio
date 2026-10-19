#Compare the following models
#1: Model from original data with your best threshold
glm.fits=glm(default~balance,data=Default,family=binomial)
summary(glm.fits)
coef(glm.fits)
nd = data.frame(seq(0,3000,0.01))
colnames(nd) = "balance"
glm.probs=predict(glm.fits,newdata=nd,type="response")

glm.fits2=glm(default~balance+student,data=Default,family=binomial)

summary(glm.fits)
summary(glm.fits2)
coef(glm.fits)
glm.probs=predict(glm.fits,type="response")

contrasts(Default$default)
glm.pred=rep("No",dim(Default)[1])
glm.pred[glm.probs >0.3]="Yes"
sum(glm.pred=="Yes")
table1 = table(glm.pred,Default$default)
mean(glm.pred==Default$default)
table1

#2: Model from SMOTE with your good choice of perc.over and perc.under
library(performanceEstimation)
znew <- smote(default~.,Default, perc.over = 8,perc.under=1.2)
dim(znew)
sum(znew$default == "Yes")
sum(znew$default == "No")

glm.fits2=glm(default~balance+income+student,data=znew,family=binomial)
summary(glm.fits2)
coef(glm.fits2)
glm.probs2=predict(glm.fits2,type="response")
glm.pred2=rep("No",dim(znew)[1])
glm.pred2[glm.probs2 >0.5]="Yes"
table2 = table(glm.pred2,znew$default)
#Accuracy
mean(glm.pred2==znew$default)
table2
#FPR 
fpr2 = table2[2,1]/(table2[1,1]+table2[2,1])
#FNR 
fnr2 = table2[1,2]/(table2[1,2]+table2[2,2])
#TPR
tpr2 = table2[2,2]/(table2[1,2]+table2[2,2])
#TNR
tnr2 = table2[1,1]/(table2[1,1]+table2[2,1])
#F1
f12 = 2*table2[2,2]/(2*table2[2,2]+table2[2,1]+table2[1,2])
#3: Add recall and precision
precision <- tpr2/(tpr2+fpr2)
recall_score <- tpr2/(tpr2+fnr2)


