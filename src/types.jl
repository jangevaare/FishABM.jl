"""
Type definitions for the structured stock-level and agent-level model components
Justin Angevaare
May 2015
"""

type agent_assumptions
  """
  Assumptions regarding mortality, movement, and growth
  """
  mortality_natural::Array
  mortality_risk::Vector
  growth::Vector
  movement::Array
end

type environment_assumptions
  """
  A specialized type which contains layers of information to indicate spawning area, habitat type, and additional risks. location id should be specified as NaN when a valid location does not exist.
  """
  id::Array
  spawning::Array
  habitat::Array
  risk::Array
end

type stock_db
  """
  A database which contains population size data for each time step and adult class
  """
  population::DataFrame
  fishing_mortality::DataFrame
end

type stock_assumptions
  """
  Age specific survivorship (survivorship at carrying capacity if density depedence occurs)
  Age specific sexual maturity (i.e. percentage of females that will spawn)
  Age specific fecundity (i.e. mean quantity of eggs each spawning female will produce)
  Age specific carrying carrying_capacity (specify as NaN if density dependence does not occur).
  Age specific catachability
  """
  survivorship::Vector
  proportion_sexually_mature::Vector
  mean_brood_size::Vector
  carrying_capacity::Vector
  catchability::Vector
end
