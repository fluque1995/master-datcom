import pandas as pd
import keras
import matplotlib.pyplot as plt
import seaborn as sns
import sklearn
import numpy as np
import itertools

import sklearn.model_selection
import sklearn.preprocessing
import sklearn.metrics


# Data reading
white = pd.read_csv("winequality-white.csv", sep=";")
red = pd.read_csv("winequality-red.csv", sep=";")

# Print info
print(white.info())
print(red.info())

# Print first rows
print(red.head())
print(white.head())

# Describe dataset
print(white.describe())

# Check if there are missing values
print(pd.isnull(red).any())
print(pd.isnull(white).any())

# Figures preparation and plotting

# Histogram
fig, ax = plt.subplots(1,2)

ax[0].hist(red.alcohol, 10, facecolor='red', alpha=0.5, label="Red wine")
ax[1].hist(white.alcohol, 10, facecolor='white', ec="black", lw=0.5,
           alpha=0.5, label="White wine")

#fig.subplots_adjust(left=0, right=1, bottom=0, top=0.5, hspace=0.05, wspace=1)
ax[0].set_ylim([0,1000])
ax[0].set_xlabel("Alcohol in % vol")
ax[0].set_ylabel("Frequency")
ax[1].set_xlabel("Alcohol in % vol")
ax[1].set_ylabel("Frequency")

fig.suptitle("Distribution of Alcohol in % Vol")

plt.show()

fig, ax = plt.subplots(1,2)

ax[0].scatter(red["quality"], red["sulphates"], color='red')
ax[1].scatter(red["quality"], red["sulphates"], color='white',
              edgecolors="black", lw=0.5)

ax[0].set_title("Red wine")
ax[1].set_title("White wine")
ax[0].set_xlabel("Quality")
ax[0].set_ylabel("Sulphates")
ax[1].set_xlabel("Quality")
ax[1].set_ylabel("Sulphates")
ax[0].set_xlim([0,10])
ax[0].set_ylim([0,2.5])
ax[1].set_xlim([0,10])
ax[1].set_ylim([0,2.5])

fig.subplots_adjust(wspace=0.5)
fig.suptitle("Distribution of Alcohol in % Vol")

plt.show()

# Data preprocessing for training
red['type'] = 1
white['type'] = 0

# Datasets appending
wines = red.append(white, ignore_index=True)

# Correlation study
corr = wines.corr()
sns.heatmap(corr, xticklabels=corr.columns.values,
            yticklabels=corr.columns.values)

plt.show()

####################################################
#
#          PREDICTION - WINE TYPE
#
####################################################


# Data and labels separation
X = wines.iloc[:,0:11]
y = np.ravel(wines.type)

# Train test split
X_train, X_test, y_train, y_test = sklearn.model_selection.train_test_split(
    X, y, test_size=0.33, random_state=42
)

# Data normalization
scaler = sklearn.preprocessing.StandardScaler().fit(X_train)

X_train = scaler.transform(X_train)
X_test = scaler.transform(X_test)

def neural_network_trial(hidden_units, activation, epochs=20):
# Neural network instantiation
    model = keras.models.Sequential()

    model.add(keras.layers.Dense(hidden_units[0], input_shape=(11,),
                                 activation=activation))

    for hidden_u in hidden_units[1:]:
        model.add(keras.layers.Dense(hidden_u, activation=activation))

    model.add(keras.layers.Dense(1, activation="sigmoid"))
    model.compile(loss="binary_crossentropy",
                  optimizer="adam",
                  metrics=['accuracy']
    )

    model.fit(X_train, y_train, epochs=epochs, batch_size=1, verbose=1)

    y_pred = model.predict(X_test)
    y_pred = (y_pred > 0.5)

    conf_mat = sklearn.metrics.confusion_matrix(y_test, y_pred).ravel()
    precision = sklearn.metrics.precision_score(y_test, y_pred)
    f1_score = sklearn.metrics.f1_score(y_test, y_pred)

    return [
        hidden_units, activation,
        conf_mat[0], conf_mat[1], conf_mat[2],
        conf_mat[3], precision, f1_score
    ]

results = pd.DataFrame(
    columns=["Hidden layers", "activation",
             "TW", "FR", "FW", "TR", "Precision", "F1"]
)

results.loc[len(results)] = neural_network_trial([12,], "relu", epochs=20)
results.loc[len(results)] = neural_network_trial([12,8,4], "relu", epochs=20)
results.loc[len(results)] = neural_network_trial([12,], "tanh", epochs=20)
results.loc[len(results)] = neural_network_trial([8,4], "tanh", epochs=20)

####################################################
#
#          PREDICTION - WINE QUALITY
#
####################################################

# Data and labels separation
X = wines.iloc[:,0:11]
y = np.ravel(wines.quality) - 3

# Quality preparation to be categorical
y = keras.utils.to_categorical(y)

# Train test split
X_train, X_test, y_train, y_test = sklearn.model_selection.train_test_split(
    X, y, test_size=0.33, random_state=42
)

# Data normalization
scaler = sklearn.preprocessing.StandardScaler().fit(X_train)

X_train = scaler.transform(X_train)
X_test = scaler.transform(X_test)

def neural_network_trial(hidden_units, activation, epochs=20):
# Neural network instantiation
    model = keras.models.Sequential()

    model.add(keras.layers.Dense(hidden_units[0], input_shape=(11,),
                                 activation=activation))

    for hidden_u in hidden_units[1:]:
        model.add(keras.layers.Dense(hidden_u, activation=activation))

    model.add(keras.layers.Dense(7, activation="sigmoid"))
    model.compile(loss="categorical_crossentropy",
                  optimizer="adam",
                  metrics=['accuracy']
    )

    model.fit(X_train, y_train, epochs=epochs, batch_size=1, verbose=1)

    y_pred = model.predict(X_test)
    y_pred = np.argmax(y_pred, axis=1)

    conf_mat = sklearn.metrics.confusion_matrix(
        np.argmax(y_test, axis=1), y_pred
    )
    precision = sklearn.metrics.precision_score(
        np.argmax(y_test, axis=1), y_pred, average="micro"
    )
    f1_score = sklearn.metrics.f1_score(
        np.argmax(y_test, axis=1), y_pred, average="micro"
    )

    return [
        hidden_units, activation,
        conf_mat, precision, f1_score
    ]

res_list = []
results = pd.DataFrame(
    columns=["Hidden layers", "activation",
             "Confusion matrix", "Precision", "F1"]
)

res_list.append(neural_network_trial([12,], "relu", epochs=20))
res_list.append(neural_network_trial([12,8,4], "relu", epochs=20))
res_list.append(neural_network_trial([12,], "tanh", epochs=20))
res_list.append(neural_network_trial([8,4], "tanh", epochs=20))
