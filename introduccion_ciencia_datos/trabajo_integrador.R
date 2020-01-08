## TRABAJO INTEGRADOR
## Francisco Luque Sánchez
## Configuración inicial e imports
set.seed(0)
library(knitr)
library(kableExtra)
library(fBasics)
library(ggplot2)
library(gridExtra)
library(GGally)
library(dplyr)
library(texreg)
library(kknn)
library(caret)
library(class)
library(corrplot)
library(MASS)


## ANÁLISIS EXPLORATORIO DE DATOS
## Carga del dataset de regresión
dataset <- read.csv('forestFires/forestFires.dat', comment.char = "@", header = FALSE)
cols <- c("X", "Y", "Month", "Day", "FFMC", "DMC", "DC", "ISI", "Temp", "RH", "Wind", "Rain", "Area")
colnames(dataset) <- cols

# La función kable de la librería knitr nos permite generar directamente tablas en formato LaTeX, para su correcta visualizacion
kable(head(dataset), booktabs=T, caption="Ejemplo de algunas instancias del conjunto de datos") %>% kable_styling(position="center", latex_options = "hold_position")


# Consulta de las dimensiones del dataset (<nº ejemplos> x <nº atributos>)
dim(dataset)


# Extraemos la misma información que la función summary, pero usando una función del paquete fBasics que nos permite mostrar esta información como una tabla
stats <- basicStats(dataset)[c('Minimum', '1. Quartile', 'Median', 'Mean', 'Stdev', '3. Quartile', 'Maximum', 'Skewness', 'Kurtosis'),]
kable(stats[,1:7], digits = 2, booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")
kable(stats[,8:13], digits = 2, booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")


# Esta función recibe como parámetro el nombre de una columna del dataset y crea el diagrama de barras asociado a dicha columna. Lo utilizaremos junto con el vector de nombres de columnas para generar los gráficos
plot.bars <- function(colname) {
  ggplot(dataset, aes_string(x = colname)) + geom_bar(stat = "count")
}
barplots <- lapply(cols[1:4], plot.bars)
# La función do.call nos permite pasar una lista de elementos (en este caso plots), como argumentos independientes
do.call(grid.arrange, c(barplots, ncol=4))


# Al igual que en el ejemplo anterior, pero utilizando ahora histogramas. Para cada histograma, se agrupan los datos en 20 intervalos de igual amplitud
plot.hist <- function(colname) {
  ggplot(dataset, aes_string(x = colname)) + geom_histogram(breaks=seq(
    min(dataset[,colname]),
    max(dataset[,colname]),
    length.out = 20))
}
histograms <- lapply(cols[5:7], plot.hist)
do.call(grid.arrange, c(histograms, ncol=3))


histograms <- lapply(cols[8:10], plot.hist)
do.call(grid.arrange, c(histograms, ncol=3))


histograms <- lapply(cols[11:13], plot.hist)
do.call(grid.arrange, c(histograms, ncol=3))


## Gráficos por pares de variables
ggpairs(dataset, aes(colour=), axisLabels = 'none', 
        upper = list(continuous = wrap("cor", size = 2)),
        lower = list(continuous = wrap("points", alpha = 0.3, colour = "#5555FF", size = 0.3)))


## Gráficos QQ
qqplotline <- function(colname){
  qqnorm(dataset[,colname], main = paste("Q-Q plot - ", colname))
  qqline(dataset[,colname])
}
par(mfrow=c(1,3)); foo <- lapply(cols[5:7], qqplotline)
par(mfrow=c(1,3)); foo <- lapply(cols[8:10], qqplotline)
par(mfrow=c(1,3)); foo <- lapply(cols[11:13], qqplotline)


## Test de Shapiro Wilk para las variables contiunas
# Extracción del valor del estadístico y los p-valores para cada columna
statistics <- simplify2array(lapply(cols[-(1:4)], function (x) shapiro.test(dataset[, x])[['statistic']]))
pvals <- simplify2array(lapply(cols[-(1:4)], function (x) shapiro.test(dataset[, x])[['p.value']]))
# Creación de un dataframe con dicha información, conversión de los valores a cadenas de texto para el display y nombrado de filas y columnas
tests.mat <- data.frame(rbind(statistics, pvals))
tests.mat <- tests.mat %>% dplyr::mutate_if(., is.numeric, ~ as.character(signif(., 3)))
colnames(tests.mat) <- cols[-(1:4)]
rownames(tests.mat) <- c("W", "p-val")
# Impresión de la tabla
kable(tests.mat, caption="Tests de Shapiro-Wilk para las variables continuas", booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")


## Carga del dataset de clasificación
dataset <- read.csv('heart/heart.dat', comment.char = '@', header = F)
cols <- c('Age', 'Sex', 'ChestPainType', 'RestBloodPressure', 'SerumCholestoral', 'FastingBloodSugar', 'ResElectrocardiographic', 'MaxHeartRate', 'ExerciseInduced', 'Oldpeak', 'Slope', 'MajorVessels', 'Thal', 'Class')
colnames(dataset) <- cols
dataset$Class = as.factor(dataset$Class)


## Dimensiones del dataset
dim(dataset)


##Distribución de clases en el conjunto de datos
table(dataset$Class)


## Estadísticas básicas de las variables continuas
stats <- basicStats(dataset[,c(1,4,5,8,10)])[c('Minimum', '1. Quartile', 'Median', 'Mean', 'Stdev', '3. Quartile', 'Maximum', 'Skewness', 'Kurtosis'),]
kable(stats, digits = 2, , booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")


## Histogramas para las variables continuas
# Utilizamos la función implementada en la sección anterior
histograms <- lapply(cols[c(1,4,5,8,10)], plot.hist)
do.call(grid.arrange, c(histograms, ncol=3))


## Diagramas de barras para las columnas nominales
# Modificamos la función plot.bars para que nos permita colorear las barras en función de la proporción de elementos de cada clase
plot.bars <- function(colname) {
  ggplot(dataset, aes_string(x = colname, fill="Class")) + geom_bar(position="stack") + theme(legend.title = element_text(size=8), legend.key.size = unit(.5, "cm"), axis.title.y = element_text("", size=0))
}
barplots <- lapply(cols[c(2,6,9)], plot.bars)
do.call(grid.arrange, c(barplots, ncol=3))
barplots <- lapply(cols[c(3,7,11,12,13)], plot.bars)
do.call(grid.arrange, c(barplots, ncol=3))

## Gráficos por pares de variables para las variables continuas
ggpairs(dataset[c(1,4,5,8,10,14)], aes(colour=Class),
        upper = list(continuous = wrap("cor", size = 3)),
        lower = list(continuous = wrap("points", alpha = 0.5, size = 0.3), combo = wrap("facethist", binwidth=10)))


## Test de Shapiro Wilk para las variables continuas
# Extracción del valor del estadístico y los p-valores para cada columna
statistics <- simplify2array(lapply(cols[c(1,4,5,8,10)], function (x) shapiro.test(dataset[, x])[['statistic']]))
pvals <- simplify2array(lapply(cols[c(1,4,5,8,10)], function (x) shapiro.test(dataset[, x])[['p.value']]))
# Creación de un dataframe con dicha información, conversión de los valores a cadenas de texto para el display y nombrado de filas y columnas
tests.mat <- data.frame(rbind(statistics, pvals))
tests.mat <- tests.mat %>% dplyr::mutate_if(., is.numeric, ~ as.character(signif(., 3)))
colnames(tests.mat) <- cols[c(1,4,5,8,10)]
rownames(tests.mat) <- c("W", "p-val")
# Impresión de la tabla
kable(tests.mat, caption="Tests de Shapiro-Wilk para las variables continuas", , booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")


## Gráficos QQ
par(mfrow=c(2,3)); foo <- lapply(cols[c(1,4,5,8,10)], qqplotline)


## PROBLEMA DE REGRESIÓN
dataset <- read.csv('forestFires/forestFires.dat', comment.char = "@", header = FALSE)
cols <- c("X", "Y", "Month", "Day", "FFMC", "DMC", "DC", "ISI", "Temp", "RH", "Wind", "Rain", "Area")
colnames(dataset) <- cols


## Gráficos de puntos de todas las variables frente a la variable a estimar, para encontrar relaciones lineales
plot.regr <- function(colname){
  plot(dataset[,'Area']~dataset[,colname], main=colname, ylab="Area")
}
par(mfrow=c(3,4), mar=c(2,2,2,2))
foo <- lapply(cols[1:12], plot.regr)


# Calculamos la correlación de todas las columnas del dataset con la columna Area. Tenemos que transponer el resultado antes de imprimir la tabla para obtener una matriz por filas en lugar de por columnas
kable(t(apply(dataset[,-(13)], 2, cor, y=dataset$Area)), caption = "Coeficientes de correlación de Pearson de todas las variables frente a la columna a predecir", digits = 3, booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")


## Regresiones lineales simples para las cinco variables más correladas
simple.lm <- function(col){
  lm(as.formula(paste("Area", col, sep = "~")),
     data=dataset)
}
best.vars <- c("Temp", "RH", "DMC", "X", "Month")
fits <- sapply(best.vars, simple.lm, simplify = F, USE.NAMES = T)
lapply(fits, summary)


## Gráficos con las rectas de regresión calculadas
par(mfrow=c(2,3))
graphs <- lapply(best.vars, function (x) ggplot(dataset, aes_string(x = x, y = 'Area')) + geom_point() + stat_smooth(method='lm') + theme_light())
do.call(grid.arrange, c(graphs, ncol=3))


## Regresión lineal con todas las variables
complete.fit <- lm(Area ~ ., data=dataset)
summary(complete.fit)


## Vamos eliminando las variables menos explicativas del ajuste
partial.fit1 <- lm(Area ~ . - FFMC, data=dataset)
summary(partial.fit1)

partial.fit2 <- lm(Area ~ . - FFMC - Y, data=dataset)
summary(partial.fit2)

partial.fit3 <- lm(Area ~ . - FFMC - Y - Rain, data=dataset)
summary(partial.fit3)

partial.fit4 <- lm(Area ~ . - FFMC - Y - Rain - Day, data=dataset)
summary(partial.fit4)

partial.fit5 <- lm(Area ~ . - FFMC - Y - Rain - Day - Wind, data=dataset)
summary(partial.fit5)

partial.fit6 <- lm(Area ~ . - FFMC - Y - Rain - Day - Wind - RH, data=dataset)
summary(partial.fit6)

partial.fit7 <- lm(Area ~ . - FFMC - Y - Rain - Day - Wind - RH - ISI - DMC - DC - Month, data=dataset)
summary(partial.fit7)

## Transformaciones no lineales de las variables
nonlinear.fit1 <- lm(Area ~ I(Temp^2) + X, data=dataset)
summary(nonlinear.fit1)

nonlinear.fit2 <- lm(Area ~ Temp + I(Temp^2) + X, data=dataset)
summary(nonlinear.fit2)

## Transformación de la columna temporal de los meses para mantener la información cíclica
temporal.fit1 <- lm(Area ~ I(Temp^2) + X + Month, data=dataset)
summary(temporal.fit1)

temporal.fit2 <- lm(Area ~ I(Temp^2) + X + cos(pi*Month/6) + sin(pi*Month/6), data=dataset)
summary(temporal.fit2)

temporal.fit2 <- lm(Area ~ I(Temp^2) + X + cos(pi*Month/6), data=dataset)
summary(temporal.fit2)

## Regresión usando kNN
knn.fit1 <- kknn(Area ~ ., dataset, dataset)

plot(Area ~ Temp, data=dataset)
points(dataset$Temp, knn.fit1$fitted.values, col="red", pch=20)


## Cálculo del ECM cometido
RMSE <- function(reals, preds){
  sqrt(sum((reals - preds)^2)/length(reals))
}
RMSE(dataset$Area, knn.fit1$fitted.values)


knn.fit2 <- kknn(Area ~ Temp + X, dataset, dataset)
RMSE(dataset$Area, knn.fit2$fitted.values)

knn.fit3 <- kknn(Area ~ . - Month - Day - X - Y, dataset, dataset)
RMSE(dataset$Area, knn.fit3$fitted.values)

knn.fit4 <- kknn(Area ~ Temp + RH + Wind + Rain, dataset, dataset)
RMSE(dataset$Area, knn.fit4$fitted.values)

## Adición de columna de índices automatizada
check.index.knn <- function(var){
  formula = paste("Area~Temp+RH+Wind+Rain", var, sep="+")
  fit <- kknn(as.formula(formula), dataset, dataset)
  RMSE(dataset$Area, fit$fitted.values)
}

sapply(c("FFMC", "DMC", "DC", "ISI"), check.index.knn, USE.NAMES=T)

## Seleccionamos el mejor de los modelos
knn.fit5 <- kknn(Area ~ Temp + RH + Wind + Rain + FFMC, dataset, dataset)
RMSE(dataset$Area, knn.fit5$fitted.values)

## Interacciones entre variables
knn.fit6 <- kknn(Area ~ Temp + Wind + Rain + RH + 
                   Temp*Wind + Temp*Rain + Temp*RH +
                   Wind*Rain + Wind*RH + Rain*RH, dataset, dataset)
RMSE(dataset$Area, knn.fit6$fitted.values)

## Gráficos de los tres ajustes seleccionados
par(mfrow=c(1,3))
plot(Area ~ Temp, data=dataset)
points(dataset$Temp, knn.fit1$fitted.values, col="red", pch=20)
plot(Area ~ Temp, data=dataset)
points(dataset$Temp, knn.fit5$fitted.values, col="green", pch=20)
plot(Area ~ Temp, data=dataset)
points(dataset$Temp, knn.fit6$fitted.values, col="blue", pch=20)

## Cross-validation
load.folds <- function(dataset.name, num.folds, colnames.vec){
  train.filenames <- sapply(1:num.folds, function(x) paste(dataset.name, "/", dataset.name, "-", num.folds, "-", x, "tra.dat", sep = ""))
  test.filenames <- sapply(1:num.folds, function(x) paste(dataset.name, "/", dataset.name, "-", num.folds, "-", x, "tst.dat", sep = ""))
  train.folds <- lapply(train.filenames, read.csv, comment.char="@", header=F, col.names=colnames.vec)
  test.folds <- lapply(test.filenames, read.csv, comment.char="@", header=F, col.names=colnames.vec)
  
  mapply(function(x,y) list(train=x, test=y), train.folds, test.folds, SIMPLIFY = F)
}

## Carga de los folds
folds <- load.folds("forestFires", 5, cols)

## Dimensiones de los conjuntos de train y test
dim(folds[[1]]$train)
dim(folds[[1]]$test)

## Clasificación de un subconjunto usando modelos lineales
classify.lm <- function(fold, form, set = 'test'){
  train.set <- fold$train

  # Aunque por defecto se evalúe sobre test, se permite la evaluación sobre train
  if (set == "test"){
    test.set <- fold$test
  } else if (set == "train"){
    test.set <- fold$train
  }
  model <- lm(form, train.set)
  res <- predict(model, test.set)
  RMSE(res, test.set$Area)
}

## Aplicación sobre los cinco subconjuntos
rmse.simple.lm.test <- sapply(folds, classify.lm, form = Area ~ Temp)
rmse.simple.lm.train <- sapply(folds, classify.lm, form = Area ~ Temp, set = "train")
kable(rbind(test = rmse.simple.lm.test, train = rmse.simple.lm.train), caption = "RMSE cometido por el modelo lineal sobre los conjunos de entrenamiento y test", booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")

rmse.bivariate.lm.test <- sapply(folds, classify.lm, form = Area ~ Temp + X)
rmse.bivariate.lm.train <- sapply(folds, classify.lm, form = Area ~ Temp + X, set = "train")
rmse.nonlinear.test <- sapply(folds, classify.lm, form = Area ~ I(Temp^2) + X + cos(pi*Month/6)) 
rmse.nonlinear.train <- sapply(folds, classify.lm, form = Area ~ I(Temp^2) + X + cos(pi*Month/6), set = "train") 

## Clasificación de un subconjunto usando kNN
classify.knn <- function(fold, form, set = "test"){
  train.set <- fold$train
  
  # Aunque por defecto se evalúe sobre test, se permite la evaluación sobre train
  if (set == "test"){
    test.set <- fold$test
  } else if (set == "train"){
    test.set <- fold$train
  }
  res <- kknn(form, train.set, test.set)
  RMSE(res$fitted.values, test.set$Area)
}

## Aplicación sobre los cinco subconjuntos
rmse.basic.knn.test <- sapply(folds, classify.knn, Area ~ Temp + RH + Wind + Rain + FFMC)
rmse.basic.knn.train <- sapply(folds, classify.knn, Area ~ Temp + RH + Wind + Rain + FFMC, set = "train")

rmse.interaction.knn.test <- sapply(folds, classify.knn, Area ~ Temp + RH + Wind + Rain + FFMC + Temp*Wind + Temp*Rain + Temp*RH + Wind*Rain + Wind*RH + Rain*RH)
rmse.interaction.knn.train <- sapply(folds, classify.knn, Area ~ Temp + RH + Wind + Rain + FFMC + Temp*Wind + Temp*Rain + Temp*RH + Wind*Rain + Wind*RH + Rain*RH, set = "train")


## Tablas de resultados obtenidos
rmse.matrix <- rbind(
  simple=rmse.simple.lm.test, 
  bivariado=rmse.bivariate.lm.test,
  "no lineal"=rmse.nonlinear.test, 
  "knn simple"=rmse.basic.knn.test, 
  "interacciones"=rmse.interaction.knn.test,
  simple=rmse.simple.lm.train,
  bivariado=rmse.bivariate.lm.train,
  "no lineal"=rmse.nonlinear.train,
  "knn simple"=rmse.basic.knn.train,
  interacciones=rmse.interaction.knn.train)

rmse.means <- apply(rmse.matrix, 1, mean)

rmse.matrix <- cbind(rmse.matrix, rmse.means)

colnames(rmse.matrix) <- c("1", "2", "3", "4", "5", "Media")
kable(rmse.matrix, digits = 2, booktabs = T, caption = "Resultados obtenidos por los algoritmos (RMSE)")  %>% kable_styling(position="center", latex_options="hold_position") %>% pack_rows("Test", 1, 5) %>% pack_rows("Train", 6, 10)


## Tests estadísticos para comprobar los resultados
regr.test <- read.csv("regr_test_alumnos.csv", row.names = 1)
regr.train <- read.csv("regr_train_alumnos.csv", row.names = 1)

# Necesitamos calcular el MSE, no el RMSE
MSE <- function(preds, reals){sum((reals - preds)^2)/length(reals)}

# Modificamos la función de CV para lm y kNN, para que devuelvan el MSE
classify.lm <- function(fold, form, set = 'test'){
    train.set <- fold$train
    if (set == "test"){
        test.set <- fold$test
    } else if (set == "train"){
        test.set <- fold$train
    }
    model <- lm(form, train.set)
    res <- predict(model, test.set)
    MSE(res, test.set$Area)
}
classify.knn <- function(fold, form, set = "test"){
  train.set <- fold$train
  if (set == "test"){
    test.set <- fold$test
  } else if (set == "train"){
    test.set <- fold$train
  }
  res <- kknn(form, train.set, test.set)
  MSE(res$fitted.values, test.set$Area)
}

# Calculamos la información necesaria
mse.test.lm <- mean(sapply(folds, classify.lm, Area ~ .))
mse.train.lm <- mean(sapply(folds, classify.lm, Area ~ ., set="train"))
mse.test.knn  <- mean(sapply(folds, classify.knn, Area ~ .))
mse.train.knn  <- mean(sapply(folds, classify.knn, Area ~ ., set="train"))

# Y la sustituimos en los dataframes de resultados
regr.test["forestFires", "out_test_lm"] <- mse.test.lm
regr.train["forestFires", "out_train_lm"] <- mse.train.lm
regr.test["forestFires", "out_test_kknn"] <- mse.test.knn
regr.train["forestFires", "out_train_kknn"] <- mse.train.knn


## ESTUDIO ESTADÍSTICO SOBRE LOS RESULTADOS EN LOS CONJUNTOS DE TRAIN
## Test de Wilcoxon para comparar dos algoritmos
difs <- (regr.train[,1] - regr.train[,2]) / regr.train[,1]
wilc_1_2 <- cbind(ifelse (difs<0, abs(difs)+0.1, 0+0.1), ifelse (difs>0, abs(difs)+0.1, 0+0.1))
colnames(wilc_1_2) <- c(colnames(regr.train)[1], colnames(regr.train)[2])
head(wilc_1_2)

LMvsKNNtst <- wilcox.test(wilc_1_2[,1], wilc_1_2[,2], alternative = "two.sided", paired=TRUE)
KNNvsLMtst <- wilcox.test(wilc_1_2[,2], wilc_1_2[,1], alternative = "two.sided", paired=TRUE)
kable(cbind("p-val"=LMvsKNNtst$p.value, "R+"=LMvsKNNtst$statistic, "R-"=KNNvsLMtst$statistic), row.names = F, caption="Valores del test LM (R+) vs kNN (R-)", booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")


## Test de friedman para comparar tres algoritmos
friedman.test(as.matrix(regr.train))

## Test post-hoc de Holm
tam <- dim(regr.train)
grp <- rep(1:tam[2], each=tam[1])
pairwise.wilcox.test(as.matrix(regr.train), grp, p.adjust = "holm", paired=T)

## Cálculo de rankings para determinar qué modelo obtiene mejores resultados
train.ranks <- apply(regr.train, 1, rank)
kable(t(apply(train.ranks, 1, mean)), row.names=F, booktabs=T, caption="Ranking medio de cada algoritmo") %>% kable_styling(position="center", latex_options="hold_position")

## TEST ESTADÍSTICO SOBRE LOS RESULTADOS EN TEST
## Test de Wilcoxon para comparar dos algoritmos
difs <- (regr.test[,1] - regr.test[,2]) / regr.test[,1]
wilc_1_2 <- cbind(ifelse (difs<0, abs(difs)+0.1, 0+0.1), ifelse (difs>0, abs(difs)+0.1, 0+0.1))
colnames(wilc_1_2) <- c(colnames(regr.test)[1], colnames(regr.test)[2])
LMvsKNNtst <- wilcox.test(wilc_1_2[,1], wilc_1_2[,2], alternative = "two.sided", paired=TRUE)
KNNvsLMtst <- wilcox.test(wilc_1_2[,2], wilc_1_2[,1], alternative = "two.sided", paired=TRUE)
kable(cbind("p-val"=LMvsKNNtst$p.value, "R+"=LMvsKNNtst$statistic, "R-"=KNNvsLMtst$statistic), row.names = F, caption="Valores del test LM (R+) vs kNN (R-) sobre los resultados en test", booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")

## Test de Friedman para comparar tres algoritmos
friedman.test(as.matrix(regr.test))

## Test post-hoc de Holm
tam <- dim(regr.test)
grp <- rep(1:tam[2], each=tam[1])
pairwise.wilcox.test(as.matrix(regr.test), grp, p.adjust = "holm", paired=T)

## Cálculo de los rankings
test.ranks <- apply(regr.test, 1, rank)
kable(t(apply(test.ranks, 1, mean)), row.names=F, booktabs=T, caption="Ranking medio de cada algoritmo sobre los resultados de test") %>% kable_styling(position="center", latex_options="hold_position")

## PROBLEMA DE CLASIFICACIÓN
dataset <- read.csv('heart/heart.dat', comment.char = '@', header = F)
cols <- c('Age', 'Sex', 'ChestPainType', 'RestBloodPressure', 'SerumCholestoral', 'FastingBloodSugar', 'ResElectrocardiographic', 'MaxHeartRate', 'ExerciseInduced', 'Oldpeak', 'Slope', 'MajorVessels', 'Thal', 'Class')
colnames(dataset) <- cols
dataset$Class = as.factor(dataset$Class)

## Preprocesamiento de los datos
# La función scale estandariza el vector que se pasa como argumento restando su media y dividiendo por la desviación típica
dataset$Age <- scale(dataset$Age)
dataset$RestBloodPressure <- scale(dataset$RestBloodPressure)
dataset$SerumCholestoral <- scale(dataset$SerumCholestoral)
dataset$MaxHeartRate <- scale(dataset$MaxHeartRate)
dataset$Oldpeak <- scale(dataset$Oldpeak)

## Variables binarias a partir de las nominales
dataset$DummyEC_0 <- ifelse(dataset$ResElectrocardiographic == 0, 1, 0)
dataset$DummyEC_1 <- ifelse(dataset$ResElectrocardiographic == 1, 1, 0)
dataset$DummyEC_2 <- ifelse(dataset$ResElectrocardiographic == 2, 1, 0)
dataset$ResElectrocardiographic <- NULL

dataset$DummySlope_1 <- ifelse(dataset$Slope == 1, 1, 0)
dataset$DummySlope_2 <- ifelse(dataset$Slope == 2, 1, 0)
dataset$DummySlope_3 <- ifelse(dataset$Slope == 3, 1, 0)
dataset$Slope <- NULL

dataset$Thal <- ifelse(dataset$Thal == 3, 0, 1)

## Dimensión final del dataset
dim(dataset)

## Carga de los conjuntos de cross validation
folds <- load.folds("heart", 10, cols)
dim(folds[[1]]$train)
dim(folds[[1]]$test)

## Función para normalizar los conjuntos
normalize.sets <- function(fold){
  tra <- fold$train
  tst <- fold$test

  for (col in c("Age", "RestBloodPressure", "SerumCholestoral", "MaxHeartRate", "Oldpeak")){
    pp <- preProcess(tra[col])
    tra[col] <- predict(pp, tra[col])
    tst[col] <- predict(pp, tst[col])
  }
  
  tra$DummyEC_0 <- ifelse(tra$ResElectrocardiographic == 0, 1, 0)
  tra$DummyEC_1 <- ifelse(tra$ResElectrocardiographic == 1, 1, 0)
  tra$DummyEC_2 <- ifelse(tra$ResElectrocardiographic == 2, 1, 0)
  tra$ResElectrocardiographic <- NULL

  tst$DummyEC_0 <- ifelse(tst$ResElectrocardiographic == 0, 1, 0)
  tst$DummyEC_1 <- ifelse(tst$ResElectrocardiographic == 1, 1, 0)
  tst$DummyEC_2 <- ifelse(tst$ResElectrocardiographic == 2, 1, 0)
  tst$ResElectrocardiographic <- NULL
  
  tra$DummySlope_1 <- ifelse(tra$Slope == 1, 1, 0)
  tra$DummySlope_2 <- ifelse(tra$Slope == 2, 1, 0)
  tra$DummySlope_3 <- ifelse(tra$Slope == 3, 1, 0)
  tra$Slope <- NULL 
  
  tst$DummySlope_1 <- ifelse(tst$Slope == 1, 1, 0)
  tst$DummySlope_2 <- ifelse(tst$Slope == 2, 1, 0)
  tst$DummySlope_3 <- ifelse(tst$Slope == 3, 1, 0)
  tst$Slope <- NULL
  
  tra$Thal <- ifelse(tra$Thal == 3, 0, 1)
  tst$Thal <- ifelse(tst$Thal == 3, 0, 1)
  
  list(train = tra, test = tst)
}

## Aplicación de la función sobre todos los folds
folds <- lapply(folds, normalize.sets)

## Función para clasificar usando kNN
classify.knn <- function(fold, k = 3, set = 'test'){
  train.labels <- fold$train$Class
  if (set == 'test'){
     test.labels <- fold$test$Class 
     test.set <- fold$test
  } else if (set == 'train'){
    test.labels <- fold$train$Class
    test.set <- fold$train
  }

  fold$train$Class <- NULL
  test.set$Class <- NULL
  
  preds <- knn(fold$train, test.set, train.labels, k = k)
  
  sum(preds == test.labels)/length(test.labels)
}

## Precisiones obtenidas
accuracy <- sapply(folds, classify.knn)
kable(t(accuracy), digits = 3, col.names = sapply(1:10, function(x) paste("Fold", x)), caption = "Precisión obtenida sobre los distintos folds", booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")
mean(accuracy)

## Estudio de la precisión según el valor de K para el kNN
possible.k = seq(from=1, to=240, by=5)
mean.accs.knn.test <- sapply(possible.k, function(x) mean(sapply(folds, classify.knn, k = x, set = 'test')))
mean.accs.knn.train <- sapply(possible.k, function(x) mean(sapply(folds, classify.knn, k = x, set = 'train')))

res = data.frame(train=mean.accs.knn.train, test=mean.accs.knn.test)

ggplot(res, aes(x=possible.k)) + geom_line(aes(y=train, colour="red")) + geom_line(aes(y=test, colour="blue")) + xlab("Valor de k") + ylab("Precisión") +     scale_color_discrete(name = "Conjunto de datos", labels = c("Test", "Train"))

## Seleción del mejor valor de K para nuestro problema
mean.accs <- sapply(1:25, function(x) mean(sapply(folds, classify.knn, k = x)))

paste("k óptimo: ", which.max(mean.accs), ", precisión: ", mean.accs[which.max(mean.accs)], sep = "")

## Precisión obtenida
mean.accs.knn.train <- sapply(folds, classify.knn, k = 19, set = "train")
mean.accs.knn.test <- sapply(folds, classify.knn, k = 19, set = "test")

res.knn <- rbind(train = mean.accs.knn.train, test = mean.accs.knn.test)

## Carga de nuevo del dataset para utilizar el algoritmo LDA
dataset <- read.csv('heart/heart.dat', comment.char = '@', header = F)
cols <- c('Age', 'Sex', 'ChestPainType', 'RestBloodPressure', 'SerumCholestoral', 'FastingBloodSugar', 'ResElectrocardiographic', 'MaxHeartRate', 'ExerciseInduced', 'Oldpeak', 'Slope', 'MajorVessels', 'Thal', 'Class')
colnames(dataset) <- cols
dataset$Class = as.factor(dataset$Class)

## Test de normalidad de las variables
# Aprovechamos la tabla que construimos durante el análisis exploratorio de datos
kable(tests.mat, caption="Tests de Shapiro-Wilk para las variables continuas", booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")

## La varianza de los datos debe ser la misma para ambas clases. Comprobamos dicha precondición
negative.examples <- dataset %>% filter(Class==1)
positive.examples <- dataset %>% filter(Class==2)
neg.var <- sapply(negative.examples[,-14], var)
pos.var <- sapply(positive.examples[,-14], var)
table.var <- rbind(neg.var, pos.var)
kable(table.var[,1:5], booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")
kable(table.var[,6:9], booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")
kable(table.var[,10:13], booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")

## Buscamos correlación entre las variables
corrplot(cor(dataset[,-14]))

## Cargamos los subconjuntos de validación
folds <- load.folds("heart", 10, cols)

## Normalización de los datos en cada fold
normalize.sets <- function(fold){
  tra <- fold$train
  tst <- fold$test

  for (col in c("Age", "RestBloodPressure", "SerumCholestoral", "MaxHeartRate", "Oldpeak")){
    pp <- preProcess(tra[col])
    tra[col] <- predict(pp, tra[col])
    tst[col] <- predict(pp, tst[col])
  }

  list(train = tra, test = tst)
}

folds <- lapply(folds, normalize.sets)

## Función para clasificar usando LDA
classify.lda <- function(fold, form, set = "test"){
  lda.fit <- lda(form, data=fold$train)
  if (set == "test"){
    test.set <- fold$test
  } else if (set == "train") {
    test.set <- fold$train
  }
  preds <- predict(lda.fit, test.set)
  sum(preds$class == test.set$Class)/length(preds$class)
}

## Resultados obtenidos usando todas las variables
accuracy <- sapply(folds, classify.lda, form=Class ~ .)
kable(t(accuracy), digits = 3, col.names = sapply(1:10, function(x) paste("Fold", x)), caption = "Precisiones obtenidas por el modelo LDA con todas las variables", booktabs=T) %>% kable_styling(position = "center")
mean(accuracy)

## Resultados obtenidos usando exclusivamente las variables numéricas
accuracy <- sapply(folds, classify.lda, form=Class ~ Age + RestBloodPressure + SerumCholestoral + MaxHeartRate + Oldpeak)
kable(t(accuracy), digits = 3, col.names = sapply(1:10, function(x) paste("Fold", x)), caption = "Precisiones obtenidas por el modelo LDA con variables numéricas", booktabs=T) %>% kable_styling(position = "center")
mean(accuracy)

## Precisión obtenida sobre test y train con LDA 
mean.accs.lda.train <- sapply(folds, classify.lda, Class ~ ., set = "train")
mean.accs.lda.test <- sapply(folds, classify.lda, Class ~ ., set = "test")

res.lda <- rbind(train = mean.accs.lda.train, test = mean.accs.lda.test)

## Función para clasificar usando QDA
classify.qda <- function(fold, form, set = "test"){
  qda.fit <- qda(form, data=fold$train)
  if (set == "test"){
    test.set <- fold$test
  } else if (set == "train"){
    test.set <- fold$train
  }
  preds <- predict(qda.fit, test.set)
  sum(preds$class == test.set$Class)/length(preds$class)
}

## QDA usando todas las variables
accuracy <- sapply(folds, classify.qda, form=Class ~ .)
kable(t(accuracy), digits = 3, col.names = sapply(1:10, function(x) paste("Fold", x)), caption = "Precisiones obtenidas por el modelo QDA con variables numéricas", booktabs=T) %>% kable_styling(position = "center")
mean(accuracy)

## QDA usando sólo las variables numéricas
accuracy <- sapply(folds, classify.qda, form=Class ~ Age + RestBloodPressure + SerumCholestoral + MaxHeartRate + Oldpeak)
kable(t(accuracy), digits = 3, col.names = sapply(1:10, function(x) paste("Fold", x)), caption = "Precisiones obtenidas por el modelo QDA con variables numéricas", booktabs=T) %>% kable_styling()
mean(accuracy)

## Resultados medios obtenidos
mean.accs.qda.train <- sapply(folds, classify.qda, Class ~ ., set = "train")
mean.accs.qda.test <- sapply(folds, classify.qda, Class ~ ., set = "test")

res.qda <- rbind(train = mean.accs.qda.train, test = mean.accs.qda.test)

## Tablas de resultados
kable(res.knn, digits = 4, caption = "Resultados para kNN", booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")
kable(res.lda, digits = 4, caption = "Resultados para LDA", booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")
kable(res.qda, digits = 4, caption = "Resultados para QDA", booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")

# Tests estadísticos sobre los resultados
train.res <- cbind(res.knn['train',], res.lda['train',], res.qda['train',])
colnames(train.res) <- c("kNN", "LDA", "QDA")
test.res <- cbind(res.knn['test',], res.lda['test',], res.qda['test',])
colnames(test.res) <- c("kNN", "LDA", "QDA")

## Tes de Friedman para comparar los tres algoritmos (resultados en entrenamiento)
friedman.test(train.res)

## Test post-hoc de Holm
tam <- dim(train.res)
grp <- rep(1:tam[2], each=tam[1])
pairwise.wilcox.test(as.matrix(train.res), grp, p.adjust = "holm", paired=T)

## Resultados medios obtenidos
kable(t(apply(train.res, 2, mean)), caption="Precisión media obtenida por los algoritmos", booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")

## Test de Friedman para comparar los tres algoritmos (resultados en test)
friedman.test(test.res)


## Test post-hoc de Holm
tam <- dim(test.res)
grp <- rep(1:tam[2], each=tam[1])
pairwise.wilcox.test(as.matrix(test.res), grp, p.adjust = "holm", paired=T)

## Resultados medios obtenidos
accs <- rbind(apply(test.res, 2, mean), apply(test.res, 2, sd))
rownames(accs) <- c("mean", "sd")
kable(accs, booktabs=T) %>% kable_styling(position="center", latex_options="hold_position")
