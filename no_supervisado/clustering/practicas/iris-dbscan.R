 #iris-dbscan, preparo datos
 library(fpc)
 library("cluster", lib.loc="C:/Program Files/R/R-3.1.2/library")
 iris2=iris
iris2$Species=NULL
 #normalizo iris2, Notese el uso y sintaxis del bucle
 for (j in 1:4) {x=iris2[,j] ; v=(x-mean(x))/sqrt(var(x)); iris2[,j]=v}
ds=dbscan(iris2,eps=1.0,MinPts=5)
table(ds$cluster,iris$Species)
plot(ds,iris2)
 plot(ds,iris2[c(1,4)])
 plot(ds,iris2[c(3,4)])
 x=table(ds$cluster,iris$Species)
 nc=length(x[,1])
 nc
shi= silhouette(ds$cluster,dist(iris2))
 plot(shi,col=1:nc)
