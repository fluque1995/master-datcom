import utils
import numpy as np
import cv2
import keras
import pandas as pd

print("Cargando las imágenes")
images, labels = utils.load_data("data")

vgg_images = keras.applications.vgg16.preprocess_input(images)

print("Entrenando el modelo VGG16 con validación cruzada")
results = utils.cross_validation_cnn(
    vgg_images, labels, keras.applications.VGG16
)

for k, v in results.items():
    print("{} media: {}".format(k, v[-1]))
