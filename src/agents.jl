"""
Functions for agent-level model components
Justin Angevaare
May 2015
"""

function AgentDB(cohorts, AgentAssumptions::AgentAssumptions, reduced::Bool)
  """
  A function which will create an empty agent_db for the specified simulation length
  """
  sub_agent_db = DataFrame(cohort = DataFrame(stage=Int[], location=Int[], alive=Int[], dead_natural=Int[], dead_risk=Int[]))
  int_agent_db = hcat(sub_agent_db, sub_agent_db)
  if reduced
    columns = length(AgentAssumptions.growth)
  else
    columns = 104
  end
  for i = 1:(columns-2)
    int_agent_db=hcat(int_agent_db, sub_agent_db)
  end
  if reduced
    names!(int_agent_db, [symbol("stage_$i") for i in 1:columns])
  else
    names!(int_agent_db, [symbol("week_$i") for i in 1:columns])
  end
  agent_db = vcat(int_agent_db, int_agent_db)
  for i = 1:(cohorts-2)
    agent_db = vcat(agent_db, int_agent_db)
  end
  return agent_db
#   return int_agent_db
end

function Kill!(agent_db::DataFrame, EnvironmentAssumptions::EnvironmentAssumptions, AgentAssumptions::AgentAssumptions, cohort::Int, week::Int)
  """
  This function will kill agents based on all stage and location specific risk factors described in a `EnvironmentAssumptions`
  """
  for i = 1:length(agent_db[cohort, week][:alive])
    if agent_db[cohort, week][:alive][i] > 0
      #killed = minimum([rand(Poisson(agent_db[cohort, week][:alive][i]*AgentAssumptions.mortality_natural[EnvironmentAssumptions.habitat[agent_db[cohort, week][:location][i].==EnvironmentAssumptions.id],agent_db[cohort, week][:stage][i]][1])), agent_db[cohort, week][:alive][i]])
      killed = rand(Binomial(agent_db[cohort, week][:alive][i], AgentAssumptions.mortality_natural[EnvironmentAssumptions.habitat[agent_db[cohort, week][:location][i].==EnvironmentAssumptions.id],agent_db[cohort, week][:stage][i]][1]))
      agent_db[cohort, week][:dead_natural][i] += killed
      agent_db[cohort, week][:alive][i] -= killed
      if agent_db[cohort, week][:alive][i] > 0
        if EnvironmentAssumptions.risk[agent_db[cohort, week][:location][i].==EnvironmentAssumptions.id][1]
          #killed = minimum([rand(Poisson(agent_db[cohort, week][:alive][i]*AgentAssumptions.mortality_risk[agent_db[cohort, week][:stage][i]][1])), agent_db[cohort, week][:alive][i]])
          killed = rand(Binomial(agent_db[cohort, week][:alive][i], AgentAssumptions.mortality_risk[agent_db[cohort, week][:stage][i]][1]))
          agent_db[cohort, week][:dead_risk][i] += killed
          agent_db[cohort, week][:alive][i] -= killed
        end
      end
    end
  end
end

function LocalMovement(location, weights::Array, EnvironmentAssumptions::EnvironmentAssumptions)
  """
  A function which creates a reduced movement matrix (3,3) for any current location
  """
  # Match location id to map index
  id_ind=findn(EnvironmentAssumptions.id .== location)
  choices=[location, weights[2,2]]
  if id_ind[1][1] > 1
    if id_ind[2][1] > 1 && EnvironmentAssumptions.id[id_ind[1][1]-1, id_ind[2][1]-1] != -1
      choices = hcat(choices, [EnvironmentAssumptions.id[id_ind[1][1]-1, id_ind[2][1]-1], weights[1,1]])
    end
    if EnvironmentAssumptions.id[id_ind[1][1]-1, id_ind[2][1]] != -1
      choices = hcat(choices, [EnvironmentAssumptions.id[id_ind[1][1]-1, id_ind[2][1]], weights[1,2]])
    end
    if id_ind[2][1] < size(EnvironmentAssumptions.id, 2) && EnvironmentAssumptions.id[id_ind[1][1]-1, id_ind[2][1]+1] != -1
      choices = hcat(choices, [EnvironmentAssumptions.id[id_ind[1][1]-1, id_ind[2][1]+1], weights[1,3]])
    end
  end
  if id_ind[2][1] > 1 && EnvironmentAssumptions.id[id_ind[1][1], id_ind[2][1]-1] != -1
    choices = hcat(choices, [EnvironmentAssumptions.id[id_ind[1][1], id_ind[2][1]-1], weights[2,1]])
  end
  if id_ind[2][1] < size(EnvironmentAssumptions.id, 2) && EnvironmentAssumptions.id[id_ind[1][1], id_ind[2][1]+1] != -1
    choices = hcat(choices, [EnvironmentAssumptions.id[id_ind[1][1], id_ind[2][1]+1], weights[2,3]])
  end
  if id_ind[1][1] < size(EnvironmentAssumptions.id, 1)
    if id_ind[2][1] > 1 && EnvironmentAssumptions.id[id_ind[1][1]+1, id_ind[2][1]-1] != -1
      choices = hcat(choices, [EnvironmentAssumptions.id[id_ind[1][1]+1, id_ind[2][1]-1], weights[3,1]])
    end
    if EnvironmentAssumptions.id[id_ind[1][1]+1, id_ind[2][1]] != -1
      choices = hcat(choices, [EnvironmentAssumptions.id[id_ind[1][1]+1, id_ind[2][1]], weights[3,2]])
    end
    if id_ind[2][1] < size(EnvironmentAssumptions.id, 2) && EnvironmentAssumptions.id[id_ind[1][1]+1, id_ind[2][1]+1] != -1
      choices = hcat(choices, [EnvironmentAssumptions.id[id_ind[1][1]+1, id_ind[2][1]+1], weights[3,3]])
    end
  end
  choices[2,:] = choices[2,:]/sum(choices[2,:])
  return choices[1, find(rand(Multinomial(1, choices[2,:][:])))[1]]
end

function Move!(agent_db::DataFrame, AgentAssumptions::AgentAssumptions, EnvironmentAssumptions::EnvironmentAssumptions, cohort::Int, week::Int)
  """
  This function will move agents based on stage and location
  """
  for i = 1:length(agent_db[cohort, week][:alive])
    agent_db[cohort, week][:location][i] = LocalMovement(agent_db[cohort, week][:location][i], AgentAssumptions.movement[agent_db[cohort, week][:stage][i]], EnvironmentAssumptions)
  end
end

function InjectAgents!(agent_db::DataFrame, location::Int, size::Int, cohort::Int, week::Int)
  """
  This function will inject agents into an `agent_db` to simulate stocking efforts. These stocked agents will take their stage information from the `agent_db`
  """
  push!(agent_db[cohort,week], [maximum(agent_db[cohort,week][:stage]), location, size, 0, 0])
end
