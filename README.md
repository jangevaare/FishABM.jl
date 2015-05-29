# FishABM.jl
This package contains functions to simulate the life cycle dynamics of managed fisheries. A fish population is divided into two components: adults and pre-recruits.

Adults have age-specific survivorship, are harvested with age specific catchability, and spawn with age specific sexual maturity and fecundity. Pre-recruits graduate between several early life stages, move, and face multiple forms of stage and location specific mortality. The recruit portion of the model is a structured stock based model (specifically an age-structured model), whereas the pre-recruit portion of the model is a more detailed and computationally intensive agent based model. This simulation tool is especially well suited to investigation of spatial risks to pre-recruits in managed populations, where population level impacts may only be observable through changes in harvest.

To download and use package in Julia:

`Pkg.clone("https://github.com/jangevaa/FishABM.jl.git")`

`using FishABM`
