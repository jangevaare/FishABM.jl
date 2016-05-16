#Refactoring all data structures used

# Load required packages
using  FishABM


"""
Combine agent and stock level functions into a simulation framework
Justin Angevaare
May 2015
File name: simulate.jl
"""

function simulate_test(carrying_capacity::Vector, effort::Vector, bump::Vector,
  initStock::Vector, e_a::EnvironmentAssumptions, a_assumpt::AdultAssumptions,
  age_assumpt::AgentAssumptions, progress=true::Bool, limit=250000::Int64)
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
  for i = 1:4
    injectAgents!(a_db, e_a.spawningHash, initStock[5-i], -age_assumpt.growth[((7-i)%4)+1])
  end

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

      #Agents are killed and moved weekly
      #kill!(a_db, e_a, a_a, y, c[w])
      #move!(a_db, a_a, e_a, y, c[w])

      if w == harvestWeek
        #harvest can be set to any week(s)
        #harvest!(harvest_effort[y], s_db, s_a)
      end
    end
    removeEmptyClass!(a_db)
    #updateAgentLocationArray!()
    #
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
adult_a = AdultAssumptions([0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.65],
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

a_a = AgentAssumptions([[0.80 0.095 0.09 0.05]
                        [0.10 0.095 0.09 0.10]
                        [0.80 0.095 0.09 0.20]
                        [0.80 0.80 0.09 0.30]
                        [0.80 0.80 0.80 0.40]
                        [0.80 0.80 0.80 0.50]],
                       [0.0, 0.0, 0.0, 0.0],
                       [19, 52, 104, 0],
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
adb = simulate_test(k, effortVar, bumpVar, initialStock, enviro_a, adult_a, a_a)

#refactor to include class population instead of each different stage

len = length(adb[enviro_a.spawningHash[1]].class)
adb[enviro_a.spawningHash[1]].alive[3]
adb[enviro_a.spawningHash[1]].weekNum[3]

#=
*****

Files, specific file headers etc

*****
=#

function localmove(location::Int, stage::Int, AgentAssumptions::AgentAssumptions, EnvironmentAssumptions::EnvironmentAssumptions)
  """
  A function which generates movement to a neighbouring location based on movement weights
  """
  @assert(0.<= AgentAssumptions.autonomy[stage] <=1., "Autonomy level must be between 0 and 1")
  # location id to coordinates
  id=ind2sub(size(EnvironmentAssumptions.habitat), location)
  # Select surrounding block of IDs, match up with weights
  choices = [sub2ind(size(EnvironmentAssumptions.habitat), [id[1]-1,id[1],id[1]+1,id[1]-1,id[1],id[1]+1,id[1]-1,id[1],id[1]+1], [id[2]-1, id[2]-1, id[2]-1, id[2], id[2], id[2], id[2]+1, id[2]+1, id[2]+1]) [AgentAssumptions.movement[stage][:]]]
  # If habitat type is 0, remove row
  choices = choices[EnvironmentAssumptions.habitat[choices[:,1]] .> 0, :]
  # Match locations with natural mortality rates
  choices = hcat(choices, 1-AgentAssumptions.naturalmortality[EnvironmentAssumptions.habitat[choices[:,1]], stage])
  # Normalize into probabilities
  choices[:,2]=choices[:,2]/sum(choices[:,2])
  choices[:,3]=choices[:,3]/sum(choices[:,3])
  # Weight options by autonomy
  return int(choices[findfirst(rand(Multinomial(1, choices[:,2]*(1-AgentAssumptions.autonomy[stage]) + choices[:,3]*(AgentAssumptions.autonomy[stage])))), 1])
end

function move!(agent_db::DataFrame, AgentAssumptions::AgentAssumptions, EnvironmentAssumptions::EnvironmentAssumptions, cohort::Int, week::Int)
  """
  This function will move agents based on stage and location
  """
  for i = 1:length(agent_db[cohort, week][:alive])
    if agent_db[cohort, week][:alive][i] > 0
      agent_db[cohort, week][:location][i] = localmove(agent_db[cohort, week][:location][i], agent_db[cohort, week][:stage][i], AgentAssumptions, EnvironmentAssumptions)
    end
  end
end

#Write a function to move! the fish of a single enviro agent
using Gadfly

#required params
agent_db = adb
agent_a = a_a
enviro_types = enviro_a.habitat
current_week = 4


#@assert(0.<= AgentAssumptions.autonomy[stage] <=1., "Autonomy level must be between 0 and 1")
lifeStages = Array(Int64, length(agent_db[1].alive)); classStages[:] = 0;
totalHeight = size(enviro_a.habitat)[1]

stageWeeks = [agent_a.growth[4], agent_a.growth[3], agent_a.growth[2], agent_a.growth[1]]

#find the age and stage of each current cohort
for m = 1:length(classStages)
  currentAge = current_week - agent_db[1].weekNum[m]
  lifeStages[m] = findCurrentStage(currentAge, agent_a.growth)
end





#For each agent
@time for n = 1:length(agent_db)
  #simply the location id of the enviro agent
  id = agent_db[n].locationID


  #id=ind2sub(size(EnvironmentAssumptions.habitat), location)

  #=# Select surrounding block of IDs, match up with weights
  #choices = [sub2ind(size(EnvironmentAssumptions.habitat), [id[1]-1,id[1],id[1]+1,id[1]-1,id[1],id[1]+1,id[1]-1,id[1],id[1]+1], [id[2]-1, id[2]-1, id[2]-1, id[2], id[2], id[2], id[2]+1, id[2]+1, id[2]+1]) [AgentAssumptions.movement[stage][:]]]
  moveChoices=[
    id-totalHeight-1, id-1, id+totalHeight-1,
    id-totalHeight, id, id+totalHeight,
    id-totalHeight+1, id+1, id+totalHeight+1]

  id=ind2sub(size(enviro_a.habitat), moveChoices[:,1])

  # If habitat type is 0, remove row
  #choices = choices[EnvironmentAssumptions.habitat[choices[:,1]] .> 0, :]
  choices = [sub2ind(
    size(enviro_a.habitat),
    [id[1]-1,id[1],id[1]+1,id[1]-1,id[1],id[1]+1,id[1]-1,id[1],id[1]+1],
    [id[2]-1, id[2]-1, id[2]-1, id[2], id[2], id[2], id[2]+1, id[2]+1, id[2]+1]), [agent_a.movement[1][:]]]

  # Match locations with natural mortality rates
  #choices = hcat(choices, 1-AgentAssumptions.naturalmortality[EnvironmentAssumptions.habitat[choices[:,1]], stage])

  # Normalize into probabilities
  #choices[:,2]=choices[:,2]/sum(choices[:,2])
  #choices[:,3]=choices[:,3]/sum(choices[:,3])=#



  #Check if the enviro agent is empty before preceeding to movement prep
  if isEmpty(agent_db[n]) == false
    #find local movement avalibility
    moveChoices=[
      id-totalHeight-1, id-1, id+totalHeight-1,
      id-totalHeight, id, id+totalHeight,
      id-totalHeight+1, id+1, id+totalHeight+1]

    #remove all non water choices
    moveChoices = moveChoices[enviro_a.habitat[moveChoices[:,1]] .> 0, :]

    #for each cohort in the agent database
    for cohort = 1:length(classStages)
      stage = lifeStages[cohort]
      choices = deepcopy(moveChoices)
      choices = hcat(choices, 1-agent_a.naturalmortality[enviro_a.habitat[choices[:,1]], stage])

      #print testing message
      #print("cohort = $cohort, currentAge = $currentAge weeks old, stage = $stage \n")

      choices[:,2]=choices[:,2]/sum(choices[:,2])

      chocOne = choices[:,2]
      one = 1-agent_a.autonomy[stage]
      partOne = chocOne*one

      chocTwo = choices[:,2+1-1]
      two = agent_a.autonomy[stage]
      partTwo = chocTwo*two

      Multinomial(1,partOne+partTwo)

      #=return int(
        choices[findfirst(
          rand(Multinomial(
            1,
            choices[:,2]*(1-AgentAssumptions.autonomy[stage]) + choices[:,3]*(AgentAssumptions.autonomy[stage])
            )
          )
        ),
        1]
      )=#
    end #for
  end #if
end




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

#Write a function to graduate the fish of a single enviro agent
function kill!_test(agent_db::DataFrame, EnvironmentAssumptions::EnvironmentAssumptions, AgentAssumptions::AgentAssumptions, cohort::Int, week::Int)
  """
    This function will kill agents based on all stage and location specific risk
    factors described in a `EnvironmentAssumptions`
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


#params, need to add the mortality summary typedef
#Requires age_db, env_a, age_a, year, week)
#Als
env_a = initEnvironment(spawnPath, habitatPath, riskPath)
age_db = AgentDB(env_a)
hashEnvironment!(age_db, env_a)


#Write a function for killing agents
