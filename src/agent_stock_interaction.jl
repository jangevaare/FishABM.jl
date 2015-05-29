"""
Functions for interaction between the structured stock-level and agent-level model components
Justin Angevaare
May 2015
"""

function Spawn!(agent_db::DataFrame, StockDB::StockDB, StockAssumptions::StockAssumptions, EnvironmentAssumptions::EnvironmentAssumptions, cohort::Int)
  """
  This function creates a new cohort of agents based on an structured adult population, spawning area information contained in a `EnvironmentAssumptions`, and `StockAssumptions`.
  """
  if isnan(StockAssumptions.fecunditycompensation)
    compensation_factor_a = 1
  else
    compensation_factor_a = 2*(1-cdf(Normal(StockAssumptions.carryingcapacity, StockAssumptions.carryingcapacity/StockAssumptions.fecunditycompensation), sum(StockDB.population[end,:][1,])))
  end
  @assert(0.01 < compensation_factor_a < 1.99, "Population regulation has failed, respecify simulation parameters")
  if isnan(StockAssumptions.maturitycompensation)
    compensation_factor_b = 1
  else
    compensation_factor_b = 2*(cdf(Normal(StockAssumptions.carryingcapacity, StockAssumptions.carryingcapacity/StockAssumptions.maturitycompensation), sum(StockDB.population[end,:][1,])))
  end
  @assert(0.01 < compensation_factor_b < 1.99, "Population regulation has failed, respecify simulation parameters")
  brood_size = rand(Poisson(compensation_factor_a*StockAssumptions.mean_brood_size[1]), rand(Binomial(StockDB.population[end,1], cdf(Binomial(length(StockAssumptions.mean_brood_size)+2, min(1, compensation_factor_b*StockAssumptions.age_at_half_mature/(length(StockAssumptions.mean_brood_size)+2))), 2)*0.5)))
  for i = 2:length(StockAssumptions.mean_brood_size)
    append!(brood_size, rand(Poisson(compensation_factor_a*StockAssumptions.mean_brood_size[i]), rand(Binomial(StockDB.population[end,i], cdf(Binomial(length(StockAssumptions.mean_brood_size)+2, min(1, compensation_factor_b*StockAssumptions.age_at_half_mature/(length(StockAssumptions.mean_brood_size)+2))), i+1)*0.5))))
  end
  brood_location = sample(find(EnvironmentAssumptions.spawning), length(brood_size))
  agent_db[cohort,1] = DataFrame(stage=fill(1, length(brood_size)), location=brood_location, alive=brood_size, dead_natural=fill(0, length(brood_size)), dead_risk=fill(0, length(brood_size)))
  return agent_db
end

function Graduate!(agent_db::DataFrame, StockDB::StockDB, AgentAssumptions::AgentAssumptions, cohort::Int, week::Int, column::Int)
  """
  This function will advance an agent currently in a specified stage to its next life stage. If this function is applied to juveniles, it will also add their information to the StockDB
  """
  if any(AgentAssumptions.growth .== week)
    for i = 1:length(agent_db[cohort, column][:stage])
      if week == AgentAssumptions.growth[agent_db[cohort, column][:stage][i]]
        agent_db[cohort, column][:stage][i] += 1
        if week == AgentAssumptions.growth[end]
          StockDB.population[end, 1] += agent_db[cohort, column][:alive][i]
        end
      end
    end
  end
end
