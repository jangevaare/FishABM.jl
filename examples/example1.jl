"""
example1.jl
Justin Angevaare
May 2015
"""

# LOAD REQUIRED PACKAGES
using DataFrames, Distributions, Gadfly, Fish_ABM

# STOCK ASSUMPTIONS
# Age specific mortality
# Age at 50% maturity
# Age specific fecundity
# Carrying capacity (total adults)
# Compensatory strength - fecundity
# Compensatory strength - age at 50% maturity
# Compensatory strength - adult natural mortality
# Age specific catchability
s_a = stock_assumptions([0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50],
                        5,
                        [2500, 7500, 15000, 20000, 22500, 27500, 32500],
                        500000,
                        2,
                        0.25,
                        0.5,
                        [0.00001, 0.00002, 0.000025, 0.000025, 0.000025, 0.000025, 0.000025])

# LOAD CSV FILES
# Location ID
# Spawning areas
# Habitat types
# Risk areas
e_a = environment_assumptions(readdlm(Pkg.dir("Fish_ABM")"/examples/LakeHuron_1km_id.csv", ',', Int),
                              readdlm(Pkg.dir("Fish_ABM")"/examples/LakeHuron_1km_spawning.csv", ',', Bool),
                              readdlm(Pkg.dir("Fish_ABM")"/examples/LakeHuron_1km_habitat.csv", ',', Int),
                              readdlm(Pkg.dir("Fish_ABM")"/examples/LakeHuron_1km_risk.csv", ',', Bool))

# AGENT ASSUMPTIONS
# Weekly natural mortality rate (by habitat type in the rows, and stage in the columns)
# Weekly risk mortality (by stage)
# Stage length (in weeks)
# Movement weight matrices

a_a = agent_assumptions([[0.05 0.05 0.05]
                         [0.05 0.05 0.05]],
                         [0.05, 0.05, 0.05],
                         [19, 52, 104],
                         Array[Array[[0 0 0]
                                     [0 1 0]
                                     [0 0 0]]
                               Array[[1 2 2]
                                     [1 6 2]
                                     [1 1 1]]
                               Array[[1 2 2]
                                     [1 3 2]
                                     [1 2 2]]])

# STOCK DATABASE
# Must set initial age distribution of adults
# Must create an empty dataframe for fishing mortality
s_db = stock_db(DataFrame(age_2=500000,
                           age_3=50000,
                           age_4=20000,
                           age_5=6000,
                           age_6=4000,
                           age_7=3000,
                           age_8=2000),
                 DataFrame(age_2=Int[],
                           age_3=Int[],
                           age_4=Int[],
                           age_5=Int[],
                           age_6=Int[],
                           age_7=Int[],
                           age_8=Int[]))

# SIMULATE
# Simulation length (years)
# Annual fishing effort (vector matching the simulation length)
# Stock database
# Stock assumptions
# Agent assumptions
# Environment assumptions
# Reduced output mode (true = reduced output mode, false = full output mode)
@time a_db = simulate(5, fill(0., 5), s_db, s_a, a_a, e_a, false)

# OUTPUT
# Adult age distribution through time
s_db.population
