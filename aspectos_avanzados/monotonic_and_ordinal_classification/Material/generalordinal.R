### LABORATORIO DE CLASIFICACIÓN ORDINAL

library(RWeka)
set.seed(0)

dataset <- read.arff("esl.arff")

dataset$out1 <- as.factor(dataset$out1)

test.idx <- sample(1:nrow(dataset), 100)

train.data <- dataset[-test.idx,]
test.data <- dataset[test.idx,]

classes <- sort(unique(as.numeric(dataset$out1)))

predict.lesesr <- function(value, train, test){

}
