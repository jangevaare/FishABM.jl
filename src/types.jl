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
  A database which contains population size data for each time step and adult class. For more complicated applications where seperate causes of mortality are being tracked for adults, this may have seperate components for each cause of removal.
  """
  population::DataFrame
  #natural_mortality::Array
  #fishing_mortality::Array
end

type stock_assumptions
  """
  Age specific survivorship
  Age specific sexual maturity (i.e. percentage of females that will spawn)
  Age specific fecundity (i.e. mean quantity of eggs each spawning female will produce)
  """
  survivorship::Vector
  proportion_sexually_mature::Vector
  mean_brood_size::Vector
end
