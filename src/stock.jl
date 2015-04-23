"""
Functions and types for structured stock-level model components
Justin Angevaare
April 2015
"""

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

function age_adults!(stock_db::stock_db, stock_assumptions::stock_assumptions)
  """
  This function will apply transition probabilities to the current adult population. In the future this function may also apply annual removals due to fishing or other causes of mortality.
  """
  stock_size = fill(0, size(stock_assumptions.survivorship))
  for i = 1:(length(stock_assumptions.survivorship)-1)
    stock_size[i+1] = rand(Binomial(stock_db.population[end,i], stock_assumptions.survivorship[i]))
  end
  stock_size[end] += rand(Binomial(stock_db.population[end,end], stock_assumptions.survivorship[end]))
  push!(stock_db.population, DataArray(stock_size))
end
