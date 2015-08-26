"""
stock.jl
Functions for structured stock-level model components
"""

function harvest!(effort::Float64, stockdb::StockDB, stockassumptions::StockAssumptions)
  """
  This function will generate fishing mortality based on a specified integer level of effort, and assumed age specific catchabilities.
  """
  harvest_size = fill(0, size(stockassumptions.catchability))
  if effort > 0
    for i = 1:length(stockassumptions.catchability)
      harvest_size[i] = rand(Poisson(stockdb.population[end,i]*stockassumptions.catchability[i]*effort))
      stockdb.population[end, i] -= harvest_size[i]
    end
  end
  push!(stockdb.harvest, DataArray(harvest_size))
end

function ageadults!(stockdb::StockDB, stockassumptions::StockAssumptions, carryingcapacity::Float64, bump=0::Int64)
  """
  This function will apply transition probabilities to the current adult population.
  """
  stock_size = fill(0, size(stockassumptions.naturalmortality))
  if isnan(stockassumptions.mortalitycompensation)
    compensation_factor = 1
  else
    compensation_factor = 2*(cdf(Normal(carryingcapacity, carryingcapacity/stockassumptions.mortalitycompensation), sum(stockdb.population[end,:][1,])))
  end
  @assert(0.01 < compensation_factor < 1.99, "Population regulation has failed, respecify simulation parameters")
  for i = 1:(length(stockassumptions.naturalmortality)-1)
    stock_size[i+1] = rand(Binomial(stockdb.population[end,i], 1-(stockassumptions.naturalmortality[i]*compensation_factor)))
  end
  stock_size[end] += rand(Binomial(stockdb.population[end,end], 1-(stockassumptions.naturalmortality[end]*compensation_factor)))
  stock_size[1] += bump
  push!(stockdb.population, DataArray(stock_size))
end
