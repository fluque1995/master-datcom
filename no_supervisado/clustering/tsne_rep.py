import os

if os.path.basename(os.getcwd()) != 'clustering':
    os.chdir("no_supervisado/clustering")

import numpy as np
import sklearn.manifold
import sklearn.decomposition
import pandas as pd
import plotly.express as px

dataset_path = "dataset/optdigits.csv"
dims = 2

dataset = pd.read_csv(dataset_path)

x = dataset.iloc[:, :-1]
y = dataset.iloc[:, -1]

if dims == 2:
    reduced_data = sklearn.manifold.TSNE(
        n_components=2,
    ).fit_transform(x)
    df = pd.DataFrame(reduced_data, columns=["x", "y"])
    df['labels'] = y
    fig = px.scatter(df, x="x", y="y", color="labels",
                     color_continuous_scale="Portland")

if dims == 3:
    reduced_data = sklearn.manifold.TSNE(n_components=3).fit_transform(x)
    df = pd.DataFrame(reduced_data, columns=["x", "y", "z"])
    df['labels'] = y
    fig = px.scatter_3d(df, x="x", y="y", z="z", color="labels")

fig.show()
