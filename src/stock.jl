"""
Functions for structured stock-level model components
Justin Angevaare
May 2015
"""

function harvest!(effort::Float64, stock_db::stock_db, stock_assumptions::stock_assumptions)
  """
  This function will generate fishing mortality based on a specified integer level of effort, and assumed age specific catchabilities.
  """
  harvest_size = fill(0, size(stock_assumptions.catchability))
  if effort > 0
    for i = 1:length(stock_assumptions.catchability)
      harvest_size[i] = rand(Poisson(stock_db.population[end,i]*stock_assumptions.catchability[i]*effort))
      stock_db.population[end, i] -= harvest_size[i]
    end
  end
  push!(stock_db.fishing_mortality, DataArray(harvest_size))
end

function age_adults!(stock_db::stock_db, stock_assumptions::stock_assumptions)
  """
  This function will apply transition probabilities to the current adult population. In the future this function may also apply annual removals due to fishing or other causes of mortality.
  """
  stock_size = fill(0, size(stock_assumptions.natural_mortality))
  if isnan(stock_assumptions.mortality_compensation)
    compensation_factor = 1
  else
    compensation_factor = 2*(cdf(Normal(stock_assumptions.carrying_capacity, stock_assumptions.carrying_capacity/stock_assumptions.mortality_compensation), sum(stock_db.population[end,:][1,])))
  end
  @assert(0.01 < compensation_factor < 1.99, "Population regulation has failed, respecify simulation parameters")
  for i = 1:(length(stock_assumptions.natural_mortality)-1)
    stock_size[i+1] = rand(Binomial(stock_db.population[end,i], 1-(stock_assumptions.natural_mortality[i]*compensation_factor)))
  end
  stock_size[end] += rand(Binomial(stock_db.population[end,end], 1-(stock_assumptions.natural_mortality[end]*compensation_factor)))
  push!(stock_db.population, DataArray(stock_size))
end
