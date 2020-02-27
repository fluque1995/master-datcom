import os
if os.path.basename(os.getcwd()) != "GPC":
    os.chdir("extraccion_caracteristicas_imagenes/GPC")

import gpflow
import scipy.io as scio
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import sklearn

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

def read_data(filename):
    data = scio.loadmat(filename)

    healthy = data['Healthy_folds']
    malign = data['Malign_folds']

    healthy_folds = [healthy[0][i][0] for i in range(5)]
    malign_folds = [malign[0][i][0] for i in range(5)]

    return (healthy_folds, malign_folds)

def build_folds(healthy_data, malign_data):
    folds = []
    for i, fold in enumerate(healthy_data):
        folds.append({
            'train': {
                'healthy': [
                    healthy for j, healthy in enumerate(healthy_data) if j!=i
                ],
                'malign': np.vstack([
                    malign for j, malign in enumerate(malign_data) if j!=i
                ])
            },
            'test': {
                'data': np.vstack((fold, malign_data[i])),
                'labels': np.concatenate(
                    (-1*np.ones(fold.shape[0]),
                     np.ones(malign_data[i].shape[0]))
                )
            }
        })

    return folds

def get_probs_fold(fold):
    train = fold['train']
    test = fold['test']

    res = []
    for healthy_fold in train['healthy']:
        train_data = np.vstack((healthy_fold, train['malign']))
        train_labels = np.vstack(
            (-1*np.ones((healthy_fold.shape[0],1)),
             np.ones((train['malign'].shape[0],1)))
        )

        model = gpflow.models.VGP(
            train_data, train_labels,
            kern=gpflow.kernels.RBF(10),
            likelihood=gpflow.likelihoods.Bernoulli(),
        )

        def objective():
            return -model.log_marginal_likelihood()

        gpflow.train.ScipyOptimizer(options={'maxiter': 200}).minimize(
            model
        )

        res.append(model.predict_y(test['data'])[0])

    return np.array(res).reshape((4,-1))

def draw_roc_curve(real_labels, probs, filename):
    fpr, tpr, thresh = sklearn.metrics.roc_curve(real_labels, probs)
    auc = sklearn.metrics.roc_auc_score(real_labels, probs)

    plt.plot(fpr, tpr, color='darkorange',
             label='ROC curve (area = {:.4f})'.format(auc))
    plt.plot([0, 1], [0, 1], color='navy', linestyle='--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.legend(loc="lower right")
    plt.savefig(filename)
    plt.clf()

def draw_prc_curve(real_labels, probs, filename):
    pr, re, thresh = sklearn.metrics.roc_curve(real_labels, probs)

    plt.plot(pr, re, color='darkorange',
             label='Precision-recall curve')
    plt.plot([0, 1], [0, 1], color='navy', linestyle='--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('Precision')
    plt.ylabel('Recall')
    plt.title('Receiver operating characteristic example')
    plt.legend(loc="lower right")
    plt.savefig(filename)
    plt.clf()

def get_confusion_matrix(real_labels, probs, thr):
    pred_labels = np.int8(probs > thr)
    pred_labels[pred_labels == 0] = -1

    return sklearn.metrics.confusion_matrix(real_labels, pred_labels)

healthy_folds, malign_folds = read_data("Datos.mat")
folds = build_folds(healthy_folds, malign_folds)

confusion_matrices = []

for i, fold in enumerate(folds):
    print("Empezando fold {}".format(i))
    res = get_probs_fold(fold)
    prob_means = np.mean(res, 0)
    real_labels = fold['test']['labels']

    draw_roc_curve(
        real_labels, prob_means, "imgs/roc-fold{}.png".format(i)
    )
    draw_prc_curve(
        real_labels, prob_means, "imgs/prc-fold{}.png".format(i)
    )

    confusion_matrices.append(
        get_confusion_matrix(real_labels, prob_means, 0.5)
    )

accuracies = []
precisions = []
recalls = []
specificities = []
f1_scores = []

for mat in confusion_matrices:
    accuracies.append(accuracy(mat))
    precisions.append(precision(mat))
    recalls.append(recall(mat))
    specificities.append(specificity(mat))
    f1_scores.append(f1score(mat))

conf_matrices_flatten = np.array(confusion_matrices).reshape((5,-1))

conf_mat_df = pd.DataFrame(conf_matrices_flatten)
conf_mat_df.columns = ["TN", "FP", "FN", "TP"]
conf_mat_df.index += 1

print(conf_mat_df.to_latex())

results = pd.DataFrame(
    {
        'Accuracy (%)': np.asarray(accuracies)*100,
        'Precision (%)': np.asarray(precisions)*100,
        'Recall (%)': np.asarray(recalls)*100,
        'Specificity (%)': np.asarray(specificities)*100,
        'F1 score (%)': np.asarray(f1_scores)*100,
    }
)

results.index += 1

results.loc['Means'] = results.mean()
latex_list = results.to_latex(float_format='%.3f').replace('lrrrrr', 'lccccc').splitlines()
latex_list.insert(len(latex_list)-3, '\midrule')
latex_new = '\n'.join(latex_list)

print(latex_new)
