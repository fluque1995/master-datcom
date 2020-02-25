import os

if(os.path.basename(os.getcwd()) != "entrega"):
    os.chdir("extraccion_caracteristicas_imagenes/LBP/entrega")

import utils
import sklearn.metrics
import numpy as np
import time
import LBP
import cv2


TRAIN_IMAGES_FOLDER = "data/train"
TEST_IMAGES_FOLDER = "data/test"
IMG_EXTENSION = ".png"

print("Cargando las imágenes de entrenamiento")
train_images, train_classes = utils.load_data(TRAIN_IMAGES_FOLDER, IMG_EXTENSION)
test_images, test_classes = utils.load_data(TEST_IMAGES_FOLDER, IMG_EXTENSION)

print("Calculando descriptores")
train_descriptors = utils.compute_lbp(train_images, uniform = True)
test_descriptors = utils.compute_lbp(test_images, uniform = True)

descriptors = np.vstack((train_descriptors, test_descriptors))
labels = np.concatenate((train_classes, test_classes))

print("Entrenando el clasificador")
classifier = utils.train(descriptors.astype(np.float32), labels,
                         kernel = cv2.ml.SVM_POLY,
                         params={'degree': 2}
)

detector = LBP.LBPDetector(8,8,16,16,128,64,8,8,classifier)

print("Detectando en Abbey Road")

abbey_road = cv2.imread("abbey_road.jpeg")
peds = detector.detect(abbey_road, [0.8,1,1.2])

for ped in peds:
    cv2.rectangle(abbey_road, (ped[1], ped[0]), (ped[3], ped[2]), (0,0,255), 1)

cv2.imwrite("abbey_road_dets_multiscale.jpeg", abbey_road)

print("Detectando en Pedestrians")

pedestrians = cv2.imread("street.jpg")
peds = detector.detect(pedestrians, [1,1.1,1.2])

for ped in peds:
    cv2.rectangle(pedestrians, (ped[1], ped[0]), (ped[3], ped[2]), (0,0,255), 1)

cv2.imwrite("street_dets.jpeg", pedestrians)
