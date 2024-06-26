library(readr)
library(tree)
library(class)
library(MLmetrics)
library(ggplot2)
library(RSNNS)

dados <- read.csv("C:\\Users\\pedro\\OneDrive\\Documentos\\Inteligencia Artificial\\analiseDeDados3\\projeto3\\winequality-whiteAndRed.csv",stringsAsFactors = FALSE)

summary(dados$quality)

#Remover dados duplicados
dados <- unique(dados)

#Remover dados com valores null
dados <- na.omit(dados)

dados <- dados[complete.cases(dados), ]

#Ajustando cada atributo

dados$fixed.acidity <- as.numeric(dados$fixed.acidity)
dados <- dados[dados$fixed.acidity >= 0 & dados$fixed.acidity <= 10, ]

dados$volatile.acidity <- as.numeric(dados$volatile.acidity)
dados <- dados[dados$volatile.acidity >= 0 & dados$volatile.acidity <= 1, ]

dados$citric.acid <- as.numeric(dados$citric.acid)
dados <- dados[dados$citric.acid >= 0 & dados$citric.acid <= 1, ]

dados$residual.sugar <- as.numeric(dados$residual.sugar)
dados <- dados[dados$residual.sugar >= 1 & dados$residual.sugar <= 15, ]

dados$chlorides <- as.numeric(dados$chlorides)
dados <- dados[dados$chlorides >= 20 & dados$chlorides <= 100, ]

dados$free.sulfur.dioxide <- as.numeric(dados$free.sulfur.dioxide)
dados <- dados[dados$free.sulfur.dioxide >= 10 & dados$free.sulfur.dioxide <= 80, ]

dados$total.sulfur.dioxide <- as.numeric(dados$total.sulfur.dioxide)
dados <- dados[dados$total.sulfur.dioxide >= 80 & dados$total.sulfur.dioxide <= 230, ]

dados$density <- as.numeric(dados$density)
dados <- dados[dados$density >= 9 & dados$density <= 10, ]

dados$pH <- as.numeric(dados$pH)
dados <- dados[dados$pH >= 2 & dados$pH <= 4, ]

dados$sulphates <- as.numeric(dados$sulphates)
dados <- dados[dados$sulphates >= 0 & dados$sulphates <= 1, ]

dados$alcohol <- as.numeric(dados$alcohol)
dados <- dados[dados$alcohol >= 8 & dados$alcohol <= 14, ]

#Separando os conjuntos

set.seed(123)
prop_test <- 0.3
num_observacoes <- nrow(dados)
num_teste <- round(prop_test * num_observacoes)
indices_teste <- sample(1:num_observacoes, num_teste)
test <- dados[indices_teste, ]
train <- dados[-indices_teste, ]

#Observando o balanceamento

plot(test$quality)
plot(train$quality)

# Converter a variável de saída para 0 ou 1
train$classe <- ifelse(train$quality >= 6, 1, 0)
test$classe <- ifelse(test$quality >= 6, 1, 0)
train <- subset(train, select = -quality)
test <- subset(test, select = -quality)

#Apagando os dados NA da base

test <- na.omit(test)
train <- na.omit(train)

targetTrain <- train$classe
train$classe <- NULL
targetTest <- test$classe
test$classe <- NULL


############################
## KNN
############################

limiar <- 3

x <- data.frame (train, y = as.factor(targetTrain))
model <- class::knn(train = train, test = test, cl = targetTrain, k = 3)
predsVal <- as.numeric(as.character(model))
predVal <- ifelse(predsVal > limiar, 1, 0)

vn <- sum((targetTest == 1) & (predVal == 1))
fn <- sum((targetTest == 0) & (predVal == 1))
vp <- sum((targetTest == 0) & (predVal == 0))
fp <- sum((targetTest == 1) & (predVal == 0))
confusionMat <- matrix(c(vp, fp, fn, vn), nrow = 2, ncol = 2, dimnames = list(c("1","0"), c("1", "0")))

print(vp)
print(fp)
print(vn)
print(fn)
confusionMat
#Classe majoritaria

count_0 <- sum(predVal == 0)
count_1 <- sum(predVal == 1)
classe_majoritaria <- ifelse(count_0 > count_1, 0, 1)
print( classe_majoritaria)


# Erro tipo 1
TFP = (fp/(vn+fp))
print(TFP)

Precisao = (vp/(vp+fp))
print(Precisao)

Acuracia = (vp+vn/(vp+vn+fp+fn))
print(Acuracia)

Recall = (vp/(vp+fn))
print(Recall)

############################
## DECISION TREE
############################


model <- tree(targetTrain ~ ., train)
predsVal <- predict(model, test)
predVal <- ifelse (predsVal > 0.5, 1, 0)
print(predVal)

vn <- sum((targetTest == 1) & (predVal == 1))
fn <- sum((targetTest == 0) & (predVal == 1))
vp <- sum((targetTest == 0) & (predVal == 0))
fp <- sum((targetTest == 1) & (predVal == 0))
confusionMat <- matrix(c(vp, fp, fn, vn), nrow = 2, ncol = 2, dimnames = list(c("0","1"), c("0","1")))

print(vp)
print(fp)
print(vn)
print(fn)
confusionMat

#Classe majoritaria

count_0 <- sum(predVal == 0)
count_1 <- sum(predVal == 1)
classe_majoritaria <- ifelse(count_0 > count_1, 0, 1)
print( classe_majoritaria)

#Erro tipo 1
TFP = (fp/(vn+fp))
print(TFP)

Precisao = (vp/(vp+fn))
print(Precisao)

Acuracia = (vp+vn/(vp+vn+fp+fn))
print(Acuracia)

Recall = (vp/(vp+fn))
print(Recall)



############################
## MLP
############################


model <- mlp(	x = train,
              y = targetTrain,
              size = 5,
              learnFuncParams = c(0.1),
              maxit = 100,
              inputsTest = test,
              targetsTest = targetTest)
predsVal <- predict(model,test)
predVal <- ifelse (predsVal > 0.5, 1, 0)
print(predVal)

vn <- sum((targetTest == 1) & (predVal == 1))
fn <- sum((targetTest == 0) & (predVal == 1))
vp <- sum((targetTest == 0) & (predVal == 0))
fp <- sum((targetTest == 1) & (predVal == 0))
confusionMat <- matrix(c(vp, fp, fn, vn), nrow = 2, ncol = 2, dimnames = list(c("0","1"), c("0","1")))

print(vp)
print(fp)
print(vn)
print(fn)
confusionMat
#Classe majoritaria

count_0 <- sum(predVal == 0)
count_1 <- sum(predVal == 1)
classe_majoritaria <- ifelse(count_0 > count_1, 0, 1)
print( classe_majoritaria)

#Erro tipo 1
TFP = (fp/(vn+fp))
print(TFP)

Precisao = (vp/(vp+fn))
print(Precisao)

Acuracia = (vp+vn/(vp+vn+fp+fn))
print(Acuracia)

Recall = (vp/(vp+fn))
print(Recall)


