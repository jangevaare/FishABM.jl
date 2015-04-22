"""
Functions and types for structured stock-level model components
Justin Angevaare
February 2015
"""

type stock_db
  """
  A database which contains population size data for each time step and adult class. For more complicated applications where seperate causes of mortality are being tracked for adults, this may have seperate components for each cause of removal.
  """
  population::DataFrame
  #general_mortality::Array
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

function age_adults!(stock_db::stock_db, stock_assumptions::stock_assumptions)
  """
  This function will apply transition probabilities to the current adult population. In the future this function may also apply annual removals due to fishing or other causes of mortality.
  """
  Binomial(stock_db.population[end,i], stock_assumptions.survivorship)



  append!(array(stock_db.population[:,end]) * transition_matrix.general, stock_db.population)

