### LABORATORIO DE CLASIFICACIÓN ORDINAL
### Cargamos las librerías necesarias
library(RWeka)
library(caret)
set.seed(0)

## Selección del conjunto de datos
dataset <- read.arff("esl.arff")

## Generación del vector de índices para el test
test.idx <- sample(1:nrow(dataset), 100)

## Separación entre train y test
train.data <- dataset[-test.idx,]
test.data <- dataset[test.idx,]

## Nombre de la columna que se quiere predecir
## (por defecto, se toma la última columna del conjunto)
class.col <- colnames(dataset)[length(dataset)]

build.datasets <- function(train.set, class.col = "Class",
                           class.min = NULL, class.max = NULL){

    #' Construcción de los conjuntos de datos
    #'
    #' @param train.set Conjunto de datos a particionar
    #' @param class.col Nombre de la columna que se considera clase
    #' @param class.min Valor mínimo para la clase
    #' @param class.max Valor máximo para la clase
    #'
    #' @return Lista con los conjuntos de datos reetiquetados para
    #' clasificación ordinal

    ## Si los valores máximo y mínimo no se especifican, se calculan
    if (missing(class.min)) {
        class.min = min(train.set[,class.col])
    }
    if (missing(class.max)) {
        class.max = max(train.set[,class.col])
    }

    ## Se transforma la columna objetivo en función de los valores
    ## de la clase
    lapply(class.min:(class.max - 1), function (x){
        train.set[,class.col] <- as.factor(
            ifelse(train.set[,class.col] > x, 1, 0)
        )
        train.set
    })
}

## Wrapper para entrenamiento del modelo
build.model <- function(dataset, model, class.name = "Class"){
    train(as.formula(paste(class.name, "~ .")), dataset, method=model, )
}

predict.test <- function(test.set, models){

    #' Predicción del conjunto de test a partir de los modelos calculados
    #'
    #' @param test.set Conjunto de test a predecir
    #' @param models Lista de modelos a utilizar para la predicción
    #'
    #' @return Probabilidades obtenidas por los modelos para cada una de
    #' las clases

    ## Se calculan las predicciones para el conjunto de test con todos
    ## los modelos, y se conserva la probabilidad de la clase 1 (probabilidad
    ## de que la etiqueta de dicho ejemplo sea mayor que la etiqueta límite
    ## para ese clasificador)
    predictions <- lapply(models, function(x)
        predict(x, test.set, type = "prob")[, "1"]
        )

    ## Se ajustan las probabilidades para todas las clases, como probabilidad
    ## condicionada utilizando la predicción por el modelo anterior
    probs <- sapply(1:length(predictions), function(x){
        if(x == 1){
            1 - predictions[[x]]
        } else {
            predictions[[x-1]] * (1 - predictions[[x]])
        }
    }, simplify=TRUE)

    ## Se adjunta la probabilidad del último modelo
    probs <- cbind(probs, predictions[[length(predictions)]])
}


predict.ordinal <- function(train.set, test.set, model, class.col = "Class",
                            class.min = NULL, class.max = NULL){

    #' Wrapper para el pipeline previo
    #'
    #' Función que permite aplicar todas las funciones anteriores
    #' de forma ordenada automáticamente dado un modelo, un conjunto
    #' de entrenamiento y un conjunto de test
    #'
    #' @param train.set Conjunto de entrenamiento
    #' @param train.set Conjunto de entrenamiento
    #' @param model Modelo de aprendizaje utilizado
    #' @param class.col Nombre de la columna a predecir
    #' @param class.min Valor mínimo para la columna de clase
    #' @param class.max Valor máximo para la columna de clase
    #'
    #' @return Matriz de probabilidades para el conjunto de test.

    train.sets <- build.datasets(train.set, class.col = class.col,
                                 class.min, class.max)
    models <- lapply(train.sets, build.model, model = model,
                     class.name=class.col)

    predict.test(test.set, models)
}

## Utilización del pipeline previo para obtener la matriz de probabilidades
predictions.prob <- predict.ordinal(train.data, test.data,
                                    "J48", class.col=class.col)

## Para obtener la clase, es suficiente con buscar el índice máximo de cada
## fila
predictions.class <- apply(predictions.prob, 1, which.max)

## Ahora, podemos construir la matriz de confusión del modelo
table(test.data[,class.col], predictions.class)
