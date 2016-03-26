#Refactoring all data structures used

# Load required packages
using  FishABM



"""
Combine agent and stock level functions into a simulation framework
Justin Angevaare
May 2015
File name: simulate.jl
"""

function simulate_test(carrying_capacity::Vector, effort::Vector, bump::Vector, initStock::Vector,
    e_a::EnvironmentAssumptions, a_assumpt::AdultAssumptions,
    progress=true::Bool, limit=250000::Int64)
  """
    Brings together all of the functions necessary for a life cycle simulation
  """
  @assert(all(carrying_capacity .> 0.), "There is at least one negative carrying capacity")
  @assert(length(effort)<=length(carrying_capacity), "The effort vector must be equal or less than the length of the simulation")
  @assert(length(bump)<=length(carrying_capacity), "The bump vector must be equal or less than the length of the simulation")
  years = length(carrying_capacity)
  #initialize the agent database and hash the enviro
  a_db = AgentDB(e_a); hashEnvironment!(a_db, e_a);

  #initialize stock, and
  globalPopulation = ClassPopulation(initStock, 0)
  #could add init stock to initialize it based off of the carrying capacity, maybe 50% bump?
  injectAgents!(a_db, e_a.spawningHash, initStock, 0)

  bumpvec = fill(0, years)
  bumpvec[1:length(bump)] = bump
  harvest_effort = fill(0., years)
  harvest_effort[1:length(effort)] = effort

  #initialize the progress meter
  if progress
    totalPopulation = globalPopulation.stage[1]+globalPopulation.stage[2]+globalPopulation.stage[3]+globalPopulation.stage[4]
    progressBar = Progress(years*52, 30, " Year 1 (of $years), week 1 of simulation ($totalPopulation) fish, $(globalPopulation.stage[4]) adult fish) ", 30)
    print(" Year 1, week 1 ($(round(Int, 1/(years*52)))%) of simulation ($(globalPopulation.stage[4]) adult fish, $totalPopulation total) \n")
  end

  spawnWeek = 1; harvestWeek = 52;

  for y = 1:years
    for w = 1:52
      totalPopulation = globalPopulation.stage[1]+globalPopulation.stage[2]+globalPopulation.stage[3]+globalPopulation.stage[4]
      @assert(totalPopulation < limit, "> $limit agents in current simulation, stopping here.")

      if progress
        progressBar.desc = " Year $y (of $years), week $w of simulation ($totalPopulation) fish, $(globalPopulation.stage[4]) adult fish) "
        next!(progressBar)
        current = (y*52)+w
        if current%50 == 0
          total = (years+1)*52; percent = (current/total)*100;
          print(" Year $y, week $w ($(round(Int, percent))%) of simulation ($(globalPopulation.stage[4]) adult fish, $totalPopulation total) \n")
        end
      end

      if w == spawnWeek
        #spawning can be set to any week(s)
        #spawn!(a_db, s_db, s_a, e_a, y, carrying_capacity[y])
      end

      #Agents are killed, moved, and aged weekly
      #kill!(a_db, e_a, a_a, y, c[w])
      #move!(a_db, a_a, e_a, y, c[w])
      #graduate!(a_db, s_db, a_a, y, w, c[w])

      if w == harvestWeek
        #harvest can be set to any week(s)
        #harvest!(harvest_effort[y], s_db, s_a)
      end
    end
    removeEmptyClass!(a_db)
  end

  return a_db
end






