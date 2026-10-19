
#association rule
library(arules)
library(stringr)



#asso groceries
grocery <- read.transactions('groceries.csv', sep=',')
dim(grocery)
fix(grocery)
inspect(grocery[size(grocery)==1])
inspect(grocery[size(grocery)==2])
inspect(grocery[size(grocery)<=10])
inspect(grocery[size(grocery)==32])


grocery[size(grocery)>10]

grocery.text <- readLines('groceries.csv')
sum(str_detect(grocery.text, "citrus fruit"))
sum(str_detect(grocery.text, "margarine"))
sum(str_detect(grocery.text, "citrus fruit") & str_detect(grocery.text, "margarine"))

#support 0.00793 or 0.793%
sum(str_detect(grocery.text, "citrus fruit") & str_detect(grocery.text, "margarine"))/9835
mean(str_detect(grocery.text, "citrus fruit") )

#confidence citrus fruit --> margarine 0.0958 or 9.58%
sum(str_detect(grocery.text, "citrus fruit") & str_detect(grocery.text, "margarine"))/sum(str_detect(grocery.text, "citrus fruit"))

#Lift 1.64
9835*sum(str_detect(grocery.text, "citrus fruit") & str_detect(grocery.text, "margarine"))/(sum(str_detect(grocery.text, "citrus fruit"))*sum(str_detect(grocery.text, "margarine")))


grocery.rules2 = apriori(grocery, parameter = list(minlen=2,maxlen=5,support = 0.001, confidence = 0.0))
ascus = inspect(head(sort(grocery.rules2, by = "lift",decreasing = F),20))
ascus = inspect(head(sort(grocery.rules2, by = "confidence",decreasing = TRUE),80))

grocery.rules = apriori(grocery, parameter = list(minlen=2,maxlen=10,support = 0.005, confidence = 0.3))


l = length(grocery.rules)

ascus = inspect(head(sort(grocery.rules, by = "confidence",decreasing = TRUE),30))

label(rhs(grocery.rules))



milk = 1:l
milk = milk[grocery.rules@rhs@itemInfo$labels[grocery.rules@rhs@data@i+1] =="whole milk" | grocery.rules@rhs@itemInfo$labels[grocery.rules@rhs@data@i+1] =="other vegetables"]


inspect(sort(grocery.rules[-milk],by = "confidence"))

inspect(head(sort(grocery.rules[milk], by = "confidence",decreasing = TRUE),100))
inspect(sort(grocery.rules[milk],by = "confidence"))


grocery.rules = apriori(grocery, parameter = list(minlen=2,maxlen=10,support = 0.001, confidence = 0.01))
l = length(grocery.rules)
beer = 1:l
beer = beer[grocery.rules@rhs@itemInfo$labels[grocery.rules@rhs@data@i+1] =="canned beer" | grocery.rules@rhs@itemInfo$labels[grocery.rules@rhs@data@i+1] =="bottled beer"]
inspect(head(sort(grocery.rules[beer], by = "confidence",decreasing = TRUE),100))


#MarketBaskets



#asso groceries
grocery = read.csv("marketbasket.csv",header=T,na.strings="?")
grocery$Chardonnay.Wine
grocery <- (grocery == 1)

dim(grocery)
fix(grocery)

rowSums(grocery)
max(rowSums(grocery))
grocery[which.max(rowSums(grocery)),]


sum(rowSums(grocery)>10)


grocery.rules2 = apriori(grocery, parameter = list(minlen=2,maxlen=5,support = 0.02, confidence = 0.3))
ascus = inspect(head(sort(grocery.rules2, by = "lift",decreasing = F),20))
ascus = inspect(head(sort(grocery.rules2, by = "confidence",decreasing = TRUE),80))

grocery.rules = apriori(grocery, parameter = list(minlen=2,maxlen=3,support = 0.01, confidence = 0.3))


l = length(grocery.rules)

ascus = inspect(head(sort(grocery.rules, by = "confidence",decreasing = TRUE),30))

labels(rhs(grocery.rules))


#remove too frequent items
milk = 1:l
milk = milk[grocery.rules@rhs@itemInfo$labels[grocery.rules@rhs@data@i+1] =="X2pct..Milk"]

milk = milk[grocery.rules@rhs@itemInfo$labels[grocery.rules@rhs@data@i+1] =="X2pct..Milk" | grocery.rules@rhs@itemInfo$labels[grocery.rules@rhs@data@i+1] =="White.Bread"| grocery.rules@rhs@itemInfo$labels[grocery.rules@rhs@data@i+1] =="Eggs" ]

inspect(head(sort(grocery.rules[-milk], by = "confidence",decreasing = TRUE),100))

inspect(head(sort(grocery.rules[milk], by = "confidence",decreasing = TRUE),100))
inspect(sort(grocery.rules[milk],by = "confidence"))

#specific item
grocery.rules = apriori(grocery, parameter = list(minlen=2,maxlen=5,support = 0.01, confidence = 0.01))
l = length(grocery.rules)
wine = 1:l
wine = wine[grocery.rules@rhs@itemInfo$labels[grocery.rules@rhs@data@i+1] =="Chardonnay.Wine" ]
inspect(head(sort(grocery.rules[wine], by = "confidence",decreasing = TRUE),100))


#Homework

cafe <- read.csv('bread+basket.csv', sep=',')
cafe_tran_item <- as.matrix(table(cafe$Transaction, cafe$Item))
cafe_period_item <- as.matrix(table(cafe$period_day, cafe$Item))
cafe_week_item <- as.matrix(table(cafe$weekday_weekend, cafe$Item))

cafe_tran_item <- (cafe_tran_item==1)
cafe_period_item <- (cafe_period_item==1)
cafe_week_item <- (cafe_week_item==1)

dim(grocery)
dim(cafe)




table(cafe$Transaction,cafe$Item) != 0
table(cafe$Transaction,cafe$period_day) != 0
table(cafe$Transaction,cafe$weekday_weekend) != 0

#Learn cafe datasets
#find interesting rules based on support, conf
# Analyze your selected rules
# Propose a marketing strategy based on your selected rules 

#Examples of rules
cafe_rules_1 <- apriori(cafe_tran_item, parameter = list(minlen=2,maxlen=10,support = 0.001, confidence = 0.001))
caf_rule <- apriori(cafe, parameter = list(minlen=2,maxlen=3,support = 0.001, confidence = 0.001))
cafe_rules_3 <- apriori(cafe_week_item, parameter = list(minlen=2,maxlen=10,support = 0.001, confidence = 0.001))

inspect(head(sort(cafe_rules), decreasing = TRUE,by = "confidence", 100))
inspect(head(sort(cafe_rules_1), decreasing = TRUE,by = "confidence", 100))


grocery.rules@rhs@itemInfo$labels[grocery.rules@rhs@data@i+1] =="Chardonnay.Wine"

tran <- 1:length(caf_rule)
tran <- tran[str_detect(caf_rule@rhs@itemInfo$labels[caf_rule@rhs@data@i+1] ,"Transaction")]

inspect(head(sort(caf_rule[-tran]), decreasing = TRUE,by = "confidence", 100))

rowsums(cafe_table)

grocery.rules2 = apriori(grocery, parameter = list(minlen=1,maxlen=5,support = 0.02, confidence = 0.3))
#morning+coffee >>> bakery6
#weekend+afternoon+bakery9 >>> hot chocolate

