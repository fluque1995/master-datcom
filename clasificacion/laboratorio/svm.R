## Generamos un conjunto de datos aleatorio: linealmente separables
set.seed(68)

X1 <- rnorm(n=10, mean=2, sd=1)
X2 <- rnorm(n=10, mean=2, sd=1)

observaciones <- data.frame(
    X1 = c(X1, X1+2),
    X2 = c(X2, X2+2),
    clase = rep(c(1,-1), each = 10)
)

observaciones$clase <- as.factor(observaciones$clase)

## Posibles rectas que nos separan los datos
ggplot() +
    geom_point(data = observaciones, aes(x=X1, y=X2, color=clase), size=4) +
    geom_abline(intercept = 9, slope = -2) +
    geom_abline(intercept = 8.5, slope = -1.7) +
    geom_abline(intercept = 6.5, slope = -1) +
    theme_bw()

## Cargamos la librería que nos permite trabajar con SVMs

library(e1071)

set.seed(101)

## Número de muestras a generar
n <- 100

coordenadas <- matrix(rnorm(2*100), n, 2)
colnames(coordenadas) <- c("X1", "X2")

y = c(rep(-1, n/2), rep(1, n/2))
y <- as.factor(y)

datos <- tibble::as_tibble(data.frame(coordenadas, y))

## Transformamos los datos de forma que sean separables
datos <- datos %>%
    dplyr::mutate(X1 = ifelse(y == -1, X1 + 3.8, X1)) %>%
    dplyr::mutate(X2 = ifelse(y == -1, X2 + 3.8, X2))

## Visualizamos la nube de puntos
ggplot2::ggplot(data = datos, aes(x = X1, y = X2, color = y)) +
    geom_point(size = 4) +
    theme(legend.position = "none")

## Utilizamos la función svm para aprender la frontera
modelo <- e1071::svm(formula = y ~ X1 + X2, data = datos,
                     kernel="linear", cost=10, scale = FALSE)

plot(modelo, datos, X1 ~ X2, svSymbol = "*")

rangoX1 <- range(datos$X1)
rangoX2 <- range(datos$X2)

valoresX1 <- seq(rangoX1[1], rangoX1[2], length.out=300)
valoresX2 <- seq(rangoX2[1], rangoX2[2], length.out=300)

nuevosPuntos <- tibble::as_tibble(
                            expand.grid(X1=valoresX1, X2=valoresX2)
                        )

predicciones <- predict(modelo, nuevosPuntos)

colorRegiones <- data.frame(nuevosPuntos, predicciones)

## Obtención de los vectores de soporte
soporte <- as.matrix(datos[modelo$index, c("X1", "X2")])
coeficientes <- modelo$coefs

producto <- t(coeficientes) %*% soporte

beta <- drop(producto)
beta0 <- modelo$rho

## Representación

ggplot() +
    geom_point(data = colorRegiones,
               aes(x=X1, y=X2, color=predicciones), alpha=.2) +
    geom_point(data = datos, aes(x=X1, y=X2, color=as.factor(y)),
               size=6) +
    geom_point(data = datos[modelo$index, ],
               aes(x=X1, y=X2, color=as.factor(y)),
               shape=21, colour="black", size=6) +
    geom_abline(intercept=beta0/beta[2],
                slope = -beta[1]/beta[2]) +
    geom_abline(intercept=(beta0 + 1)/beta[2],
                slope = -beta[1]/beta[2], linetype="dashed") +
    geom_abline(intercept=(beta0 - 1)/beta[2],
                slope = -beta[1]/beta[2], linetype="dashed")


modeloCV <- e1071::tune(
                       "svm", y ~ X1 + X2, data = datos,
                       kernel="linear",
                       ranges = list(cost = c(0.001, 0.01, 0.1, 1, 2, 5))
                   )

summary(modeloCV)

## Grafica del error de validación cruzada
ggplot(data=modeloCV$performances, aes(x=cost, y = error)) +
    geom_line() +
    geom_point() +
    theme_bw()


## Kernel polinómico

modeloCV <- e1071::tune(
                       "svm", y ~ X1 + X2, data = datos,
                       kernel="polynomial",
                       ranges = list(
                           cost = c(0.001, 0.01, 0.1, 1, 2, 5),
                           gamma = c(0.5, 1, 2, 3, 4, 5, 10)
                       )
                   )

modeloCV
