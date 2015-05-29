"""
Functions for structured stock-level model components
Justin Angevaare
May 2015
"""

function Harvest!(effort::Float64, StockDB::StockDB, StockAssumptions::StockAssumptions)
  """
  This function will generate fishing mortality based on a specified integer level of effort, and assumed age specific catchabilities.
  """
  harvest_size = fill(0, size(StockAssumptions.catchability))
  if effort > 0
    for i = 1:length(StockAssumptions.catchability)
      harvest_size[i] = rand(Poisson(StockDB.population[end,i]*StockAssumptions.catchability[i]*effort))
      StockDB.population[end, i] -= harvest_size[i]
    end
  end
  push!(StockDB.harvest, DataArray(harvest_size))
end

function AgeAdults!(StockDB::StockDB, StockAssumptions::StockAssumptions)
  """
  This function will apply transition probabilities to the current adult population. In the future this function may also apply annual removals due to fishing or other causes of mortality.
  """
  stock_size = fill(0, size(StockAssumptions.natural_mortality))
  if isnan(StockAssumptions.mortality_compensation)
    compensation_factor = 1
  else
    compensation_factor = 2*(cdf(Normal(StockAssumptions.carrying_capacity, StockAssumptions.carrying_capacity/StockAssumptions.mortality_compensation), sum(StockDB.population[end,:][1,])))
  end
  @assert(0.01 < compensation_factor < 1.99, "Population regulation has failed, respecify simulation parameters")
  for i = 1:(length(StockAssumptions.natural_mortality)-1)
    stock_size[i+1] = rand(Binomial(StockDB.population[end,i], 1-(StockAssumptions.natural_mortality[i]*compensation_factor)))
  end
  stock_size[end] += rand(Binomial(StockDB.population[end,end], 1-(StockAssumptions.natural_mortality[end]*compensation_factor)))
  push!(StockDB.population, DataArray(stock_size))
end
