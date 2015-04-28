module Fish_ABM

using DataFrames, Distributions, Gadfly

include("stock.jl")
include("agent_stock_interaction.jl")
include("agents.jl")
#include("simulate.jl")

end # module
