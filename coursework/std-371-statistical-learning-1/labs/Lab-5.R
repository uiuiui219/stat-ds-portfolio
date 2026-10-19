#1
#try CV for backward and hybrid 

bw=regsubsets (Grad.Rate~.,college,nvmax=17, method="backward")
reg.summary.bwd = summary(bw)
hyb=regsubsets (Grad.Rate~.,college,nvmax=17, method="seqrep")
reg.summary.hyb = summary(hyb)

cv.error.10.bwd=1:17
for (i in 1:17){
  glm.fit=glm(Grad.Rate~.,data=college[,c(reg.summary.bwd$which[i,-1],TRUE)])
  set.seed(1)
  cv.error.10.bwd[i]=cv.glm(college[,c(reg.summary.bwd$which[i,-1],TRUE)],glm.fit,K=10)$delta[1]
}
cv.error.10.bwd
plot(1:17,cv.error.10.bwd,type='b')
points(which.min(cv.error.10.bwd),cv.error.10.bwd[which.min(cv.error.10.bwd)], col="red",cex=2,pch=20)

final.fit.bwd =glm(Grad.Rate~.,data=college[,c(reg.summary.bwd$which[which.min(cv.error.10.bwd),-1],TRUE)])
summary(final.fit.bwd)


cv.error.10.hyb=1:17
for (i in 1:17){
  glm.fit=glm(Grad.Rate~.,data=college[,c(reg.summary.hyb$which[i,-1],TRUE)])
  set.seed(1)
  cv.error.10.hyb[i]=cv.glm(college[,c(reg.summary.hyb$which[i,-1],TRUE)],glm.fit,K=10)$delta[1]
}
cv.error.10.hyb
plot(1:17,cv.error.10.hyb,type='b')
points(which.min(cv.error.10.hyb),cv.error.10.hyb[which.min(cv.error.10.hyb)], col="red",cex=2,pch=20)

final.fit.hyb =glm(Grad.Rate~.,data=college[,c(cv.error.10.hyb$which[which.min(cv.error.10.hyb),-1],TRUE)])
summary(cv.error.10.hyb)
#2 BIC


#Add F1 and precision and you may select the final model based on F1 
k=10
folds=sample(1:k,nrow(college2),replace=TRUE)
sum(folds == 1) 
acc = 1:14
tpp = 1:14
tnn = 1:14
fpp = 1:14
fnn = 1:14
pre = 1:14
rec = 1:14

f1_score = 1:14

for (i in 1:14){
  ndat= college2[,c(as.logical(hyb_model_log$Subsets[i+1,-c(1,16,17)]),T)]  
  cv.acc= 1:k
  tp = 1:k
  tn = 1:k
  fp = 1:k
  fn = 1:k
  for (j in 1:k){
    glm.ndat = glm(y~.,data = ndat[folds!=j,], family=binomial)
    prob = predict(glm.ndat,newdata=ndat[folds==j,],type='response')
    pred = rep('Low',dim(ndat[folds==j,])[1])
    pred[prob>0.5] = 'High'
    cv.acc[j] = mean(pred == ndat[folds==j,ncol(ndat)])
    tp[j] = mean(pred[ndat[folds==j,ncol(ndat)]=='High'] == ndat[folds==j,ncol(ndat)][ndat[folds==j,ncol(ndat)]=='High'])
    tn[j] = mean(pred[ndat[folds==j,ncol(ndat)]=='Low'] == ndat[folds==j,ncol(ndat)][ndat[folds==j,ncol(ndat)]=='Low'])
    
    tab <- table(ndat[folds==j,ncol(ndat)], factor(pred, levels = c("Low", "High")))
    fp[j] = tab[2,1]
    fn[j] = tab[1,2]
    
  }
  acc[i] = mean(cv.acc)
  tpp[i] = mean(tp)
  tnn[i] = mean(tn)
  fpp[i] = mean(fp)
  fnn[i] = mean(fn)
  
  pre[i] = mean(tpp/(tpp+fpp))
  rec[i] = mean(tpp/(tpp+tnn))
  
  f1_score[i] = mean(2*pre*rec/(pre + rec))
}

acc
tpp
tnn
pre
rec
which.max(acc)
hyb_model_log$Subsets[which.max(acc)+1,]

plot(1:14,acc,type='b',pch=20)
 
pre
f1_score



#______________________________________________________
library(boot)
cv.error = 1:17
ss = sample(1:10000)[1]
for (i in 1:17){
  College.pca = data.frame(cbind(pr.out$x[,1:i],College$Grad.Rate))
  colnames(College.pca)[ncol(College.pca)] = "GradRate"
  glm.fit=glm(GradRate ~ ., data = College.pca)
  set.seed(ss)
  cv.error[i]=cv.glm(College.pca,glm.fit,K=5)$delta[1]
}
sqrt(cv.error)
which.min(cv.error)
min(sqrt(cv.error))

College.pca = data.frame(cbind(pr.out$x[,1:which.min(cv.error)],College$Grad.Rate))
colnames(College.pca)[ncol(College.pca)] = "GradRate"
glm.fit=glm(GradRate ~ ., data = College.pca)
summary(glm.fit)

head(College)
glm.fit.ori = glm(Grad.Rate ~ ., data = College)
summary(glm.fit.ori)
set.seed(ss)
cv.error.ori=sqrt(cv.glm(College,glm.fit.ori,K=5)$delta[1])
