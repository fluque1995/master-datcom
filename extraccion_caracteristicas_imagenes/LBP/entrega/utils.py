import os
import cv2
import numpy as np
import LBP as LBP
import sklearn.model_selection
import sklearn.metrics

def accuracy(conf_mat):
    return (conf_mat[0,0] + conf_mat[1,1]) / np.sum(conf_mat)

def precision(conf_mat):
    return conf_mat[1,1] / np.sum(conf_mat[:,1])

def recall(conf_mat):
    return conf_mat[1,1] / np.sum(conf_mat[1,:])

def specificity(conf_mat):
    return conf_mat[0,0] / np.sum(conf_mat[0,:])

def f1score(conf_mat):
    pr = precision(conf_mat)
    rc = recall(conf_mat)
    return 2*pr*rc / (pr + rc)

def load_data(root_path, img_extension):
    """
    Lee las imágenes de entrenamiento (positivas y negativas) y calcula sus
    descriptores para el entrenamiento.

    returns:
    np.array: numpy array con los descriptores de las imágenes leídas
    np.array: numpy array con las etiquetas de las imágenes leídas
    """
    images = []
    classes = []

    # Casos positivos
    positive_path = os.path.join(root_path, "pedestrians")
    counter_positive_samples = 0
    for filename in os.listdir(positive_path):
        if filename.endswith(img_extension):
            filename = os.path.join(positive_path, filename)
            img = cv2.imread(filename)
            images.append(img)
            classes.append(1)
            counter_positive_samples += 1

    print("Leidas {} imágenes de la clase positiva".format(
        counter_positive_samples
    ))

    # Casos negativos
    negative_path = os.path.join(root_path, "background")
    counter_negative_samples = 0
    for filename in os.listdir(negative_path):
        if filename.endswith(img_extension):
            filename = os.path.join(negative_path, filename)
            img = cv2.imread(filename)
            images.append(img)
            classes.append(0)
            counter_negative_samples += 1

    print("Leidas {} imágenes de la clase negativa".format(
        counter_negative_samples
    ))

    return images, np.array(classes)

def compute_hog(img_list):
    hog_list = []
    hog = cv2.HOGDescriptor()

    for img in img_list:
        hog_list.append(hog.compute(img))

    return np.array(hog_list)

def compute_lbp(img_list, uniform = False):
    lbp = LBP.LBPDescriptor(8,8,16,16,128,64,uniform)
    lbp_list = [lbp.compute(img) for img in img_list]

    return np.array(lbp_list)

def train(training_data, classes, kernel = cv2.ml.SVM_LINEAR, params = None):
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
    svm.setKernel(kernel)
    if params is not None:
        if "degree" in params.keys():
            svm.setDegree(params["degree"])
        if "gamma" in params.keys():
            svm.setGamma(params["gamma"])
    svm.train(training_data, cv2.ml.ROW_SAMPLE, classes)

    return svm

def test(descriptors, classifier):
    preds = classifier.predict(descriptors)[1].flatten()
    return preds

def cross_validation(dataset, labels, k = 5, svm_kernel = cv2.ml.SVM_LINEAR,
                     params = None):
    skf = sklearn.model_selection.StratifiedKFold(
        n_splits=k, shuffle=True, random_state=0
    )

    ## Listas de resultados vacías
    accs, prs, rcs, specs, f1s = [], [], [], [], []

    ## Repetimos la clasificación para cada split
    for train_index, test_index in skf.split(dataset, labels):
        train_desc, train_labs = dataset[train_index], labels[train_index]
        test_desc, test_labs = dataset[test_index], labels[test_index]

        classifier = train(train_desc, train_labs, svm_kernel, params)
        predictions = test(test_desc, classifier)

        conf_mat = sklearn.metrics.confusion_matrix(test_labs, predictions)

        accs.append(accuracy(conf_mat))
        prs.append(precision(conf_mat))
        rcs.append(recall(conf_mat))
        specs.append(specificity(conf_mat))
        f1s.append(f1score(conf_mat))

    accs.append(np.mean(accs))
    prs.append(np.mean(prs))
    rcs.append(np.mean(rcs))
    specs.append(np.mean(specs))
    f1s.append(np.mean(f1s))

    return {
        "Accuracy": accs, "Precision": prs, "Recall": rcs,
        "Specificity": specs, "F1": f1s
    }
