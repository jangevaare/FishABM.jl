"""
  Type definitions for the structured stock-level and agent-level model components
  Justin Angevaare
  File name: types.jl
  May 2015
"""


type AdultAssumptions
  """
    Age specific survivorship (survivorship at carrying capacity if density depedence occurs)
    Age at 50% mature (Binomial cdf assumed)
    Age specific fecundity (i.e. mean quantity of eggs each spawning female will produce)
    Compensatory fecundity - compensatory strength for changes in fecundity. Compensatory strength
      is a divisor of K which will result in a 68% change in fecundity - smaller values indicate
      lower compensation strength. Compensation function based on Normal CDF. Use NaN if compensation
      is assumed to not occur.
    Compensatory sexual maturity - compensatory strength for changes in age of sexual maturity.
      Compensatory strength is a divisor of K which will result in a 68% change in age of sexual
      maturity - smaller values indicate lower compensation strength. Compensation function based on
      Normal CDF. Use NaN if compensation is assumed to not occur.
    Compensatory mortality - compensatory strength for changes in age of sexual maturity. Compensatory
      strength is a divisor of K which will result in a 68% change in natural mortality - smaller
      values indicate lower compensation strength. Compensation function based on Normal CDF. Use NaN
      if compensation is assumed to not occur.
  """
  naturalmortality::Vector
  halfmature::Float64
  broodsize::Vector
  fecunditycompensation::Float64
  maturitycompensation::Float64
  mortalitycompensation::Float64
  catchability::Vector

  StockAssumptions() = new()
  StockAssumptions(naturalmortality, halfmature, broodsize, fecunditycompensation, maturitycompensation, mortalitycompensation, catchability) =
    new(naturalmortality, halfmature, broodsize, fecunditycompensation, maturitycompensation, mortalitycompensation, catchability)
end



type ClassPopulation
  alive::Vector
  weekNum::Int64
end



type EnviroAgent
  """
    This is an "Environment agent" used to track fish population dynamics.
  """
  locationID::Int64

  stageOne::Vector
  stageTwo::Vector
  stageThree::Vector
  stageFour::Vector
  weekNum::Vector

  EnviroAgent(locationID) = new(locationID, [0], [0], [0], [0], [0])
end



type EnvironmentAssumptions
  """
    Precondition: Location id should be specified as NaN when a valid location does not exist.
    A specialized type which contains layers of information to indicate spawning area, habitat type, and additional risks.
  """
  spawning::Array
  spawningHash::Vector
  habitat::Array
  risk::Vector
  riskHash::Vector

  EnvironmentAssumptions() = new()

  EnvironmentAssumptions(spawning, spawningHash, habitat, risk, riskHash) =
  new(spawning, spawningHash, habitat, risk, riskHash)
end
