# Load required packages

using Cairo, DataFrames, Distributions, Gadfly, FishABM

# To define all parameters at the same time highlight before running

# Specify stock assumptions:
# * s_a.naturalmortality = Age specific mortality
# * s_a.halfmature = Age at 50% maturity
# * s_a.broodsize = Age specific fecundity
# * s_a.fecunditycompensation = Compensatory strength - fecundity
# * s_a.maturitycompensation = Compensatory strength - age at 50% maturity
# * s_a.mortalitycompensation = Compensatory strength - adult natural mortality
# * s_a.catchability = Age specific catchability

s_a = StockAssumptions([0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50],
                       5,
                       [2500, 7500, 15000, 20000, 22500, 27500, 32500],
                       2,
                       0.25,
                       1,
                       [0.00001, 0.00002, 0.000025, 0.000025, 0.000025, 0.000025, 0.000025])

# Specify environment assumptions:
# * e_a.spawning = Spawning areas
# * e_a.habitat = Habitat types
# * e_a.risk = Risk areas


cd()
cd(split(Base.source_path(), "simulations")[1])

if(isdir("maps") == false)
  print("directory not found. \n")
end

e_a = EnvironmentAssumptions(readdlm(split(Base.source_path(), "simulations")[1]"maps/LakeHuron_1km_spawning.csv", ',', Bool)[150:end, 200:370],
                             readdlm(split(Base.source_path(), "simulations")[1]"maps/LakeHuron_1km_habitat.csv", ',', Int)[150:end, 200:370],
                             readdlm(split(Base.source_path(), "simulations")[1]"maps/LakeHuron_1km_risk.csv", ',', Bool)[150:end, 200:370])

pad_environment!(e_a)

# Specify agent assumptions:
# * a_a.naturalmortality =  Weekly natural mortality rate (by habitat type in the rows, and stage in the columns)
# * a_a.extramortality = Weekly risk mortality (by stage)
# * a_a.growth = Stage length (in weeks)
# * a_a.movement = Movement weight matrices
# * a_a.autonomy =  Movement autonomy

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
                              [0. 0. 0.]], [[1. 2. 1.]
                                            [1. 2. 1.]
                                            [1. 1. 1.]], [[1. 2. 1.]
                                                          [1. 1. 1.]
                                                          [1. 1. 1.]]],
                       [0., 0.5, 0.75])

a_a_withA = AgentAssumptions(
a_a_withA = AgentAssumptions([[0.80 0.095 0.09]
                        [0.10 0.095 0.09]
                        [0.80 0.095 0.09]
                        [0.80 0.80 0.09]
                        [0.80 0.80 0.80]
                        [0.80 0.80 0.80]],
                        [1.0, 1.0, 1.0],
                        [19, 52, 104],
                        Array[[[0. 0. 0.]
                               [0. 1. 0.]
                               [0. 0. 0.]], [[1. 2. 2.]
                                             [1. 2. 1.]
                                             [1. 1. 1.]], [[1. 2. 2.]
                                                           [1. 1. 1.]
                                                           [1. 1. 1.]]],
                              [0., 0.5, 0.75])

# Initialize stock database:
# * s_db.population = Initial population distribution
# * s_db.harvest = Empty harvest dataset

s_db = StockDB(DataFrame(age_2=1000,
                         age_3=500,
                         age_4=400,
                         age_5=300,
                         age_6=200,
                         age_7=100,
                         age_8=1000),
               DataFrame(age_2=Int[],
                         age_3=Int[],
                         age_4=Int[],
                         age_5=Int[],
                         age_6=Int[],
                         age_7=Int[],
                         age_8=Int[]))

s_db_withA = StockDB(DataFrame(age_2=1000,
                         age_3=500,
                         age_4=400,
                         age_5=300,
                         age_6=200,
                         age_7=100,
                         age_8=1000),
               DataFrame(age_2=Int[],
                         age_3=Int[],
                         age_4=Int[],
                         age_5=Int[],
                         age_6=Int[],
                         age_7=Int[],
                         age_8=Int[]))

# Begin life cycle simulation, specifying:
# * Year specific carrying capacity (vector length determines simulation length)
# * Annual fishing effort
# * Population bump

# And indicating the previously specified objects:
# * Stock database
# * Stock assumptions
# * Agent assumptions
# * Environment assumptions

k = rand(Normal(500000, 50000),10)
reducedOutput = false

a_db_withA = simulate(k,[0], [100000], s_db_withA, s_a, a_a_withA, e_a, reducedOutput)
a_db = simulate(k, [0], [100000], s_db, s_a, a_a, e_a, reducedOutput)

#Summary of the simulation results
resultSummary = simulationSummary(a_db, a_db_withA, k, reducedOutput)
resultsToWrite = convertToStringArray(resultSummary)

cd()
cd(split(Base.source_path(), "Example")[1])
if (isdir("results") == false)
  print("Created a directory for a summary of the results. \n")
  mkdir("results")
end

if (reducedOutput == true)
  writedlm(split(Base.source_path(), "Example")[1]"results/exampleOne_stage1.csv", resultsToWrite[:, :, 1], ',')
  writedlm(split(Base.source_path(), "Example")[1]"results/exampleOne_stage2.csv", resultsToWrite[:, :, 2], ',')
  writedlm(split(Base.source_path(), "Example")[1]"results/exampleOne_stage3.csv", resultsToWrite[:, :, 3], ',')
  writedlm(split(Base.source_path(), "Example")[1]"results/reducedResults_exampleOne.csv", resultsToWrite[:, :, 4], ',')
else
  writedlm(split(Base.source_path(), "Example")[1]"results/fullResults_exampleOne.csv", resultsToWrite[:, :], ',')
end

s_db.population
s_db_withA.population

# Visualize agent movement, specify:
# * Environment assumption object
# * Agent database (as generated by simulation)
# * Cohort
showProgress = true
year = 2

writeOutAgentPlots(a_db, a_db_withA, year, e_a, showProgress)

# Visualize stock age distribution through time
stockplot = plot_stock(s_db)
stockplot_withA = plot_stock(s_db_withA)

draw(PNG(split(Base.source_path(), "simulations")[1]"plots/population.png", 20cm, 15cm), stockplot)
draw(PNG(split(Base.source_path(), "simulations")[1]"plots/population_withA.png", 20cm, 15cm), stockplot_withA)

