from WOA import WOA
from GWO import GWO
from MFO import MFO
from metrics import *
import pandas as pd
import pickle as pkl
import plotly.express as px
import plotly.graph_objects as go

execute = False
dim = 50
fun = C30
pop_size = 100

if execute:
    params = {
        "problem_size": dim,
        "domain_range": [-100, 100],
        "objective_func": fun,
        "epochs": int(10000*dim/pop_size),
        "num_measurements": 500,
        "pop_size": pop_size,
        "verbose": False
    }

    woa_res_list = []
    gwo_res_list = []
    mfo_res_list = []

    for i in range(3):
        print("Pasada {}".format(i+1))
        woa = WOA(params)
        gwo = GWO(params)
        mfo = MFO(params)
        woa_res = woa.train()[1][:-1]
        gwo_res = gwo.train()[1][:-1]
        mfo_res = mfo.train()[1][:-1]
        woa_res_list.append(woa_res)
        gwo_res_list.append(gwo_res)
        mfo_res_list.append(mfo_res)

    pkl.dump(woa_res_list, open("woa.pkl", "wb"))
    pkl.dump(gwo_res_list, open("gwo.pkl", "wb"))
    pkl.dump(mfo_res_list, open("mfo.pkl", "wb"))
else:
    woa_res_list = pkl.load(open("woa.pkl", "rb"))
    gwo_res_list = pkl.load(open("gwo.pkl", "rb"))
    mfo_res_list = pkl.load(open("mfo.pkl", "rb"))

fig_woa = go.Figure()
x_val = list(range(len(woa_res_list[0])))
fig_woa.add_trace(go.Scatter(x=x_val, y=woa_res_list[0], name="Ejecución 1"))
fig_woa.add_trace(go.Scatter(x=x_val, y=woa_res_list[1], name="Ejecución 2"))
fig_woa.add_trace(go.Scatter(x=x_val, y=woa_res_list[2], name="Ejecución 3"))
fig_woa.update_layout(
    yaxis_type="log", title="WOA - Función {}".format(fun.__name__)
)
fig_woa.show()

fig_gwo = go.Figure()
x_val = list(range(len(gwo_res_list[0])))
fig_gwo.add_trace(go.Scatter(x=x_val, y=gwo_res_list[0], name="Ejecución 1"))
fig_gwo.add_trace(go.Scatter(x=x_val, y=gwo_res_list[1], name="Ejecución 2"))
fig_gwo.add_trace(go.Scatter(x=x_val, y=gwo_res_list[2], name="Ejecución 3"))
fig_gwo.update_layout(
    yaxis_type="log", title="GWO - Función {}".format(fun.__name__)
)
fig_gwo.show()

fig_mfo = go.Figure()
x_val = list(range(len(mfo_res_list[0])))
fig_mfo.add_trace(go.Scatter(x=x_val, y=mfo_res_list[0], name="Ejecución 1"))
fig_mfo.add_trace(go.Scatter(x=x_val, y=mfo_res_list[1], name="Ejecución 2"))
fig_mfo.add_trace(go.Scatter(x=x_val, y=mfo_res_list[2], name="Ejecución 3"))
fig_mfo.update_layout(
    yaxis_type="log", title="MFO - Función {}".format(fun.__name__)
)
fig_mfo.show()
