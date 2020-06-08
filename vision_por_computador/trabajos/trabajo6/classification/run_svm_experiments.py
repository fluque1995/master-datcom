import utils
import numpy as np
import cv2
import keras
import pandas as pd

print("Cargando las imágenes")
images, labels = utils.load_data("data")

print("Calculando los descriptores HOG")
hog_descriptors = utils.compute_hog(images)
results_df = pd.DataFrame(
    columns=["Model", "TP", "FN", "FP", "TN",
             "Accuracy", "Precision", "Recall", "F1"]
)

print("Entrenando los modelos SVM lineales")
results = utils.cross_validation_svm(
    hog_descriptors, labels, svm_kernel=cv2.ml.SVM_LINEAR,
    params={"name": "Linear"}
)
results_df.loc[len(results_df.index)] = results

for k, v in results.items():
    print("{} media: {}".format(k, v))
print("")

print("Entrenando los modelos SVM con kernel polinómico de grado 2")
results = utils.cross_validation_svm(
    hog_descriptors, labels, svm_kernel=cv2.ml.SVM_POLY,
    params={"degree":2, "name": "Poly - deg 2"}
)
results_df.loc[len(results_df.index)] = results

for k, v in results.items():
    print("{} media: {}".format(k, v))
print("")

print("Entrenando los modelos SVM con kernel polinómico de grado 3")
results = utils.cross_validation_svm(
    hog_descriptors, labels, svm_kernel=cv2.ml.SVM_POLY,
    params={"degree":3, "name": "Poly - deg 3"}
)
results_df.loc[len(results_df.index)] = results

for k, v in results.items():
    print("{} media: {}".format(k, v))
print("")

print("Entrenando los modelos SVM con kernel polinómico de grado 4")
results = utils.cross_validation_svm(
    hog_descriptors, labels, svm_kernel=cv2.ml.SVM_POLY,
    params={"degree":4, "name": "Poly - deg 4"}
)
results_df.loc[len(results_df.index)] = results

for k, v in results.items():
    print("{} media: {}".format(k, v))
print("")

print("Entrenando los modelos SVM con kernel gaussiano, gamma=0.1")
results = utils.cross_validation_svm(
    hog_descriptors, labels, svm_kernel=cv2.ml.SVM_RBF,
    params={"gamma":0.1, "name": "RBF - gamma 0.1"}
)
results_df.loc[len(results_df.index)] = results

for k, v in results.items():
    print("{} media: {}".format(k, v))
print("")

print("Entrenando los modelos SVM con kernel gaussiano, gamma=0.2")
results = utils.cross_validation_svm(
    hog_descriptors, labels, svm_kernel=cv2.ml.SVM_RBF,
    params={"gamma":0.2, "name": "RBF - gamma 0.2"}
)
results_df.loc[len(results_df.index)] = results

for k, v in results.items():
    print("{} media: {}".format(k, v))
print("")

print("Entrenando los modelos SVM con kernel gaussiano, gamma=0.3")
results = utils.cross_validation_svm(
    hog_descriptors, labels, svm_kernel=cv2.ml.SVM_RBF,
    params={"gamma":0.3, "name": "RBF - gamma 0.3"}
)
results_df.loc[len(results_df.index)] = results

for k, v in results.items():
    print("{} media: {}".format(k, v))
print("")

print("Entrenando los modelos SVM con kernel gaussiano, gamma=0.5")
results = utils.cross_validation_svm(
    hog_descriptors, labels, svm_kernel=cv2.ml.SVM_RBF,
    params={"gamma":0.5, "name": "RBF - gamma 0.5"}
)
results_df.loc[len(results_df.index)] = results

for k, v in results.items():
    print("{} media: {}".format(k, v))
print("")

print("Entrenando los modelos SVM con kernel gaussiano, gamma=0.7")
results = utils.cross_validation_svm(
    hog_descriptors, labels, svm_kernel=cv2.ml.SVM_RBF,
    params={"gamma":0.7, "name": "RBF - gamma 0.7"}
)
results_df.loc[len(results_df.index)] = results

for k, v in results.items():
    print("{} media: {}".format(k, v))
print("")

print("Entrenando los modelos SVM con kernel gaussiano, gamma=1")
results = utils.cross_validation_svm(
    hog_descriptors, labels, svm_kernel=cv2.ml.SVM_RBF,
    params={"gamma":1, "name": "RBF - gamma 1"}
)
results_df.loc[len(results_df.index)] = results

for k, v in results.items():
    print("{} media: {}".format(k, v))
print("")

'''
vgg_images = keras.applications.vgg16.preprocess_input(images)

print("Entrenando el modelo VGG16 con validación cruzada")
results = utils.cross_validation_cnn(
    vgg_images, labels, keras.applications.VGG16
)

for k, v in results.items():
    print("{} media: {}".format(k, v[-1]))
'''
