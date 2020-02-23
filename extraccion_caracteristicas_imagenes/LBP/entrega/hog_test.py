import utils
import sklearn.metrics

TRAIN_IMAGES_FOLDER = "data/train"
TEST_IMAGES_FOLDER = "data/test"
IMG_EXTENSION = ".png"

print("Cargando las imágenes de entrenamiento")
train_images, train_classes = utils.load_data(TRAIN_IMAGES_FOLDER, IMG_EXTENSION)
print("Cargando las imágenes de test")
test_images, test_classes = utils.load_data(TEST_IMAGES_FOLDER, IMG_EXTENSION)

print("Calculando los descriptores HOG")
train_descriptors = utils.compute_hog(train_images)
test_descriptors = utils.compute_hog(test_images)

print("Entrenando el clasificador")
classifier = utils.train(train_descriptors, train_classes)

print("Prediciendo sobre el conjunto de test")
predictions = utils.test(test_descriptors, classifier)

print("La precisión del modelo es {0:.5f}".format(
    sklearn.metrics.accuracy_score(test_classes, predictions)
))
