import os
import cv2
import numpy as np

PATH_POSITIVE_TRAIN = "data/train/pedestrians/"
PATH_NEGATIVE_TRAIN = "data/train/background/"
PATH_POSITIVE_TEST = "data/test/pedestrians/"
PATH_NEGATIVE_TEST = "data/test/background/"
EXAMPLE_POSITIVE = PATH_POSITIVE_TEST + "AnnotationsPos_0.000000_crop001002d_0.png"
EXAMPLE_NEGATIVE = PATH_NEGATIVE_TEST+"AnnotationsNeg_0.000000_00000002a_0.png"
IMAGE_EXTENSION = ".png"


def ejemplo_clasificador_imagenes():
    """
    Prueba de entrenamiento de un clasificador
    """
    # Obtenemos los datos para el entrenamiento del clasificador
    training_data, classes = load_training_data()
    # Entrenamos el clasificador
    clasificador = train(training_data, classes)
    print("Clasificador entrenado")

    # Leemos imagen a clasificar
    test_data, test_classes = load_test_data()

    # Clasificamos
    preds = test_batch(test_data, clasificador)

    return preds, test_classes


def load_training_data():
    """
    Lee las imágenes de entrenamiento (positivas y negativas) y calcula sus
    descriptores para el entrenamiento.

    returns:
    np.array: numpy array con los descriptores de las imágenes leídas
    np.array: numpy array con las etiquetas de las imágenes leídas
    """
    training_data = []
    classes = []

    # Casos positivos
    counter_positive_samples = 0
    for filename in os.listdir(PATH_POSITIVE_TRAIN):
        if filename.endswith(IMAGE_EXTENSION):
            filename = PATH_POSITIVE_TRAIN+filename
            img = cv2.imread(filename)
            hog = cv2.HOGDescriptor()
            descriptor = hog.compute(img)
            training_data.append(descriptor)
            classes.append(1)
            counter_positive_samples += 1

    print("Leidas " + str(counter_positive_samples) + " imágenes de entrenamiento -> positivas")

    # Casos negativos
    counter_negative_samples = 0
    for filename in os.listdir(PATH_NEGATIVE_TRAIN):
        if filename.endswith(IMAGE_EXTENSION):
            filename = PATH_NEGATIVE_TRAIN+filename
            img = cv2.imread(filename)
            hog = cv2.HOGDescriptor()
            descriptor = hog.compute(img)
            training_data.append(descriptor)
            classes.append(0)
            counter_negative_samples += 1

    print("Leidas " + str(counter_negative_samples) + " imágenes de entrenamiento -> negativas")

    return np.array(training_data), np.array(classes)

def load_test_data():
    """
    Lee las imágenes de test (positivas y negativas)

    returns:
    test_data: Lista con las imágenes de test
    classes: numpy array con las etiquetas de las imágenes leídas
    """
    test_data = []
    classes = []

    # Casos positivos
    counter_positive_samples = 0
    for filename in os.listdir(PATH_POSITIVE_TEST):
        if filename.endswith(IMAGE_EXTENSION):
            filename = PATH_POSITIVE_TEST+filename
            img = cv2.imread(filename)
            test_data.append(img)
            classes.append(1)
            counter_positive_samples += 1

    print("Leidas " + str(counter_positive_samples) + " imágenes de entrenamiento -> positivas")

    # Casos negativos
    counter_negative_samples = 0
    for filename in os.listdir(PATH_NEGATIVE_TEST):
        if filename.endswith(IMAGE_EXTENSION):
            filename = PATH_NEGATIVE_TEST+filename
            img = cv2.imread(filename)
            test_data.append(img)
            classes.append(0)
            counter_negative_samples += 1

    print("Leidas " + str(counter_negative_samples) + " imágenes de entrenamiento -> negativas")

    return test_data, np.array(classes)


def train(training_data, classes):
    """
        Entrena el clasificador

        Parameters:
        training_data (np.array): datos de entrenamiento
        classes (np.array): clases asociadas a los datos de entrenamiento

        Returns:
        cv2.SVM: un clasificador SVM
    """
    svm = cv2.ml.SVM_create()
    svm.setType(cv2.ml.SVM_C_SVC)
    svm.setKernel(cv2.ml.SVM_LINEAR)
    svm.train(training_data, cv2.ml.ROW_SAMPLE, classes)

    return svm


def test(image, clasificador):
    """
    Clasifica la imagen pasada por parámetro

    Parameters:
    image (np.array): imagen a clasificar
    clasificador (cv2.SVM): clasificador

    Returns:
        int: clase a la que pertenece la imagen (1|0)
    """
    # HOG de la imagen a testear
    hog = cv2.HOGDescriptor()
    descriptor = hog.compute(image)
    # Clasificación
    # Devuelve una tupla donde el segundo elemento es un array
    # que contiene las predicciones (en nuestro caso solo una)
    # ej: (0.0, array([[1.]], dtype=float32))
    return int(clasificador.predict(descriptor.reshape(1, -1))[1][0][0])

def test_batch(images, classifier):
    hog = cv2.HOGDescriptor()
    descriptors = []
    for img in images:
        descriptors.append(hog.compute(img))

    descriptors = np.asarray(descriptors)

    preds = classifier.predict(descriptors)[1].flatten()

    return preds
