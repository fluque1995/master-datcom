import os
if os.path.basename(os.getcwd()) != "GPC":
    os.chdir("extraccion_caracteristicas_imagenes/GPC")

import gpflow
import scipy.io as scio
import numpy as np

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
                'real_labels': np.concatenate(
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
            kern=gpflow.kernels.SquaredExponential(10),
            likelihood=gpflow.likelihoods.Bernoulli(),
        )

        def objective():
            return -model.log_marginal_likelihood()

        gpflow.train.ScipyOptimizer(options={'maxiter': 200}).minimize(
            model
        )

        res.append(model.predict_y(test['data'])[0])

    return np.array(res).reshape((4,-1))


healthy_folds, malign_folds = read_data("Datos.mat")
folds = build_folds(healthy_folds, malign_folds)

res = get_probs_fold(folds[0])
