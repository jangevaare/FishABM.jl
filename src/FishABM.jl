module FishABM

using DataFrames, Distributions, Gadfly, ProgressMeter, Interact

export
  # Types
  AgentAssumptions,
  EnvironmentAssumptions,
  StockAssumptions,
  StockDB,

  # Agent functions
  AgentDB,
  Kill!,
  LocalMove,
  Move!,
  InjectAgents!,

  # Stock functions
  Harvest!,
  AgeAdults!,

  # Agent-Stock function
  Spawn!,
  Graduate!,

  # Utilities
  PadEnvironmentAssumptions!,
  agent_visualize,

  # Simulate
  Simulate

include("types.jl")
include("utilities.jl")
include("agents.jl")
include("stock.jl")
include("agent_stock_interaction.jl")
include("simulate.jl")

end # module
