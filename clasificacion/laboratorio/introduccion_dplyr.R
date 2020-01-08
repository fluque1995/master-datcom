library(dplyr)
library(tidyr)

## Nombre de las variables
names(starwars)

## Seleccionar columnas
data1 <- dplyr::select(starwars, name, height, gender)
names(data1)

## Se nos permite seleccionar rangos
data2 <- dplyr::select(starwars, name, mass:species)
names(data2)

## Eliminar columnas
data3 <- dplyr::select(starwars, -birth_year, -gender)
names(data3)

## Selección de instancias
data4 <- dplyr::filter(starwars, gender == "female")
show(data4)

## Condiciones múltiples
data5 <- dplyr::filter(starwars, gender == "female" & homeworld == "Alderaan")
show(data5)

data6 <- dplyr::filter(starwars, homeworld == "Alderaan" | homeworld == "Endor")
show(data6)

data7 <- dplyr::filter(starwars, homeworld %in% c("Alderaan", "Endor"))
show(data7)

## Modificación de variables
data8 <- dplyr::mutate(starwars, height = height/30.48,
                       mass = mass*2.205) # height to feet, weight to lb
show(data8)

## Este método permite crear nuevas variables
data9 <- dplyr::mutate(starwars,
                       heightcat = ifelse(height > 180, "tall", "short"))
names(data9)
data9$heightcat

## Tratamiento de datos anómalos
data10 <- dplyr:mutate(starwars,
                       height = ifelse(height < 75 | height > 200, NA, height))
show(data10)

## Borrado de datos
rm(data1, data2, data3, data4, data5, data6, data7, data8, data9, data10)

## Obtener medidas de resumen de los datos
medidas <- dplyr::summarise(starwars, mean_ht=mean(height, na.rm=T),
                            sd_ht=sd(height, na.rm=T))
medidas

## Agrupamiento de datos
medidasSexo <- dplyr::group_by(starwars, gender)
medidasSexo <- dplyr::summarise(medidasSexo, mean_ht=mean(height, na.rm=T),
                                mean_mss=mean(mass, na.rm=T))
medidasSexo

## Concatenación de operaciones
medidas <- starwars %>%
    dplyr::filter(gender == "male") %>%
    dplyr::group_by(species) %>%
    dplyr::summarise(mean_ht = mean(height, na.rm = T))
medidas
