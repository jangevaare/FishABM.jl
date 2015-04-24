"""
Functions and types for interacting model components
Justin Angevaare
April 2015
"""

type life_map
  """
  A specialized map which contains layers of information to indicate spawning area, habitat preferability, and additional risks
  """
  id::Array
  spawning::Array
  habitat::Array
  risk1::Array
end

function spawn!(stock_db::stock_db, stock_assumptions::stock_assumptions, life_map::life_map)
  """
  This function creates a new cohort of agents based on an structured adult population, spawning area information contained in a `life_map`, and `fecundity_assumptions`.
  """
  brood_size = rand(Poisson(stock_assumptions.mean_brood_size[1]), rand(Binomial(stock_db.population[end,1], stock_assumptions.proportion_sexually_mature[1]*0.5)))
  for i = 2:length(stock_assumptions.proportion_sexually_mature)
    append!(brood_size, rand(Poisson(stock_assumptions.mean_brood_size[i]), rand(Binomial(stock_db.population[end,i], stock_assumptions.proportion_sexually_mature[i]*0.5))))
  end
  brood_location = sample(life_map.id[life_map.spawning], length(brood_size))
  return hcat(brood_size, brood_location)
end

# function graduate!(agent_db::agent_db, stock_db::stock_db, stage::integer)
  """
  This function will advance an agent currently in a specified stage to its next life stage. If this function is applied to juveniles, it will also add their information to the stock_db
  """
