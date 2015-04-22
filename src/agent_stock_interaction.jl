"""
Functions and types for interacting model components
Justin Angevaare
April 2015
"""

type life_map
  """
  A specialized map which contains layers of information to indicate spawning area, habitat preferability, and additional risks
  """
  spawning::Array
  habitat::Array
  risk1::Array
end

#function spawn!(agent_db::agent_db, stock_db::stock_db, life_map::life_map, fecundity_assumptions)
function spawn!(stock_db::stock_db, stock_assumptions::stock_assumptions)
  """
  This function creates a new cohort of agents based on an structured adult population, spawning area information contained in a `life_map`, and `fecundity_assumptions`.
  """
  broods=rand(Poisson(stock_assumptions.mean_brood_size[1]), rand(Binomial(stock_db.population[end,1], stock_assumptions.proportion_sexually_mature[1]*0.5)))
  for i = 2:(size(stock_assumptions.proportion_sexually_mature)[1])
    append!(broods, rand(Poisson(stock_assumptions.mean_brood_size[i]), rand(Binomial(stock_db.population[end,i], stock_assumptions.proportion_sexually_mature[i]*0.5))))
    end
  return broods
end

# function graduate!(agent_db::agent_db, stock_db::stock_db, stage::integer)
  """
  This function will advance an agent currently in a specified stage to its next life stage. If this function is applied to juveniles, it will also add their information to the stock_db
  """
