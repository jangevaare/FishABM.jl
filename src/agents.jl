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
      #killed = minimum([rand(Poisson(agent_db[cohort, week][:alive][i]*AgentAssumptions.naturalmortality[EnvironmentAssumptions.habitat[agent_db[cohort, week][:location][i].==EnvironmentAssumptions.id],agent_db[cohort, week][:stage][i]][1])), agent_db[cohort, week][:alive][i]])
      killed = rand(Binomial(agent_db[cohort, week][:alive][i], AgentAssumptions.naturalmortality[EnvironmentAssumptions.habitat[agent_db[cohort, week][:location][i]],agent_db[cohort, week][:stage][i]][1]))
      agent_db[cohort, week][:dead_natural][i] += killed
      agent_db[cohort, week][:alive][i] -= killed
      if agent_db[cohort, week][:alive][i] > 0
        if EnvironmentAssumptions.risk[agent_db[cohort, week][:location][i]]
          #killed = minimum([rand(Poisson(agent_db[cohort, week][:alive][i]*AgentAssumptions.extramortality[agent_db[cohort, week][:stage][i]][1])), agent_db[cohort, week][:alive][i]])
          killed = rand(Binomial(agent_db[cohort, week][:alive][i], AgentAssumptions.extramortality[agent_db[cohort, week][:stage][i]][1]))
          agent_db[cohort, week][:dead_risk][i] += killed
          agent_db[cohort, week][:alive][i] -= killed
        end
      end
    end
  end
end

function LocalMove(location::Int, stage::Int, AgentAssumptions::AgentAssumptions, EnvironmentAssumptions::EnvironmentAssumptions)
  """
  A function which generates movement to a neighbouring location based on movement weights
  """
  @assert(0.<= AgentAssumptions.autonomy[stage] <=1., "Autonomy level must be between 0 and 1")
  # location id to coordinates
  id=ind2sub(size(EnvironmentAssumptions.habitat), location)
  # Select surrounding block of IDs, match up with weights
  choices = [sub2ind(size(EnvironmentAssumptions.habitat), [id[1]-1,id[1],id[1]+1,id[1]-1,id[1],id[1]+1,id[1]-1,id[1],id[1]+1], [id[2]-1, id[2]-1, id[2]-1, id[2], id[2], id[2], id[2]+1, id[2]+1, id[2]+1]) [AgentAssumptions.movement[stage,:,:][:]]]
  # If habitat type is 0, remove row
  choices = choices[EnvironmentAssumptions.habitat[choices[:,1]] .> 0, :]
  # Match locations with natural mortality rates
  choices = hcat(choices, AgentAssumptions.naturalmortality[EnvironmentAssumptions.habitat[choices[:,1]], stage])
  # Normalize into probabilities
  choices[:,2]=choices[:,2]/sum(choices[:,2])
  choices[:,3]=choices[:,3]/sum(choices[:,3])
  # Weight options by autonomy
  return int(choices[findfirst(rand(Multinomial(1, choices[:,2]*(1-AgentAssumptions.autonomy[stage]) + choices[:,3]*(1-AgentAssumptions.autonomy[stage])))), 1])
end

function Move!(agent_db::DataFrame, AgentAssumptions::AgentAssumptions, EnvironmentAssumptions::EnvironmentAssumptions, cohort::Int, week::Int)
  """
  This function will move agents based on stage and location
  """
  for i = 1:length(agent_db[cohort, week][:alive])
    if agent_db[cohort, week][:alive][i] > 0
      agent_db[cohort, week][:location][i] = LocalMove(agent_db[cohort, week][:location][i], agent_db[cohort, week][:stage][i], AgentAssumptions, EnvironmentAssumptions)
    end
  end
end

function InjectAgents!(agent_db::DataFrame, location::Int, size::Int, cohort::Int, week::Int)
  """
  This function will inject agents into an `agent_db` to simulate stocking efforts. These stocked agents will take their stage information from the `agent_db`
  """
  push!(agent_db[cohort,week], [maximum(agent_db[cohort,week][:stage]), location, size, 0, 0])
end
