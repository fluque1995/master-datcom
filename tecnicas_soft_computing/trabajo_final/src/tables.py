import pandas as pd

filenames = ["results_50/function_C{}.csv".format(i+1) for i in range(30)]

dataframes = [pd.read_csv(fname, index_col=0)[['GWO', 'MFO', 'WOA']]
              for fname in filenames]

descs = [df.describe().loc[['min', '50%', 'mean', 'max', 'std']].transpose()
         for df in dataframes]

func_names = ['C{}'.format(i+1) for i in range(30)]

simple_funcs = pd.concat(descs[0:3], keys = func_names[0:3])
simple_multifuncs = pd.concat(descs[3:16], keys = func_names[3:16])
hybrid_funcs = pd.concat(descs[15:21], keys = func_names[15:21])
comp_funcs = pd.concat(descs[21:29], keys = func_names[21:29])

print(simple_funcs.to_latex(float_format="%.3f"))
print(simple_multifuncs.to_latex(float_format="%.3f"))
print(hybrid_funcs.to_latex(float_format="%.3f"))
print(comp_funcs.to_latex(float_format="%.3f"))
