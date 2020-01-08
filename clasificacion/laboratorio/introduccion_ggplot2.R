library(dplyr)
library(ggplot2)

## Data loading
data(CPS85, package="mosaicData")

## Scatter plot
ggplot2::ggplot(data=CPS85, mapping = aes(x = exper, y = wage)) +
    geom_point()

## Filtrado de datos (los ejes se reescalan automáticamente)
filtrados <- dplyr::filter(CPS85, wage < 40)
ggplot2::ggplot(data=filtrados, mapping = aes(x = exper, y = wage)) +
    geom_point()

## Cambios estéticos en el gráfico
ggplot2::ggplot(data=filtrados, mapping = aes(x = exper, y = wage)) +
    geom_point(color="cornflowerblue", alpha=.7, size=3)

## Adición de una curva de ajuste
ggplot2::ggplot(data=filtrados, mapping = aes(x = exper, y = wage)) +
    geom_point(color="cornflowerblue", alpha=.7, size=3) +
    geom_smooth(method = "lm", formula = y ~ x + I(x^2), color = "red")

## Cambios en las escalas de los ejes
ggplot2::ggplot(data=filtrados, mapping = aes(x = exper, y = wage)) +
    geom_point(color="cornflowerblue", alpha=.7, size=3) +
    geom_smooth(method = "lm", formula = y ~ x + I(x^2), color = "red") +
    scale_x_continuous(breaks = seq(0, 60, 10)) +
    scale_y_continuous(breaks = seq(0, 30, 5), labels = scales::dollar) +
    scale_color_manual(values = c("indiranred", "cornflowerblue"))


## Separación por el valor de una variable
ggplot2::ggplot(data=filtrados, mapping = aes(x = exper, y = wage)) +
    geom_point(color="cornflowerblue", alpha=.7, size=3) +
    geom_smooth(method = "lm", formula = y ~ x + I(x^2), color = "red") +
    scale_x_continuous(breaks = seq(0, 60, 10)) +
    scale_y_continuous(breaks = seq(0, 30, 5), labels = scales::dollar) +
    scale_color_manual(values = c("indiranred", "cornflowerblue")) +
    facet_wrap(~sector)

## Títulos
ggplot2::ggplot(data=filtrados, mapping = aes(x = exper, y = wage)) +
    geom_point(color="cornflowerblue", alpha=.7, size=3) +
    geom_smooth(method = "lm", formula = y ~ x + I(x^2), color = "red") +
    scale_x_continuous(breaks = seq(0, 60, 10)) +
    scale_y_continuous(breaks = seq(0, 30, 5), labels = scales::dollar) +
    scale_color_manual(values = c("indiranred", "cornflowerblue")) +
    facet_wrap(~sector) +
    labs(title = "Relación salarios / experiencia por sectores",
         caption = "Origen de los datos",
         x = "Años de experiencia", y = "Salario por hora")

## Cambio en el tema
graphic <- ggplot2::ggplot(data=filtrados, mapping = aes(x = exper, y = wage)) +
    geom_point(color="cornflowerblue", alpha=.7, size=3) +
    geom_smooth(method = "lm", formula = y ~ x + I(x^2), color = "red") +
    scale_x_continuous(breaks = seq(0, 60, 10)) +
    scale_y_continuous(breaks = seq(0, 30, 5), labels = scales::dollar) +
    scale_color_manual(values = c("indiranred", "cornflowerblue")) +
    facet_wrap(~sector) +
    labs(title = "Relación salarios / experiencia por sectores",
         caption = "Origen de los datos",
         x = "Años de experiencia", y = "Salario por hora") +
    theme_minimal()
graphic

## Guardado en memoria
ggsave(graphic, filename = "graph.png")
