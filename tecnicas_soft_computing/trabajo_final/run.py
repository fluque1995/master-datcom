from WOA import WOA
from GWO import GWO
from MFO import MFO
from metrics import *
import pandas as pd

functions_list =[
    C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15,
    C16, C17, C18, C19, C20, C21, C22, C23, C24, C25, C26, C27, C28, C29, C30
]

pop_size = 100

for dim in [10, 30, 50]:

    for fun in functions_list:
        ## Setting parameters`
        print("Función {}".format(fun.__name__))
        params = {
            "problem_size": dim,
            "domain_range": [-100, 100],
            "objective_func": fun,
            "epochs": int(10000*dim/pop_size),
            "num_measurements": 10,
            "pop_size": pop_size,
            "verbose": False
        }

        results = pd.DataFrame(columns=["GWO", "WOA", "MFO"])

        ## Run model
        for i in range(25):
            print("Pasada {}".format(i+1))
            woa = WOA(params)
            gwo = GWO(params)
            mfo = MFO(params)
            woa_res = woa.train()[1][-1]
            gwo_res = gwo.train()[1][-1]
            mfo_res = mfo.train()[1][-1]
            results.loc[i] = {"GWO": gwo_res, "WOA": woa_res, "MFO": mfo_res}

        results.to_csv("results_{}/function_{}.csv".format(dim, fun.__name__))
