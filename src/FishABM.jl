
module FishABM

  #Gadfly is broken but will be required later
  using Distributions, ProgressMeter

  export
    # Types
    AdultAssumptions,
    ClassPopulation,
    EnviroAgent,
    EnvironmentAssumptions,

    # agent_stock_interaction.jl functions

    # agents.jl functions
    AgentDB,
    injectAgents!,

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
    include("environment.jl")
    include("utilities.jl")
    include("agents.jl")
    include("stock.jl")
    include("agent_stock_interaction.jl")
    include("simulate.jl")
    include("simulationResults.jl")
end
