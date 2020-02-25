### LABORATORIO DE CLASIFICACIÓN MONOTÓNICA
### Cargamos las librerías necesarias
library(RWeka)
library(xgboost)
library(caret)
set.seed(0)

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
    if (is.null(class.min)) {
        class.min = min(train.set[,class.col])
    }
    if (is.null(class.max)) {
        class.max = max(train.set[,class.col])
    }

    ## Se transforma la columna objetivo en función de los valores
    ## de la clase
    lapply(class.min:(class.max - 1), function (x){
        train.set[,class.col] <- ifelse(train.set[,class.col] > x, 1, 0)
        train.set
    })
}

## Wrapper para entrenamiento del modelo
build.model <- function(dataset, class.name = "Class"){
    labels <- dataset[,class.name]
    data <- dataset[,!(names(dataset) == class.name)]

    ## Se entrena un modelo de xgboost con restricciones monotónicas
    xgboost(data=as.matrix(data), label=labels, nrounds=5,
            monotone_constraints=1)
}

predict.test <- function(test.set, models){

    #' Predicción del conjunto de test a partir de los modelos calculados
    #'
    #' @param test.set Conjunto de test a predecir
    #' @param models Lista de modelos a utilizar para la predicción
    #'
    #' @return Clase para cada elemento del conjunto

    ## Se calculan las predicciones para el conjunto de test con todos
    ## los modelos
    predictions <- lapply(models, function(x) predict(x, as.matrix(test.set)))

    ## La lista de valores se convierte a una matriz
    predictions.mat <- matrix(unlist(predictions), ncol=length(predictions))

    ## Las predicciones se convierten de regresión a clasificación binaria
    rounded.preds <- predictions.mat > 0.5

    ## Se suman por filas las predicciones para calcular la etiqueta final
    apply(rounded.preds, 1, sum)
}


predict.monotonic <- function(train.data, test.data, class.col = "Class",
                              class.min = NULL, class.max = NULL){
    #' Wrapper para el pipeline previo
    #'
    #' Función que permite aplicar todas las funciones anteriores
    #' de forma ordenada automáticamente dado un modelo, un conjunto
    #' de entrenamiento y un conjunto de test
    #'
    #' @param train.set Conjunto de entrenamiento
    #' @param train.set Conjunto de test
    #' @param class.col Nombre de la columna a predecir
    #' @param class.min Valor mínimo para la columna de clase
    #' @param class.max Valor máximo para la columna de clase
    #'
    #' @return Clases calculadas para cada ejemplo del test
    train.sets <- build.datasets(train.data, class.col, class.min, class.max)

    models <- lapply(train.sets, build.model, class.name=class.col)

    predict.test(test.data, models)
}

datasets.list <- c("era.arff", "esl.arff", "lev.arff", "swd.arff")

conf.matrices <- lapply(datasets.list, function (x) {
    ## Selección del conjunto de datos
    dataset <- read.arff(x)

    ## Generación del vector de índices para el test
    test.idx <- sample(1:nrow(dataset), 100)

    ## Separación entre train y test
    train.data <- dataset[-test.idx,]
    test.data <- dataset[test.idx,]

    ## Nombre de la columna que se quiere predecir
    ## (por defecto, se toma la última columna del conjunto)
    class.col <- colnames(dataset)[length(dataset)]

    ## Ejemplo de ejecución
    test.labels <- test.data[,class.col]
    test.data[class.col] <- NULL

    predictions <- predict.monotonic(train.data, test.data, class.col=class.col)

    ## Para obtener la clase, es suficiente con buscar el índice máximo de cada
    ## fila
    min.class <- min(train.data[,class.col])

    predictions <- predictions + min.class

    ## Ahora, podemos construir la matriz de confusión del modelo
    real.labels <- as.factor(test.labels)
    predicted.labels <- factor(predictions, levels=levels(real.labels))
    confusionMatrix(predicted.labels, real.labels)[c("table", "overall")]
})

conf.matrices
