"""
  Functions for agent-level model components
  Justin Angevaare
  File name: agents.jl
  May 2015
"""


function AgentDB(enviro::EnvironmentAssumptions)
  """
    A function which will create an empty agent_db for the specified simulation length
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

function injectAgents!(agent_db::Vector, spawn_agents::Vector, new_stock::Vector, week_num::Int64)
  """
    This function injects agents into the environment.
    For now, all agents are evenly distributed throughout the spawning areas.
  """
  @assert(length(new_stock)<=4, "There can only by four independent life stages of fish.")

  for agentRef = 1:length(agent_db) #add a new population class to every agent
    push!((agent_db[agentRef]).stageOne, 0)
    push!((agent_db[agentRef]).stageTwo, 0)
    push!((agent_db[agentRef]).stageThree, 0)
    push!((agent_db[agentRef]).stageFour, 0)
    push!((agent_db[agentRef]).weekNum, week_num)
  end

  classLength = length((agent_db[1]).weekNum)
  for fishStage = 1:length(new_stock)
    addToEach = round(Int, floor(new_stock[fishStage]/length(spawn_agents)))
    leftOver = new_stock[fishStage]%length(spawn_agents)
    randomAgent = rand(1:length(spawn_agents))
    for agentNum = 1:length(spawn_agents)
      addToAgent = addToEach
      if agentNum == randomAgent
        addToAgent += leftOver
      end

      #Unfortunately, we need to do an if conditional for each agent stage
      if fishStage == 1
        (agent_db[spawn_agents[agentNum]]).stageOne[classLength] = addToAgent
      elseif fishStage == 2
        (agent_db[spawn_agents[agentNum]]).stageTwo[classLength] = addToAgent
      elseif fishStage == 3
        (agent_db[spawn_agents[agentNum]]).stageThree[classLength] = addToAgent
      else
        (agent_db[spawn_agents[agentNum]]).stageFour[classLength] = addToAgent
      end
    end
  end

  return agent_db
end
