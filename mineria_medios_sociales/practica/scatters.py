import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

dataset = pd.read_csv("measurements.csv")

ax = sns.lmplot('closnesscentrality', # Horizontal axis
           'Degree', # Vertical axis
           data=dataset, # Data source
           fit_reg=False, # Don't fix a regression line
           size = 10,
           aspect =2 ) # size and dimension

# Set x-axis label
plt.xlabel('Cercanía')
# Set y-axis label
plt.ylabel('Grado')


def label_point(x, y, val, ax):
    a = pd.concat({'x': x, 'y': y, 'val': val}, axis=1)
    a = a.sort_values(by="y", ascending=False)
    for i, point in a.iloc[:11,].iterrows():
        if i % 2 == 1:
            ax.text(point['x']-.075, point['y'], str(point['val']), fontsize=10)
        else:
            if i % 4 == 0 or i == 14:
                ax.text(point['x']+0.008, point['y'], str(point['val']), fontsize=10)
            else:
                ax.text(point['x']+0.008, point['y']-5, str(point['val']), fontsize=10)

label_point(dataset.closnesscentrality, dataset.Degree, dataset.Label, plt.gca())

plt.show()
