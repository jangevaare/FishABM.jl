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
  stock_size = fill(0, size(stock_assumptions.survivorship))
  for i = 1:(length(stock_assumptions.survivorship)-1)
    if isnan(stock_assumptions.carrying_capacity[i])
      stock_size[i+1] = rand(Binomial(stock_db.population[end,i], stock_assumptions.survivorship[i]))
    else
      stock_size[i+1] = rand(Binomial(stock_db.population[end,i], stock_assumptions.survivorship[i]*max(0,(1-(stock_db.population[end,i]/stock_assumptions.carrying_capacity[i])))))
    end
  end
  if isnan(stock_assumptions.carrying_capacity[end])
    stock_size[end] += rand(Binomial(stock_db.population[end,end], stock_assumptions.survivorship[end]))
  else
    stock_size[end] += rand(Binomial(stock_db.population[end,end], stock_assumptions.survivorship[end]*max(0,(1-(stock_db.population[end,end]/stock_assumptions.carrying_capacity[end])))))
  end
  push!(stock_db.population, DataArray(stock_size))
end
