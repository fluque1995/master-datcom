import utils
import sklearn.metrics
import numpy as np
import time
import cv2

TRAIN_IMAGES_FOLDER = "data/train"
TEST_IMAGES_FOLDER = "data/test"
IMG_EXTENSION = ".png"

uniform = False

print("Cargando las imágenes de entrenamiento")
train_images, train_classes = utils.load_data(TRAIN_IMAGES_FOLDER, IMG_EXTENSION)
print("Cargando las imágenes de test")
test_images, test_classes = utils.load_data(TEST_IMAGES_FOLDER, IMG_EXTENSION)

print("Calculando los descriptores LBP")
train_descriptors = utils.compute_lbp(train_images, uniform = uniform)
test_descriptors = utils.compute_lbp(test_images, uniform = uniform)

descriptors = np.vstack((train_descriptors, test_descriptors))
labels = np.concatenate((train_classes, test_classes))

results = utils.cross_validation(descriptors, labels,
                                 svm_kernel=cv2.ml.SVM_POLY,
                                 params={"degree":2})

for k, v in results.items():
    print("{} media: {}".format(k, v[-1]))
