// Bayesian Network
//   Elvira format 

bnet  "Infecciones_urinarias" { 

// Network Properties

kindofgraph = "directed";
title = "Inferriones urinarias";
author = "Francisco Luque Sánchez";
visualprecision = "0.00";
version = 1.0;
default node states = (present , absent);

// Variables 

node Falta_de_Higiene(finite-states) {
title = "FH";
kind-of-node = chance;
type-of-variable = finite-states;
pos_x =163;
pos_y =87;
relevance = 7.0;
purpose = "";
num-states = 2;
states = ("yes" "no");
}

node Consumo_de_agua(finite-states) {
title = "CA";
kind-of-node = chance;
type-of-variable = finite-states;
pos_x =403;
pos_y =81;
relevance = 7.0;
purpose = "";
num-states = 3;
states = ("high" "medium" "low");
}

node Historial_familiar(finite-states) {
title = "HF";
kind-of-node = chance;
type-of-variable = finite-states;
pos_x =658;
pos_y =89;
relevance = 7.0;
purpose = "";
num-states = 2;
states = ("yes" "no");
}

node Infección_en_las_vías_bajas(finite-states) {
title = "IB";
kind-of-node = chance;
type-of-variable = finite-states;
pos_x =228;
pos_y =201;
relevance = 7.0;
purpose = "";
num-states = 2;
states = ("yes" "no");
}

node Infección_de_las_vías_altas(finite-states) {
title = "IA";
kind-of-node = chance;
type-of-variable = finite-states;
pos_x =555;
pos_y =254;
relevance = 7.0;
purpose = "";
num-states = 2;
states = ("yes" "no");
}

node cultivo_de_la_biopsia(finite-states) {
title = "CB";
kind-of-node = chance;
type-of-variable = finite-states;
pos_x =155;
pos_y =369;
relevance = 7.0;
purpose = "";
num-states = 2;
states = ("positive" "negative");
}

node Análisis_de_orina(finite-states) {
title = "AO";
kind-of-node = chance;
type-of-variable = finite-states;
pos_x =388;
pos_y =364;
relevance = 7.0;
purpose = "";
num-states = 2;
states = ("positive" "negative");
}

node Inflamación_en_la_ecografía(finite-states) {
title = "IE";
kind-of-node = chance;
type-of-variable = finite-states;
pos_x =669;
pos_y =363;
relevance = 7.0;
purpose = "";
num-states = 2;
states = ("present" "absent");
}

// Links of the associated graph:

link Consumo_de_agua Infección_de_las_vías_altas;

link Consumo_de_agua Infección_en_las_vías_bajas;

link Falta_de_Higiene Infección_en_las_vías_bajas;

link Historial_familiar Infección_de_las_vías_altas;

link Infección_de_las_vías_altas Análisis_de_orina;

link Infección_de_las_vías_altas Inflamación_en_la_ecografía;

link Infección_en_las_vías_bajas Análisis_de_orina;

link Infección_en_las_vías_bajas Infección_de_las_vías_altas;

link Infección_en_las_vías_bajas cultivo_de_la_biopsia;

//Network Relationships: 

relation Falta_de_Higiene { 
comment = "";
kind-of-relation = potential;
deterministic=false;
values= table (0.2 0.8 );
}

relation Consumo_de_agua { 
comment = "";
kind-of-relation = potential;
deterministic=false;
values= table (0.05 0.85 0.1 );
}

relation Historial_familiar { 
comment = "";
kind-of-relation = potential;
deterministic=false;
values= table (0.3 0.7 );
}

relation Infección_en_las_vías_bajas Falta_de_Higiene Consumo_de_agua { 
comment = "";
kind-of-relation = potential;
deterministic=false;
values= table (0.4 0.2 0.3 0.35 0.05 0.25 0.6 0.8 0.7 0.65 0.95 0.75 );
}

relation Infección_de_las_vías_altas Consumo_de_agua Historial_familiar Infección_en_las_vías_bajas { 
comment = "";
kind-of-relation = potential;
deterministic=false;
values= table (0.6 0.5 0.35 0.25 0.5 0.35 0.15 0.03 0.4 0.3 0.35 0.15 0.4 0.5 0.65 0.75 0.5 0.65 0.85 0.97 0.6 0.7 0.65 0.85 );
}

relation Inflamación_en_la_ecografía Infección_de_las_vías_altas { 
comment = "";
kind-of-relation = potential;
deterministic=false;
values= table (0.95 0.02 0.05 0.98 );
}

relation cultivo_de_la_biopsia Infección_en_las_vías_bajas { 
comment = "";
kind-of-relation = potential;
deterministic=false;
values= table (0.97 0.07 0.03 0.93 );
}

relation Análisis_de_orina Infección_en_las_vías_bajas Infección_de_las_vías_altas { 
comment = "";
kind-of-relation = potential;
deterministic=false;
values= table (0.99 0.94 0.88 0.03 0.01 0.06 0.12 0.97 );
}

}
