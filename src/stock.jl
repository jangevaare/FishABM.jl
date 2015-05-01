"""
Functions for structured stock-level model components
Justin Angevaare
May 2015
"""

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
