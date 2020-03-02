library(bnlearn)
library(gRain)

## BN creation from vertices and edges
dag <- empty.graph(nodes = c("A", "S", "E", "O", "R", "T"))

dag <- set.arc(dag, from = "A", to = "E")
dag <- set.arc(dag, from = "S", to = "E")
dag <- set.arc(dag, from = "E", to = "O")
dag <- set.arc(dag, from = "E", to = "R")
dag <- set.arc(dag, from = "O", to = "T")
dag <- set.arc(dag, from = "R", to = "T")

modelstring(dag)

## Edges speficication using modelstring
modelstring(dag) <- "[A][S][E|A:S][O|E][R|E][T|O:R]"

## Net structure inference (nodes and edges) using a function
dag3 <- model2network("[A][S][E|A:S][O|E][R|E][T|O:R]")

## Equality check
all.equal(dag, dag3)

## Nodes
nodes(dag)

## Edges (called arcs)
arcs(dag)

## Specify arcs using the arcs function
dag2 <- empty.graph(nodes = c("A", "S", "E", "O","R", "T"))
arc.set <- matrix(c("A", "E","S", "E","E", "O","E", "R","O", "T","R", "T"),
                  byrow = TRUE, ncol = 2,dimnames = list(NULL, c("from", "to")))

arcs(dag2) <- arc.set

all.equal(dag, dag2)

## As the graph must be acyclic, if we try to override this condition,
## an exception rises
try(set.arc(dag, from="T", to="E"))

## Plotting the Bayesian network
plot(dag)

## Names specification
A.st <- c("young", "adult", "old")
S.st <- c("M", "F")
E.st <- c("high", "uni")
O.st <- c("emp", "self")
R.st <- c("small", "big")
T.st <- c("car", "train", "other")

## Probabilities specification
A.prob <- array(c(0.30, 0.50, 0.20), dim=3,dimnames = list(A = A.st))
S.prob <- array(c(0.60, 0.40), dim=2, dimnames = list(S = S.st))
O.prob <- array(c(0.96, 0.04, 0.92, 0.08), dim=c(2,2),
                dimnames = list(O = O.st, E = E.st))
R.prob <- array(c(0.25, 0.75, 0.20, 0.80), dim=c(2,2),
                dimnames = list(R = R.st, E = E.st))

E.prob <- array(c(0.75, 0.25, 0.72, 0.28, 0.88, 0.12, 0.64,
                  0.36, 0.70, 0.30, 0.90, 0.10), dim=c(2, 3, 2),
                dimnames = list(E = E.st, A = A.st, S = S.st))
T.prob <- array(c(0.48, 0.42, 0.10, 0.56, 0.36, 0.08, 0.58,
                  0.24, 0.18, 0.70, 0.21, 0.09), dim=c(3, 2, 2),
                dimnames = list(T = T.st, O = O.st, R = R.st))

## Probabilities distribution list
cpt <- list(A=A.prob, S=S.prob, E=E.prob, O=O.prob, R=R.prob, T=T.prob)

## Bayesian network fitting
bn <- custom.fit(dag,cpt)

nparams(bn)
arcs(bn)

## Node exploration
bn$R

## Distribution table for a variable
R.cpt <- coef(bn$R)
R.cpt

## Bayesian network printing
bn

## Parameter estimation
survey <- read.table("survey.txt", header = TRUE)
head(survey)

## Using maximum likelihood
bn.mle <- bn.fit(dag, data=survey, method="mle")

prop.table(table(survey[, c("O", "E")]), margin=2)
bn.mle$O

## Using bayesian inference
bn.bayes <- bn.fit(dag, data = survey, method = "bayes", iss = 10)

bn.bayes$O

## Bayesian network structure learning using hill climbing
learned <- hc(survey)
modelstring(learned)

score(learned, data = survey, type = "bic")

## Learning network using other score function
learned2 <- hc(survey, score = "bde")

## Check d-separation
dsep(dag, x = "S", y = "R")
dsep(dag, x = "O", y = "R")

## Check path existence
path(dag, from = "S", to = "R")

## D-separation when conditioning
dsep(dag, x = "S", y = "R", z = "E")

## Since gRain doesn't work, new function definition
listaGRain <-list(~A, ~S, ~E | A : S, ~O | E, ~R | E, ~T | O : R)
dagGRain<-dagList(listaGRain)

A.st <- c("young", "adult", "old")
S.st <- c("M", "F")
E.st <- c("high", "uni")
O.st <- c("emp", "self")
R.st <- c("small", "big")
T.st <- c("car", "train", "other")

A.CPT <- cptable(~A, values=c(3, 5, 2), levels=A.st)
S.CPT <- cptable(~S, values=c(6, 4), levels=S.st)
O.CPT <- cptable(~O+E, values=c(96, 4, 92, 8), levels=O.st)
R.CPT <- cptable(~R+E, values=c(25, 75, 20, 80), levels=R.st)
E.CPT <- cptable(~E+A+S,
                 values=c(75, 25, 72, 28, 88, 12, 64, 36, 70, 30, 90, 10),
                 levels=E.st)
T.CPT <- cptable(~T+O+R, values=c(48, 42, 10, 56, 36, 8, 58, 24, 18, 70, 21, 9),
                 levels=T.st)

potentialList <- compileCPT(list(A.CPT, S.CPT, O.CPT, R.CPT, E.CPT, T.CPT ))

redGrain <- grain(potentialList)
junctionTreeRedGrain <- compile(redGrain)

## Probabilities query
querygrain(junctionTreeRedGrain, nodes="T")$T

## Evidence introduction
jsex <- setEvidence(junctionTreeRedGrain, nodes="S", states="F")

## Inference over network with evidence
querygrain(jsex,nodes="T")$T

## Adding evidence (again)
jres <- setEvidence(junctionTreeRedGrain, nodes = "R", states = "small")
querygrain(jres, nodes = "T")$T

## Joint probabilities
jedu <- setEvidence(junctionTreeRedGrain, nodes = "E", states = "high")
SxT.cpt <- querygrain(jedu, nodes = c("S", "T"), type = "joint")
SxT.cpt

## Marginal distributions
querygrain(jedu, nodes = c("S", "T"), type = "marginal")

## Conditional distributions
querygrain(jedu, nodes = c("S", "T"), type = "conditional")

## The result suggest independence when education is observed
dsep(bn, x = "S", y = "T", z = "E")

## Approximate inference using Monte Carlo methods
cpquery(bn, event = (S == "M") & (T == "car"), evidence = (E == "high"))

## Setting number of iterations of Monte Carlo method
cpquery(bn, event = (S == "M") & (T == "car"),
        evidence = (E == "high"), n = 10^6)

## Approximate inference by method lw
cpquery(bn, event = (S == "M") & (T == "car"),
        evidence = list(E = "high"), method = "lw")

## More complex simulations chaining conditions
cpquery(bn, event = (S == "M") & (T == "car"),
        evidence = ((A == "young") & (E == "uni")) | (A == "adult"))

## Simulate random sampling from network
SxT <- cpdist(bn, nodes = c("S", "T"), evidence = (E == "high"))

## Calculate probabilities from sample
prop.table(table(SxT))
