module FishABM

using DataFrames, Distributions, Gadfly

export
  # Types
  AgentAssumptions,
  EnvironmentAssumptions,
  StockAssumptions,
  StockDB,

  # Agent functions
  AgentDB,
  Kill!,
  LocalMovement,
  Move!,
  InjectAgents!,

  # Stock functions
  Harvest!,
  AgeAdults!,

  # Agent-Stock function
  Spawn!,
  Graduate!,

  # Utilities
  MovementMatrix,

  # Simulate
  Simulate

include("types.jl")
include("utilities.jl")
include("agents.jl")
include("stock.jl")
include("agent_stock_interaction.jl")
include("simulate.jl")

end # module
