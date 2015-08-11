# Load required packages

Pkg.rm("ProgressMeter")

Pkg.clone("ProgressMeter")
Pkg.add("ProgressMeter")
Pkg.dir("ProgressMeter")

Pkg.installed("ProgressMeter")
Pkg.status()

Pkg.clone("Cairo")
Pkg.add("Cairo")
Pkg.installed("Cairo")

using DataFrames, Distributions, Gadfly, FishABM


# Stock assumptions:
#  * Age specific mortality
#  * Age at 50% maturity
#  * Age specific fecundity
#  * Carrying capacity (total adults)
#  * Compensatory strength - fecundity
#  * Compensatory strength - age at 50% maturity
#  * Compensatory strength - adult natural mortality
#  * Age specific catchability

s_a = StockAssumptions([0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50],
                       5,
                       [2500, 7500, 15000, 20000, 22500, 27500, 32500],
                       2,
                       0.25,
                       1,
                       [0.00001, 0.00002, 0.000025, 0.000025, 0.000025, 0.000025, 0.000025])


# Specify environment assumptions:
# * Spawning areas
# * Habitat types
# * Risk areas

e_a = EnvironmentAssumptions(readdlm(Pkg.dir("FishABM")"/examples/LakeHuron_1km_spawning.csv", ',', Bool)[150:end, 200:370],
                             readdlm(Pkg.dir("FishABM")"/examples/LakeHuron_1km_habitat.csv", ',', Int)[150:end, 200:370],
                             readdlm(Pkg.dir("FishABM")"/examples/LakeHuron_1km_risk.csv", ',', Bool)[150:end, 200:370])

pad_environment!(e_a)


# Agent assumptions:
# * Weekly natural mortality rate (by habitat type in the rows, and stage in the columns)
# * Weekly risk mortality (by stage)
# * Stage length (in weeks)
# * Movement weight matrices
# * Movement autonomy

a_a = AgentAssumptions([[0.80 0.095 0.09]
                        [0.10 0.095 0.09]
                        [0.80 0.095 0.09]
                        [0.80 0.80 0.09]
                        [0.80 0.80 0.80]
                        [0.80 0.80 0.80]],
                        [0.0, 0.0, 0.0],
                        [19, 52, 104],
                        Array[[[0. 0. 0.]
                               [0. 1. 0.]
                               [0. 0. 0.]]
                              [[2. 8. 2.]
                               [1. 4. 2.]
                               [1. 1. 2.]]
                              [[2. 6. 2.]
                               [1. 2. 2.]
                               [1. 1. 2.]]],
                        [0., 0.2, 0.5])

a_a_withA = AgentAssumptions([[0.80 0.095 0.09]
                        [0.10 0.095 0.09]
                        [0.80 0.095 0.09]
                        [0.80 0.80 0.09]
                        [0.80 0.80 0.80]
                        [0.80 0.80 0.80]],
                        [0.15, 0.15, 0.10],
                        [19, 52, 104],
                        Array[[[0. 0. 0.]
                               [0. 1. 0.]
                               [0. 0. 0.]]
                              [[2. 8. 2.]
                               [1. 4. 2.]
                               [1. 1. 2.]]
                              [[2. 6. 2.]
                               [1. 2. 2.]
                               [1. 1. 2.]]],
                        [0., 0.2, 0.5])


# Stock database:
# * Initial population distribution
# * Empty harvest dataset

s_db = StockDB(DataFrame(age_2=100000,
                         age_3=50000,
                         age_4=40000,
                         age_5=30000,
                         age_6=20000,
                         age_7=10000,
                         age_8=100000),
               DataFrame(age_2=Int[],
                         age_3=Int[],
                         age_4=Int[],
                         age_5=Int[],
                         age_6=Int[],
                         age_7=Int[],
                         age_8=Int[]))

s_db_withA = StockDB(DataFrame(age_2=100000,
                         age_3=50000,
                         age_4=40000,
                         age_5=30000,
                         age_6=20000,
                         age_7=10000,
                         age_8=100000),
               DataFrame(age_2=Int[],
                         age_3=Int[],
                         age_4=Int[],
                         age_5=Int[],
                         age_6=Int[],
                         age_7=Int[],
                         age_8=Int[]))


# SIMULATION
#  c_c = Year specific carrying capacity (vector length determines simulation length)
#  effort = Annual fishing effort
#  bump = Population bump
# And indicating the previously specified objects:
#  s_db = Stock database
#  s_a = Stock assumptions
#  a_a = Agent assumptions
#  e_a = Environment assumptions

# simulate(c_c, effort, bump, s_db, s_a, a_a, e_a)

k = rand(Normal(500000, 50000), 1)

a_db = simulate(k, [0], [100000], s_db, s_a, a_a, e_a)
a_db_withA = simulate(k,[0], [100000], s_db_withA, s_a, a_a_withA, e_a)

simpleWriteOut(a_db, a_db_withA, k)

#currently not working
#summarizeResults = resultsSummary(a_db, k)
#summarizeResults_withA = resultsSummary(a_db_withA, k)

s_db.population
s_db_withA.population


# Visualize agent movement, specify:
year = 50
writeOutAgentPlots(a_db, a_db_withA, year, e_a)

# Visualize stock age distribution through time
stockplot = plot_stock(s_db)
stockplot_withA = plot_stock(s_db_withA)
draw(PNG(Pkg.dir("FishABM")"/examples/plots/population.png", 20cm, 15cm), stockplot)
draw(PNG(Pkg.dir("FishABM")"/examples/plots/population_withA.png", 20cm, 15cm), stockplot_withA)
