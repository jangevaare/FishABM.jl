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
  Age at 50% mature (Binomial cdf assumed)
  Age specific fecundity (i.e. mean quantity of eggs each spawning female will produce)
  Carrying capacity - overall carrying capacity
  Compensatory fecundity - compensatory strength for changes in fecundity. Compensatory strength is a divisor of K which will result in a 68% change in fecundity - smaller values indicate lower compensation strength. Compensation function based on Normal CDF. Use NaN if compensation is assumed to not occur.
  Compensatory sexual maturity - compensatory strength for changes in age of sexual maturity. Compensatory strength is a divisor of K which will result in a 68% change in age of sexual maturity - smaller values indicate lower compensation strength. Compensation function based on Normal CDF. Use NaN if compensation is assumed to not occur.
  Compensatory mortality - compensatory strength for changes in age of sexual maturity. Compensatory strength is a divisor of K which will result in a 68% change in natural mortality - smaller values indicate lower compensation strength. Compensation function based on Normal CDF. Use NaN if compensation is assumed to not occur.
Age specific catachability
  """
  natural_mortality::Vector
  age_at_half_mature::Float64
  mean_brood_size::Vector
  carrying_capacity::Float64
  fecundity_compensation::Float64
  maturity_compensation::Float64
  mortality_compensation::Float64
  catchability::Vector
end
