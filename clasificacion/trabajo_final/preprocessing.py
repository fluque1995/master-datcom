import numpy as np
import pandas as pd
import seaborn as sb
import matplotlib.pyplot as plt

dataset = pd.read_csv("data/training.csv")
labels = pd.read_csv("data/train-labels.csv")
full_dataset = pd.merge(dataset, labels)

numeric_vars = full_dataset.select_dtypes(include=np.number)

numeric_vars = pd.merge(numeric_vars, labels)
numeric_vars.drop(columns="id", inplace=True)

categorical_vars = full_dataset.select_dtypes(exclude=np.number)

for column in numeric_vars.columns:
    if column != "status_group":
        sb.distplot(numeric_vars.loc[
            numeric_vars['status_group'] == "functional", column
        ], hist=False)
        sb.distplot(numeric_vars.loc[
            numeric_vars['status_group'] == "non functional", column
        ], hist=False)
        sb.distplot(numeric_vars.loc[
            numeric_vars['status_group'] == "functional needs repair", column
        ], hist=False)

        plt.show()

for column in categorical_vars.columns:
    if column != "status_group":
        bins = len(categorical_vars[column].unique())
        if bins < 25:
            sb.countplot(x=column, hue="status_group", data=categorical_vars)
            plt.show()
