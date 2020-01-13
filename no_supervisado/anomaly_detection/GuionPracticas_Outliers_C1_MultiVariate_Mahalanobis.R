# Máster -> Detección de anomalías
# Juan Carlos Cubero. Universidad de Granada

###########################################################################
# MULTIVARIATE OUTLIERS -> Multivariate Normal Distribution
# -> Mahalanobis
###########################################################################

###########################################################################
# RESUMEN:

# El objetivo es calcular los outliers multivariantes
# Un outlier multivariante tendrá:
# - o bien un valor anormalmente alto o bajo en alguna de las variables
# - o bien una combinación anómala de valores en 2 o más variables
#   Éstos últimos serán los más interesantes de detectar.

# En este apartado se van a utilizar técnicas estadísticas paramétricas.
# En nuestro caso, se necesita que los datos estén distribuidos según una normal
# multivariante, aunque si las distribuciones de cada variable son unimodales
# también se suele aplicar este tipo de tests
#
# Bajo estas premisas, se usa la distancia de Mahalanobis
# para medir cómo de alejado está cada dato al centro de la distribución,
# es decir, hasta qué punto es un outlier multivariante.
#
# Podemos plantear dos tipos de tests:
# a) H0: El dato con máxima distancia de Mahalanobis no es un outlier
#    H1: El dato con máxima distancia de Mahalanobis es un outlier
#    En este caso usaríamos el alpha usual (0.05)
# b) H0: No hay outliers
#    H1: Hay al menos un outlier
#    En este caso usaríamos un alpha penalizado para tener en cuenta el error FWER
#    (Ver página 96 de las transparencias)
# En el test b) será más difícil rechazar debido a la penalización del nivel de significación

# No hay que normalizar los datos ya que la distancia de Mahalanobis está
# diseñada, precisamente para evitar el problema de la escala.

# Conjunto de datos:

mis.datos.numericos =  mtcars[,-c(8:11)]  #
mis.datos.numericos.normalizados = scale(mis.datos.numericos)
nivel.de.significacion = 0.05
nivel.de.significacion.penalizado = 1 - ( 1 - nivel.de.significacion) ^ (1 / nrow(mis.datos.numericos))  # Transparencia 96

###########################################################################
# Obtención de los outliers multivariantes

# Transparencia 97

# Usaremos el paquete CerioliOutlierDetection

# Obtiene los outliers calculando las distancias de Mahalanobis
# La estimación de la matriz de covarianzas es la estimación robusta según MCD
# (minimum covariance determinant)
# La distribución del estadístico es la obtenida en Hardin-Rocke o  Green and Martin
# (ver documentación del paquete CerioliOutlierDetection)

# Establecemos la semilla para el método iterativo que calcula MCD
# IMPORTANTE: Para que el resultado sea el mismo en todas las ejecuciones,
# siempre hay que establecer la semilla antes de lanzar la función correspondiente.

set.seed(12)

# Llamamos a cerioli2010.fsrmcd.test pasándole como primer parámetro nuestro dataset
# Pasamos como parámetro a signif.alpha el valor 0.05.
# Tal y como indica la documentación del paquete Cerioli, al utilizar un valor
# de significación "típico" de los test de hipótesis como es 0.05, el test que
# vamos a aplicar es del tipo a)
# a) H0: El dato con máxima distancia de Mahalanobis no es un outlier
#    H1: El dato con máxima distancia de Mahalanobis es un outlier
#    En este caso usaríamos el alpha usual (0.05)

# Guardamos el resultado en la variable
# cerioli
# Accedemos a cerioli$outliers para obtener un vector de T/F indicando
# si cada dato es o no un outlier. Guardamos el resultado en la variable
# is.outlier.cerioli
# A partir de ella, obtenemos un vector de índices de los marcados como outliers:
# Nos debe salir:

# 9  31

# Nos salen dos outliers porque el procedimiento realiza un test por separado
# a cada valor del dataset. Esto puede confundir ya que al fijar un nivel de significación de 0.05
# sólo podemos fijarnos en el valor más extremo (es un test de tipo a))
# Por lo tanto, para saber cuál es el más extremo de los dos
# tenemos que ver los valores de la distancia de Mahalanobis
# (realmente es una distancia modificada -ponderada- por los autores del paquete)
# ordenarlos y ver a quién corresponde el máximo.
# Para ello, construimos la variable:
# dist.mah.ponderadas = cerioli$mahdist.rw   # Valores de la distancia de Mahalanobis ponderada
# Ordenamos decrecientemente estas distancias y obtenemos los índices correspondientes en la variable
# indices.dist.mah.ponderadas
# Nos debe salir:

# [1] 31  9 29 17 28 ......

# Por lo tanto, el mayor valor de distancia de Mahalanobis ponderada es el 31.
# Por lo tanto, el test de tipo a) rechazaría la hipótesis de que el 31
# no es un outlier y lo aceptamos como outlier.

# Cabría ahora responder a la pregunta:
# ¿Es un outlier porque tiene un valor muy alto en alguna variable?
# ¿O es un outlier "puro" (más interesante) porque tiene una combinación
# anormal de variables?
# Para ello, vamos a obtener los datos normalizados de dicho valor. Debe salir:

#                mpg       cyl       disp         hp       drat          wt      qsec
# Maserati Bora -0.8446439  1.014882  0.5670394  2.7465668 -0.1057878  0.36051645 -1.818049

# En este caso, parece que es porque tiene un valor de hp (horse power)
# muy alto (2.746 como valor normalizado)
# En el próximo script de las prácticas volveremos sobre este asunto.


# Pasamos ahora a ejecutar un test del tipo b):
# b) H0: No hay outliers
#    H1: Hay al menos un outlier
#    En este caso usaríamos un alpha penalizado para tener en cuenta el error FWER
#    (Ver página 96 de las transparencias)

# Tal y como indica la documentación del paquete, para lanzar un test del tipo b)
# debemos lanzar el test fsrmcd pero con un nivel de significación penalizado.
# Así pues, lanzamos fsrmcd con nivel.de.significacion.penalizado
# Nos saldrá que no podemos rechazar la hipótesis nula de que no hay outliers
# Tal y como dijimos al principio, esto se produce porque al estar
# contrastando de forma conjunta muchas hipótesis, perdemos potencia en el test
# Con un test de tipo a) pudimos establecer que el 31 era un outlier pero si
# usamos un test de tipo b) comparando si cada uno de los datos es un outlier,
# perdemos potencia y no podemos rechazar

# COMPLETAR

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

cerioli.b <- cerioli2010.fsrmcd.test(
    mis.datos.numericos, signif.alpha = nivel.de.significacion.penalizado
)

which(cerioli.b$outliers)
