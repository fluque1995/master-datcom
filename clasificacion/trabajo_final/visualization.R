library(tibble)

library(dplyr)

dataset <- read.csv("dataset/train_set.csv", header = T, na.strings= c(".", "NA", "", "?"))

dataset <- tibble::as_tibble(dataset)

## Tamaño del dataset
dim(dataset)

## Primeras filas del conjunto
head(dataset)


## Nombre de las variables
names(dataset)

## Lectura de las etiquetas
labels <- read.csv("dataset/train_labels.csv", header=T)

dataset <- dataset %>% left_join(labels, by="id")


## Información sobre el conjunto de datos
summary(dataset)

summary(dataset$id)

str(dataset$id)


## Exploración del conjunto de datos
library(Hmisc)

Hmisc::describe(dataset$id)
Hmisc::describe(dataset$amount_tsh)
Hmisc::describe(dataset$date_recorded)
Hmisc::describe(dataset$funder)

## Contamos el número de instancias con datos perdidos
system.time(
    res1 <- apply(dataset, 1, function(x) sum(is.na(x))/ncol(dataset)*100)
)

## Uso de paralelismo

## cores <- parallel::detectCores()

## cluster <- parallel::makeCluster(cores/2)

## system.time(
##     res2 <- parallel::parRapply(
##                          dataset, 1, function(x) sum(is.na(x))/ncol(dataset)*100
##                      )
## )

## parallel::stopCluster(cluster)

## Tratamiento de valores perdidos
library(mice)

## Detección de patrones dentro de los valores perdidos
pattern <- mice::md.pattern(dataset[,20:25])

complete.instances <- mice::ncc(dataset)
incomplete.instances <- mice::nic(dataset)
complete.instances
incomplete.instances

## Escogemos un conjunto de datos más sencillo, debido al gran tamaño
## que tiene el que estábamos usando

dataset2 <- airquality

pattern <- mice::md.pattern(dataset2)

imputed.information <- mice::mice(dataset2, m=5, method = "pmm")

imputed.dataset <- mice::complete(imputed.information)

mice::ncc(imputed.dataset)
dim(imputed.dataset)

## Inspección de los valores imputados gráficamente
lattice::densityplot(imputed.information)
lattice::bwplot(imputed.information)

## Otra librería de tratamiento de datos perdidos
library(VIM)
plot <- VIM::aggr(dataset)

## Tratamiento de datos anómalos
numeric.data <- dplyr::select_if(dataset, is.numeric)

library(outliers)

pop.outlier <- outliers::outlier(dataset$population)

## Transformación de datos usando caret
library(caret)

transformation <- caret::preProcess(
                            imputed.dataset[,1:4],
                            method = c("center", "scale")
                        )

transformed.data <- predict(transformation, imputed.dataset[,1:4])

## Discretización de variables
library(discretization)

rAmeva <- discretization::disc.Topdown(imputed.dataset[,1:4], method = 1)

## Selección de características
library(FSelector)

info.gain <- FSelector::information.gain(status_group ~ ., dataset)
subset <- FSelector::cutoff.k(info.gain, 5)

## Funcion de evaluacion
fEvaluacion <- function(subset){
    print(subset)
    k<-2
    splits<-runif(nrow(iris))

    results<-sapply(1:k, function(i){
        test.idx <- (splits >= ((i-1)/k) & (splits<(i/k)))
        train.idx <- !test.idx

                                        #Seleccion de instancias
        test <- iris[test.idx, ,drop=FALSE]
        train <- iris[train.idx, ,drop=FALSE]

        tree <- rpart::rpart(as.simple.formula(subset, "Species"),train.idx)

        error.rate<-sum(test$Species != predict(tree, est, type="class"))/nrow(test)

        return()
    })
}

subset <- FSelector::best.first.search(names(iris)[-5], fEvaluacion)
