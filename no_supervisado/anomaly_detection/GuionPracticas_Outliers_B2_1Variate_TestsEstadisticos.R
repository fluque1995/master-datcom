# Máster -> Detección de anomalías
# Juan Carlos Cubero. Universidad de Granada

###########################################################################
# UNIVARIATE STATISTICAL OUTLIERS -> 1-variate Normal Distribution
###########################################################################

###########################################################################
# TODO ESTE FICHERO (B2) ES DE AMPLIACIÓN
# RESUÉLVALO SÓLO CUANDO TERMINE EL RESTO DE FICHEROS
# POR LO TANTO, PASE AHORA A RESOLVER EL SIGUIENTE FICHERO (C1)

# ESTA PARTE DE AMPLIACIÓN ES OBLIGATORIO RESOLVERLA EN EL CASO DE QUE HAGA
# EL TRABAJO DEL CURSO SOBRE LA PARTE DE ANOMALÍAS
###########################################################################

###########################################################################
# RESUMEN:

# El objetivo es el mismo que el indicado en el fichero B1, es decir, encontrar
# outliers bajo la hipótesis de normalidad
# La diferencia es que ahora vamos a aplicar un test estadístico
# para poder declarar que el valor más alejado de la media es un outlier
# con una significación estadística establecida a priori

# Se aplicarán los siguientes tests:

# Grubbs' test. Normal 1-dim. 1 único outlier
# grubbs.test {outliers}

# Rosner's test. Normal 1-dim. <= k outliers.
# rosnerTest {EnvStats}
###########################################################################

###########################################################################
# Conjuntos de datos
###########################################################################


datos.con.un.outlier           = c(45,56,54,34,32,45,67,45,67,140,65)
mydata.numeric = datos.con.un.outlier

###########################################################################
# Test de Grubbs
###########################################################################

# Transparencia 83


###########################################################################
# datos.con.un.outlier

# Mostramos el histograma de mydata.numeric usando la función hist
# y un gráfico de puntos con la función plot
# Observamos que hay un dato con un valor extremo

# -------------------------------------------------------------------------


# Aplicamos el test de Grubbs sobre datos.con.un.outlier
# Usamos la función grubbs.test (two.sided = TRUE)
# Guardamos el resultado en test.de.Grubbs y vemos el p.value correspondiente

# [1] 0.001126431

# Este resultado es significativo con los valores de alpha usuales 0.025, 0.01

# -------------------------------------------------------------------------

# El test de Grubbs es significativo por lo que se concluye que hay un ÚNICO outlier
# El valor que toma (140) los podríamos obtener a través de la función outlier del paquete outliers
# pero éste no nos dice cuál es el índice correspondiente (10).
# Por lo tanto, calculamos manualmente cuál es el índice de aquel registro
# que más se desvía de la media de la columna correspondiente.
# Tendremos que usar las funciones abs(valor absoluto), mean(media) y order (para ordenar)
# Tenga en cuenta que el resultado de order es un conjunto de índices y no de valores originales
# El resultado lo guardamos en las siguientes variables:
# indice.de.outlier.Grubbs
# valor.de.outlier.Grubbs

# [1] 10
# [1] 140

# -------------------------------------------------------------------------

# Ahora que sabemos el índice del outlier, podemos usar la función MiPlot_Univariate_Outliers
# Esta función muestra un plot similar al que ya habíamos mostrado, pero usa el color rojo para mostrar el outlier
# Los parámetros son: el conjunto de datos, los índices de los outliers (sólo uno en este caso) y el título a mostrar
# MiPlot_Univariate_Outliers = function (datos, indices_de_Outliers, titulo)

# Resultado:

# Número de datos: 11
# ¿Quién es outlier?: FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE FALSE

# COMPLETAR

hist(mydata.numeric)
plot(mydata.numeric)

grubbs.test(mydata.numeric, two.sided = T)

###########################################################################
# Realizamos el mismo proceso anterior empaquetado en una función
###########################################################################

