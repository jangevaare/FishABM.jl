"""
  Functions for agent-level model components
  Justin Angevaare, Devin  Rose
  File name: agents.jl
  May 2015
"""


function AgentDB(enviro::EnvironmentAssumptions)
  """
    A function which will create an empty agent_db for the specified simulation length

    Last update: March 2016
  """
  agent_db = [EnviroAgent(0)]; init = false;
  length = (size(enviro.habitat)[1])*(size(enviro.habitat)[2])
  for i = 1:length
    if enviro.habitat[i] > 0
      if init == false
        agent_db[1].locationID = i
        init = true
      else
        push!(agent_db, EnviroAgent(i))
      end
    end
  end

  return agent_db
end


#=
  Tweak this to find the current stage from the current_week and spawn_week
=#
#Add a function for getStageVector(::EnviroAgent, ::AgentAssumptions, curr_week::Int64)
function findCurrentStage(current_age::Int64, growth_age::Vector)
  """
    Description: Simple function used to find the current stage of a cohort from
    the current age using the agent assumptions growth vector.

    Last update: May 2016
  """
  #Initialize the life stage number to 4
  currentStage = 4
  q = length(growth_age)-1

  #Most cohorts are likely to be adults, thus check stages from old to young
  while q > 0 && current_age < growth_age[q]
    currentStage = q
    q-=1
  end

  return currentStage
end


function injectAgents!(agent_db::Vector, spawn_agents::Vector, new_stock::Int64, week_num::Int64)
  """
    This function injects agents into the environment.
    For now, all agents are evenly distributed throughout the spawning areas.

    Last update: April 2016
  """
  @assert(length(new_stock)<=4, "There can only by four independent life stages of fish.")

  addToEach = round(Int, floor(new_stock/length(spawn_agents)))
  leftOver = new_stock%length(spawn_agents)
  randomAgent = rand(1:length(spawn_agents))

  for agentRef = 1:length(agent_db) #add a new population class to every agent
    #push!((agent_db[agentRef]).stageOne, 0)
    #push!((agent_db[agentRef]).stageTwo, 0)
    #push!((agent_db[agentRef]).stageThree, 0)
    #push!((agent_db[agentRef]).stageFour, 0)
    push!((agent_db[agentRef]).alive, 0)
    push!((agent_db[agentRef]).weekNum, week_num)
    #push!((agent_db[agentRef]).class, ClassPopulation([0,0,0,0], week_num))
  end

  classLength = length((agent_db[1]).weekNum)
  #classLen = length((agent_db[1]).class)

  for agentNum = 1:length(spawn_agents)
    addToAgent = addToEach
    if agentNum == randomAgent
      addToAgent += leftOver
    end

    (agent_db[spawn_agents[agentNum]]).alive[classLength] = addToAgent
    #((agent_db[spawn_agents[agentNum]]).class)[classLen].stage[fishStage] = addToAgent
  end

  return agent_db
end


function removeEmptyClass!(age_db::Vector)
  """
    This function is used to remove an empty spawn class once all agents have
    been removed from the simulation.

    Last Update: March 2016
  """
  removeClass = true
  for i = 1:length(age_db)
    if (age_db[i]).alive[1] != 0
      removeClass = false
      i = length(age_db)
    end
  end

  if removeClass
    for j = 1:length(age_db)
      shift!((age_db[j]).class)
      #shift!((age_db[j]).stageOne)
      #shift!((age_db[j]).stageTwo)
      #shift!((age_db[j]).stageThree)
      #shift!((age_db[j]).stageFour)
      shift!((age_db[j]).alive)
      shift!((age_db[j]).weekNum)
    end
  end
end
