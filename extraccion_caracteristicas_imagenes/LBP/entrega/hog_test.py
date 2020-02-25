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

descriptors = np.vstack((train_descriptors, test_descriptors))
labels = np.concatenate((train_classes, test_classes))

results = utils.cross_validation(descriptors, labels)

for k, v in results.items():
    print("{} media: {}".format(k, v[-1]))
