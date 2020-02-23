import utils
import sklearn.metrics
import numpy as np
import time

TRAIN_IMAGES_FOLDER = "data/train"
TEST_IMAGES_FOLDER = "data/test"
IMG_EXTENSION = ".png"

print("Cargando las imágenes de entrenamiento")
train_images, train_classes = utils.load_data(TRAIN_IMAGES_FOLDER, IMG_EXTENSION)
print("Cargando las imágenes de test")
test_images, test_classes = utils.load_data(TEST_IMAGES_FOLDER, IMG_EXTENSION)

print("Calculando los descriptores LBP")
train_descriptors = utils.compute_lbp(train_images, uniform = False)
test_descriptors = utils.compute_lbp(test_images, uniform = False)

print("Entrenando el clasificador")
classifier = utils.train(train_descriptors.astype(np.float32), train_classes)

print("Prediciendo sobre el conjunto de test")
predictions = utils.test(test_descriptors.astype(np.float32), classifier)

print("La precisión del modelo es {0:.5f}".format(
    sklearn.metrics.accuracy_score(test_classes, predictions)
))
