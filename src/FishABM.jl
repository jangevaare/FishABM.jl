"""
  Module definition for an agent-based model
  Justin Angevaare, Devin Rose
  File name: agents.jl
  May 2015
"""

module FishABM

  #Gadfly is broken (Fontconfig.jl issue) but will be required later
  using Distributions, ProgressMeter

  export
    # Types
    AdultAssumptions,
    AgentAssumptions,
    ClassPopulation,
    EnviroAgent,
    EnvironmentAssumptions,

    # agent_stock_interaction.jl functions

    # agents.jl functions
    AgentDB,
    injectAgents!,
    removeEmptyClass!,

    # environment.jl functions
    hashEnvironment!,
    initEnvironment,
    pad_environment!

    # simulationResults.jl functions

    # stock.jl functions

    # utilities.jl functions

    # simulate.jl functions

    #include types in the module first, they are used in various .jl files
    include("types.jl")
    include("agent_stock_interaction.jl")
    include("agents.jl")
    include("environment.jl")
    include("simulate.jl")
    include("simulationResults.jl")
    include("stock.jl")
    include("utilities.jl")
end
