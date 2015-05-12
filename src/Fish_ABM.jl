module Fish_ABM

using DataFrames, Distributions, Gadfly

export
  # Types
  agent_assumptions
  environment_assumptions
  stock_assumptions
  stock_db

  # Agent functions
  create_agent_db
  kill!
  move!
  inject_agents!

  # Stock functions
  harvest!
  age_adults!

  # Agent-Stock function
  spawn!
  graduate!

  # Utilities
  movement_matrix

include("types.jl")
include("utilities.jl")
include("agents.jl")
include("stock.jl")
include("agent_stock_interaction.jl")
include("simulate.jl")

end # module