# Specify stock assumptions:
# * s_a.naturalmortality = Age specific mortality
# * s_a.halfmature = Age at 50% maturity
# * s_a.broodsize = Age specific fecundity
# * s_a.fecunditycompensation = Compensatory strength - fecundity
# * s_a.maturitycompensation = Compensatory strength - age at 50% maturity
# * s_a.mortalitycompensation = Compensatory strength - adult natural mortality
# * s_a.catchability = Age specific catchability
s_a = StockAssumptions([0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.65],
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

spawnPath = string(split(Base.source_path(), "FishABM.jl")[1], "FishABM.jl/maps/LakeHuron_1km_spawning.csv")
habitatPath = string(split(Base.source_path(), "FishABM.jl")[1], "FishABM.jl/maps/LakeHuron_1km_habitat.csv")
riskPath = string(split(Base.source_path(), "FishABM.jl")[1], "FishABM.jl/maps/LakeHuron_1km_risk.csv")

enviro_a = initEnvironment(spawnPath, habitatPath, riskPath)



#a_db = AgentDB(e_a)
#e_a = generateEnvironment(spawnPath, habitatPath, riskPath)



# Specify agent assumptions:
# * a_a.naturalmortality =  Weekly natural mortality rate (by habitat type in the rows, and stage in the columns)
# * a_a.extramortality = Weekly risk mortality (by stage)
# * a_a.growth = Stage length (in weeks)
# * a_a.movement = Movement weight matrices
# * a_a.autonomy =  Movement autonomy

a_a = AdultAssumptions([[0.80 0.095 0.09 0.05]
                        [0.10 0.095 0.09 0.10]
                        [0.80 0.095 0.09 0.20]
                        [0.80 0.80 0.09 0.30]
                        [0.80 0.80 0.80 0.40]
                        [0.80 0.80 0.80 0.50]],
                       [0.0, 0.0, 0.0, 0.0],
                       [19, 52, 104, 1040],
                       Array[[[0. 0. 0.]
                              [0. 1. 0.]
                              [0. 0. 0.]], [[1. 2. 1.]
                                            [1. 2. 1.]
                                            [1. 1. 1.]], [[1. 2. 1.]
                                                          [1. 1. 1.]
                                                          [1. 1. 1.]], [[1. 2. 1.]
                                                                        [1. 1. 1.]
                                                                        [1. 1. 1.]]],
                       [0., 0.5, 0.75, 0.5])



# Begin life cycle simulation, specifying:
# * Year specific carrying capacity (vector length determines simulation length)
# * Annual fishing effort
# * Population bump

using Distributions
k = rand(Normal(500000, 50000), 50)
effortVar = [0]
bumpVar = [100000]
initialStock = [5000, 10000, 15000, 20000]

using ProgressMeter
adb = simulate_test(k, effortVar, bumpVar, initialStock, enviro_a)

#refactor to include class population instead of each different stage

len = length(adb[enviro_a.spawningHash[1]].class)
adb[e_a.spawningHash[1]].class[len].stage[4]

#=
*****

Files, specific file headers etc

*****
=#




"""
  FishABM.jl
  Devin Rose
  Generates an abstracted environment from bathymetry data. An
  File name: environment.jl
  Updated: March, 2016
"""


"""
  Functions for agent-level model components
  Justin Angevaare
  File name: agents.jl
  May 2015
"""


function kill!_test(agent_db::DataFrame, EnvironmentAssumptions::EnvironmentAssumptions, AgentAssumptions::AgentAssumptions, cohort::Int, week::Int)
  """
  This function will kill agents based on all stage and location specific risk factors described in a `EnvironmentAssumptions`
  """
  for i = 1:length(agent_db[cohort, week][:alive])
    if agent_db[cohort, week][:alive][i] > 0
      killed = rand(Binomial(agent_db[cohort, week][:alive][i], AgentAssumptions.naturalmortality[EnvironmentAssumptions.habitat[agent_db[cohort, week][:location][i]],agent_db[cohort, week][:stage][i]][1]))
      agent_db[cohort, week][:dead_natural][i] += killed
      agent_db[cohort, week][:alive][i] -= killed
      if agent_db[cohort, week][:alive][i] > 0
        if EnvironmentAssumptions.risk[agent_db[cohort, week][:location][i]]
          killed = rand(Binomial(agent_db[cohort, week][:alive][i], AgentAssumptions.extramortality[agent_db[cohort, week][:stage][i]][1]))
          agent_db[cohort, week][:dead_risk][i] += killed
          agent_db[cohort, week][:alive][i] -= killed
        end
      end
    end
  end
end


#params
#Requires age_db, env_a, age_a, year, week)
env_a = initEnvironment(spawnPath, habitatPath, riskPath)
age_db = AgentDB(env_a)
hashEnvironment!(age_db, env_a)


#Write a function for killing agents





#=
*****

Code testing/scripting for new functionality below

*****
=#
