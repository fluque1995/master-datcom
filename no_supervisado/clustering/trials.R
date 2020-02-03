library(ggplot2)
library(ggfortify)
library(stats)
library(fpc)
library(cluster)
library(dplyr)
library(factoextra)
library(fastDummies)
library(knitr)


dataset.path <- "dataset/bankloan-spss.csv"
dataset <- read.csv(dataset.path, sep=";", dec = ",")
dataset <- dataset[1:700,]

nclust <- 2

numeric.vars <- c(
    'ingresos', 'deudaingr', 'deudacred',
    'deudaotro', 'empleo',  'direccion', 'edad'
)

numeric.data <- dataset %>% select(numeric.vars)

scaled.data <- scale(numeric.data)

kmeans.res <- kmeans(numeric.data, nclust)

autoplot(kmeans.res, data = numeric.data)

sil <- silhouette(kmeans.res$cluster, dist(numeric.data))

plot(sil, col=1:nclust)
