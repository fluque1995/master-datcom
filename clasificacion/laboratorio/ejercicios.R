library(dplyr)
library(tidyr)
library(ggplot2)
library(treemapify)

## Preparamos los datos con los que vamos a trabajar
datosSociales <- tibble::as_tibble(read.csv(
                             "DatosSocialesAndalucia.csv"))
coordenadas <- tibble::as_tibble(read.csv(
                           "CoordenadasMunicipios.csv"))

coordenadas <- dplyr::select(coordenadas, -Provincia)

datos <- tibble::as_tibble(cbind(datosSociales, coordenadas))

## Diagrama de barras
ggplot2::ggplot(datos, aes(x=Provincia, y = ..count../sum(..count..)*100)) +
    geom_bar(fill="red", color="blue") +
    labs(y = "Porcentaje", title = "Municipos por provincia")

counters <- datos %>% count(Provincia)

## Ordenamos el resultado
ggplot2::ggplot(counters, aes(x=reorder(Provincia, n), y = n)) +
    geom_bar(stat="identity", fill="red", color="blue") +
    geom_text(aes(label=n), vjust=-.5) +
    labs(y = "Porcentajes", title = "Municipos por provincia")

## Grafico de tarta
contadores <- datos %>% count(Provincia) %>% arrange(desc(Provincia)) %>%
    mutate(prop = round(n*100/sum(n), 2), laby.pos = cumsum(prop) - 0.5*prop)

ggplot2::ggplot(contadores, aes(x="", y=prop, fill=Provincia)) +
    geom_bar(width=1, stat="identity", color="black") +
    coord_polar("y", start = 0, direction = -1) +
    geom_text(aes(y = laby.pos, label = prop), color="black")

## Mapa de árbol (librería treemapify)
contadores <- datos %>% count(Provincia)

ggplot2::ggplot(contadores, aes(fill=Provincia, area=n, label=Provincia)) +
    geom_treemap() +
    geom_treemap_text(color="black", place="centre") +
    labs(title="Municipios por provincia") +
    theme(legend.position="none")

## Histograma para variables continuas

ggplot2::ggplot(datos, aes(x=latitud)) +
    geom_histogram()

## Función de densidad
ggplot2::ggplot(datos, aes(x=latitud)) +
    geom_density()

## Dos variables (ambas categóricas)
datos <- datos %>% mutate(crece = ifelse(IncrPoblacion > 0, "si", "no"))

ggplot2::ggplot(datos, aes(x=Provincia, fill=crece)) +
    geom_bar(position = "stack")

## Gráficos de puntos
ggplot2::ggplot(datos, aes(x=longitud, y=latitud)) +
    geom_point()