# Llamamos a la función MiPlot_resultados_TestGrubbs
# MiPlot_resultados_TestGrubbs = function(datos)
# Esta función realiza todo el proceso de aplicar el test de Grubbs tal y como hemos hecho anteriormente
# También muestra los resultados: para ello, la función llama directamente a MiPlot_Univariate_Outliers
# El parámetro a pasar a la función MiPlot_resultados_TestGrubbs es el conjunto de datos
#
# p.value: 0.001126431
# Índice de outlier: 10
# Valor del outlier: 140
# Número de datos: 11
# ¿Quién es outlier?: FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE

# COMPLETAR

MiPlot_resultados_TestGrubbs(mydata.numeric)

###########################################################################
# Masking/Swamping. Transparencias 86-88
###########################################################################

# Vamos a  aplicar el mismo proceso con otro conjunto de datos, para ver
# cómo se produce el "masking"
# En el caso de que vaya a hacer el trabajo de Anomalías, sólo ejecute
# los scripts siguientes con  el conjuntos de datos datos.con.dos.outliers.masking
# y no los aplique a su conjunto de datos.

datos.con.dos.outliers.masking = c(45,56,54,34,32,45,67,45,67,154,125,65)

# Mostramos un gráfico de puntos con la función plot
# Vemos que hay dos outliers

# Aplicamos el test de Grubbs sobre datos.con.dos.outliers.masking

# [1] 0.05614091

# El resultado no es significativo con ninguno de los valores de alpha usuales (<= 0.05)
# Sin embargo, hay dos outliers. (125, 154).
# La razón es que se ha producido un efecto de "masking"
# Ningún outlier es detectado por Grubbs :-(

# COMPLETAR

plot(datos.con.dos.outliers.masking)
grubbs.test(datos.con.dos.outliers.masking, two.sided = T)

# Hay tests para detectar un número exacto de k outliers, pero no son muy útiles
# Mejor usamos un test para detectar un número menor o igual que k outliers (Rosner)

# Aplicamos el Test de Rosner (rosnerTest) con k=4 sobre datos.con.dos.outliers.masking
# Nos dará un aviso ocasionado por tener pocos datos
# Guardamos el resultado en test.de.rosner
# El test ordena los valores de mayor a menor distancia de la media y lanza el test de hipótesis
# para ver si hay menos de k=4 outliers.

# Imprimimos los siguientes campos:
#   test.de.rosner$all.stats$Outlier
#     Es un vector de 4 boolean.
#     Nos indica si son considerados outliers los 4 valores que más se alejan de la media
#     En este caso:
#     [1]  TRUE  TRUE FALSE FALSE
#     Los dos primeros son TRUE y el resto FALSE => El test indica que hay dos outliers :-)
#
#   test.de.rosner$all.stats$Obs.Num
#     Es un vector con los cuatro índices de los 4 valores que
#     más se alejan de la media
#     En este caso:
#     [1]  10    11   5     4

# Construimos el vector con los índices de los que son outliers (10, 11)
# y se lo pasamos como parámetro a la función
# MiPlot_Univariate_Outliers
# MiPlot_Univariate_Outliers = function (datos, indices_de_Outliers, titulo){

# Número de datos: 12
# ¿Quién es outlier?: FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE TRUE FALSE

# COMPLETAR

test.de.rosner <- rosnerTest(datos.con.dos.outliers.masking, 4)

test.de.rosner$all.stats$Outlier
test.de.rosner$all.stats$Obs.Num

MiPlot_Univariate_Outliers(datos.con.dos.outliers.masking, c(10,11),
                           "Outliers detectados por el test de Rosner")

#######################################################################

# La función
# MiPlot_resultados_TestRosner = function(datos)
# hace directamente las anteriores tareas, es decir, lanza el test y dibuja el plot.
# Lanzamos esta función con el dataset datos.con.dos.outliers.masking
# y comprobamos que ofrece los resultados vistos anteriormente

# COMPLETAR

MiPlot_resultados_TestRosner(datos.con.dos.outliers.masking, 4)
