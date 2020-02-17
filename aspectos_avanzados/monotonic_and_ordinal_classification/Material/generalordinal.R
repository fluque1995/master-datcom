### LABORATORIO DE CLASIFICACIÓN ORDINAL

library(RWeka)
set.seed(0)

dataset <- read.arff("esl.arff")

dataset$out1 <- as.factor(dataset$out1)

test.idx <- sample(1:nrow(dataset), 100)

train.data <- dataset[-test.idx,]
test.data <- dataset[test.idx,]

classes <- sort(unique(as.numeric(dataset$out1)))

predict.lesser <- function(value, train, test){
    train.mod <- train
    test.mod <- test
    train.mod$out1 <- factor(ifelse(as.numeric(train.mod$out1) > value, 0, 1))
    test.mod$out1 <- factor(ifelse(as.numeric(test.mod$out1) > value, 0, 1))

    tree <- J48(out1 ~ ., data=train.mod)

    predict(tree, test.mod, "probability")
}
