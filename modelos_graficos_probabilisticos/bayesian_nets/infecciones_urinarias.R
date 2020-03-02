library(gRain)

## Problem list of variables and conditions definition
problem.list <- list(~FH, ~CA, ~HF, ~IB | CA:FH, ~IA | CA:HF:IB,
                     ~CB | IB, ~AO | IB:IA, ~IE |IA)

problem.network <- dagList(problem.list)

## Variables states definition
FH.st <- c("Si", "No")
CA.st <- c("Alto", "Medio", "Bajo")
HF.st <- c("Si", "No")
IB.st <- c("Si", "No")
IA.st <- c("Si", "No")
CB.st <- c("Positivo", "Negativo")
AO.st <- c("Positivo", "Negativo")
IE.st <- c("Presente", "Ausente")

## Probabilities definition
FH.CPT <- cptable(~FH, values=c(0.2, 0.8), levels=FH.st)
CA.CPT <- cptable(~CA, values=c(0.05, 0.85, 0.1), levels=CA.st)
HF.CPT <- cptable(~HF, values=c(0.3, 0.7), levels=HF.st)
IB.CPT <- cptable(
    ~IB+FH+CA,
    values=c(0.4, 0.6, 0.35, 0.65, 0.2, 0.8, 0.05, 0.95, 0.3, 0.7, 0.25, 0.75),
    levels=FH.st
)
IA.CPT <- cptable(
    ~IA+CA+HF+IB,
    values=c(0.6, 0.4, 0.5, 0.5, 0.4, 0.6, 0.35, 0.65, 0.15, 0.85, 0.35, 0.65,
             0.5, 0.5, 0.35, 0.65, 0.3, 0.7, 0.25, 0.75, 0.03, 0.97, 0.15, 0.85),
    levels=IA.st)
CB.CPT <- cptable(~CB+IB, values=c(0.97, 0.03, 0.07, 0.93), levels=CB.st)
AO.CPT <- cptable(
    ~AO+IA+IB,
    values=c(0.99, 0.01, 0.94, 0.06, 0.88, 0.12, 0.03, 0.97),
    levels=AO.st
)
IE.CPT <- cptable(~IE+IA, values=c(0.95, 0.05, 0.02, 0.98), levels=IE.st)

## Table compilation
potential.list <- compileCPT(list(FH.CPT, CA.CPT, HF.CPT, IB.CPT,
                                  IA.CPT, CB.CPT, AO.CPT, IE.CPT))

## Checking of correctness of introduced information (only one node shown)
potential.list$AO

## Creation of grain object
bayesian.network <- grain(potential.list)
bayesian.network.compiled <- compile(bayesian.network)

## Exact queries over the network (no evidence)
querygrain(bayesian.network.compiled, nodes="IA")
querygrain(bayesian.network.compiled, nodes="IB")

## Probabilities given some observations

## Evidence introduction
evidence.1 <- setEvidence(
    bayesian.network.compiled,
    nodes=c("CB", "AO"), states=c("Positivo", "Positivo")
)

## Query, both joint and marginal, for diseases (exact method)
querygrain(evidence.1, nodes = c("IA", "IB"), type = "joint")
querygrain(evidence.1, nodes = c("IA", "IB"), type = "marginal")

## Same query, using Montecarlo
## We have to transform our net to a bn.fit object from bnlearn
bnl.network <- as.bn.fit(bayesian.network.compiled)
cpquery(bnl.network, event = (IA == "Si") & (IB == "Si"),
        evidence = ((CB == "Positivo") & (AO == "Positivo")), n=10^6)

## Same query, using random sampling and table of probabilities
IAxIB <- cpdist(bnl.network, nodes = c("IA", "IB"),
                evidence = ((CB == "Positivo") & (AO == "Positivo")))
prop.table(table(IAxIB))

###########
## NEW CASE
###########

## Evidence introduction
evidence.2 <- setEvidence(
    bayesian.network.compiled,
    nodes=c("CA", "HF", "IE"), states=c("Bajo", "Si", "Presente")
)

## Query, both joint and marginal, for diseases (exact method)
querygrain(evidence.2, nodes = c("IA", "IB"), type = "joint")
querygrain(evidence.2, nodes = c("IA", "IB"), type = "marginal")

## Same query, using Montecarlo
cpquery(bnl.network, event = (IA == "Si") & (IB == "Si"),
        evidence = ((CA == "Bajo") & (HF == "Si") & (IE == "Presente")), n=10^6)

## Same query, using random sampling and table of probabilities
IAxIB <- cpdist(bnl.network, nodes = c("IA", "IB"),
                evidence = ((CA == "Bajo") & (HF == "Si") & (IE == "Presente")),
                n=10^6)
prop.table(table(IAxIB))

########################
## MORE COMPLEX EVIDENCE
########################

## In this example, exact inference with gRain is not possible due to
## evidence complexity, so only probabilistic queries are given
cpquery(bnl.network, event = (IA == "Si") & (IB == "Si"),
        evidence = ((CB == "Positivo") & (CA == "Alto")) |
            ((CA == "Bajo") & (IE == "Presente")),
        n=10^6)

## Same query, using random sampling and table of probabilities
IAxIB <- cpdist(bnl.network, nodes = c("IA", "IB"),
                evidence = ((CB == "Positivo") & (CA == "Alto")) |
                    ((CA == "Bajo") & (IE == "Presente")),
                n=10^6)
prop.table(table(IAxIB))

### D-SEPARATION

## Given no information about the other variables, causes are independent
## due to head-to-head relations
dsep(bnl.network, x="FH", y="CA")
dsep(bnl.network, x="HF", y="CA")
dsep(bnl.network, x="HF", y="FH")

## Given any other variable, d-separation gets broken
dsep(bnl.network, x="HF", y="CA", z="IA")

## Causes and consequences are dependent
dsep(bnl.network, x="HF", y="AO")

## Depending on the selected pair, the ovidence in one infection is
## not enough to establish d-separation
dsep(bnl.network, x="HF", y="AO", z=c("IB"))
dsep(bnl.network, x="HF", y="AO", z=c("IA"))

## Setting both diseases induces d-separation
dsep(bnl.network, x="HF", y="AO", z=c("IA", "IB"))
