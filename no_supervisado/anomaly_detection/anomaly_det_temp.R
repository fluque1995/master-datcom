# Detección de outliers usando LOF

``{r}
numero.de.vecinos.lof = 5

lof.scores <- lofactor(mis.datos.numericos.normalizados, numero.de.vecinos.lof)
lof.scores

indices.segun.lof.score.ordenados <- order(lof.scores, decreasing = T)
indices.segun.lof.score.ordenados

lof.scores.ordenados <- lof.scores[indices.segun.lof.score.ordenados]
lof.scores.ordenados

plot(lof.scores.ordenados)

numero.de.outliers <- 7
indices.de.lof.top.outliers <- indices.segun.lof.score.ordenados[1:numero.de.outliers]

is.lof.outlier <- 1:dim(
                        scaled.dataset
                    )[1] %in% indices.de.lof.top.outliers

is.lof.outlier

MiBiPlot_Multivariate_Outliers(
    scaled.dataset, is.lof.outlier,
    "Outliers detectador por LOF"
)

data.frame.solo.outliers <- mis.datos.numericos.normalizados[is.lof.outlier,]

MiBoxPlot_juntos(mis.datos.numericos.normalizados, is.lof.outlier)
``

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
    "Outliers detectados por LOF"
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
