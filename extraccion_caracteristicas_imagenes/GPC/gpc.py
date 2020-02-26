import os
if os.path.basename(os.getcwd()) != "GPC":
    os.chdir("extraccion_caracteristicas_imagenes/GPC")

import gpflow
import scipy.io as scio
import numpy as np

def read_data(filename):
    data = scio.loadmat(filename)

    healthy = data['Healthy_folds']
    malign = data['Malign_folds']

    healthy_folds = [healthy[0][i][0] for i in range(5)]
    malign_folds = [malign[0][i][0] for i in range(5)]

    return (healthy_folds, malign_folds)

healthy_folds, malign_folds = read_data("Datos.mat")
