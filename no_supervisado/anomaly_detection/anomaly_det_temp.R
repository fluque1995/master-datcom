## Test de Rosner

```{r}
test.de.rosner <- rosnerTest(selected.col, 10)

test.de.rosner$all.stats$Outlier
test.de.rosner$all.stats$Obs.Num

MiPlot_Univariate_Outliers(selected.col, c(218),
                           "Outliers detectados por el test de Rosner")

MiPlot_resultados_TestRosner(selected.col, 10)
```

# Test de Cerioli para el cálculo de outliers multivariados

```{r}
nivel.de.significacion = 0.05
nivel.de.significacion.penalizado = 1 - (1 - nivel.de.significacion) ^ (1 / nrow(mis.datos.numericos))  # Transparencia 96

set.seed(12)

## Método de Cerioli para el cálculo de outliers
cerioli <- cerioli2010.fsrmcd.test(
    mis.datos.numericos, signif.alpha = nivel.de.significacion
)

cerioli$outliers

is.outlier.cerioli <- which(cerioli$outliers)
is.outlier.cerioli

dist.mah.ponderadas <- cerioli$mahdist.rw
order.idx <- order(dist.mah.ponderadas, decreasing = T)

order.idx

mis.datos.numericos.normalizados[order.idx[1],]

## Uso del test para más de un punto anómalo
cerioli.b <- cerioli2010.fsrmcd.test(
    mis.datos.numericos, signif.alpha = nivel.de.significacion.penalizado
)

which(cerioli.b$outliers)

```

# Detección de outliers usando LOF

```{r}
numero.de.vecinos.lof = 5

lof.scores <- lofactor(mis.datos.numericos.normalizados, numero.de.vecinos.lof)
lof.scores

indices.segun.lof.score.ordenados <- order(lof.scores, decreasing = T)
indices.segun.lof.score.ordenados

lof.scores.ordenados <- lof.scores[indices.segun.lof.score.ordenados]
lof.scores.ordenados

plot(lof.scores.ordenados)

numero.de.outliers <- 4
indices.de.lof.top.outliers <- indices.segun.lof.score.ordenados[1:numero.de.outliers]

is.lof.outlier <- 1:dim(
                        mis.datos.numericos.normalizados
                    )[1] %in% indices.de.lof.top.outliers

is.lof.outlier

MiBiPlot_Multivariate_Outliers(
    mis.datos.numericos.normalizados, is.lof.outlier,
    "Outliers detectador por LOF"
)

data.frame.solo.outliers <- mis.datos.numericos.normalizados[is.lof.outlier,]

MiBoxPlot_juntos(mis.datos.numericos.normalizados, is.lof.outlier)
```

## Uso de IQR para eliminar los outliers univariantes

```{r, fig.height=3.5}
vector.claves.outliers.IQR.en.alguna.columna <- vector_claves_outliers_IQR_en_alguna_columna(mis.datos.numericos.normalizados)
vector.claves.outliers.IQR.en.alguna.columna

indices.de.outliers.multivariantes.LOF.pero.no.1variantes <- setdiff(
    indices.de.lof.top.outliers, vector.claves.outliers.IQR.en.alguna.columna
)

indices.de.outliers.multivariantes.LOF.pero.no.1variantes
valores.normalizados.de.los.outliers.LOF.pero.no.1variantes <- mis.datos.numericos.normalizados[indices.de.outliers.multivariantes.LOF.pero.no.1variantes,]
valores.normalizados.de.los.outliers.LOF.pero.no.1variantes

numero.de.outliers <- 12

indices.de.lof.top.outliers <- indices.segun.lof.score.ordenados[1:numero.de.outliers]

is.lof.outlier <- 1:dim(
                        mis.datos.numericos.normalizados
                    )[1] %in% indices.de.lof.top.outliers

MiBiPlot_Multivariate_Outliers(
    mis.datos.numericos.normalizados, is.lof.outlier,
    "Outliers detectador por LOF"
)

data.frame.solo.outliers <- mis.datos.numericos.normalizados[is.lof.outlier,]

MiBoxPlot_juntos(mis.datos.numericos.normalizados, is.lof.outlier)

vector.claves.outliers.IQR.en.alguna.columna <- vector_claves_outliers_IQR_en_alguna_columna(mis.datos.numericos.normalizados)
vector.claves.outliers.IQR.en.alguna.columna

indices.de.outliers.multivariantes.LOF.pero.no.1variantes <- setdiff(
    indices.de.lof.top.outliers, vector.claves.outliers.IQR.en.alguna.columna
)
indices.de.outliers.multivariantes.LOF.pero.no.1variantes

valores.normalizados.de.los.outliers.LOF.pero.no.1variantes <- mis.datos.numericos.normalizados[indices.de.outliers.multivariantes.LOF.pero.no.1variantes,]
valores.normalizados.de.los.outliers.LOF.pero.no.1variantes

MiPlot_Univariate_Outliers(
    mis.datos.numericos.normalizados,
    which(rownames(mis.datos.numericos.normalizados) == "Ferrari Dino"),
    "Ferrari Dino"
)
```
