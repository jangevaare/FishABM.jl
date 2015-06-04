"""
Functions for structured stock-level model components
Justin Angevaare
May 2015
"""

function harvest!(effort::Float64, StockDB::StockDB, StockAssumptions::StockAssumptions)
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

function ageadults!(StockDB::StockDB, StockAssumptions::StockAssumptions,carryingcapacity::Float)
  """
  This function will apply transition probabilities to the current adult population. In the future this function may also apply annual removals due to fishing or other causes of mortality.
  """
  stock_size = fill(0, size(StockAssumptions.naturalmortality))
  if isnan(StockAssumptions.mortalitycompensation)
    compensation_factor = 1
  else
    compensation_factor = 2*(cdf(Normal(carryingcapacity, carryingcapacity/StockAssumptions.mortalitycompensation), sum(StockDB.population[end,:][1,])))
  end
  @assert(0.01 < compensation_factor < 1.99, "Population regulation has failed, respecify simulation parameters")
  for i = 1:(length(StockAssumptions.naturalmortality)-1)
    stock_size[i+1] = rand(Binomial(StockDB.population[end,i], 1-(StockAssumptions.naturalmortality[i]*compensation_factor)))
  end
  stock_size[end] += rand(Binomial(StockDB.population[end,end], 1-(StockAssumptions.naturalmortality[end]*compensation_factor)))
  push!(StockDB.population, DataArray(stock_size))
end
