"""
Tools/utilities to improve ease of use of Fish_ABM.jl
Justin Angevaare
May 2015
"""

function pad_environment!(EnvironmentAssumptions::EnvironmentAssumptions)
  """
  A basic utility function which will pad the EnvironmentAssumptions such that bounds errors do not occur when performing movement
  """
  a = fill(false, (size(EnvironmentAssumptions.spawning, 1)+2, size(EnvironmentAssumptions.spawning, 2)+2))
  a[2:end-1, 2:end-1] = EnvironmentAssumptions.spawning
  EnvironmentAssumptions.spawning = a
  a = fill(0, (size(EnvironmentAssumptions.habitat, 1)+2, size(EnvironmentAssumptions.habitat, 2)+2))
  a[2:end-1, 2:end-1] = EnvironmentAssumptions.habitat
  EnvironmentAssumptions.habitat = a
  a = fill(false, (size(EnvironmentAssumptions.risk, 1)+2, size(EnvironmentAssumptions.risk, 2)+2))
  a[2:end-1, 2:end-1] = EnvironmentAssumptions.risk
  EnvironmentAssumptions.risk = a
  return EnvironmentAssumptions
end

function plot_agents(e_a::EnvironmentAssumptions, a_db::DataFrame, cohort::Int, progress=true::bool)
  """
  Create an interactive visualization of an agent database with IJulia
  """
  @assert(1 <= cohort <= size(a_db,1), "Invalid cohort specified")
  @assert(size(a_db,2) == 104, "Require full agent database output")
  # Generate a simple map of the lake
  y, x = ind2sub(size(e_a.habitat), 1:prod(size(e_a.habitat)))
  water = find(e_a.habitat .> 0)
  df = DataFrame(x=x, y=y, value=0.)
  if progress
    progressbar = Progress(104, 2, "Generating plots...", 30)
  end
  # Generate cohort specific dataset
  # Initialize with week 1...
  for i = 1:size(a_db[cohort,1],1)
    df[a_db[cohort,1][:location][i], 3] += a_db[cohort,1][:alive][i]
  end

  # Find relative abundance (1 is max)
  df[:value] /= maximum(df[:value])

  newplot = plot(df[water,:],
                 x="x",
                 y="y",
                 color="value",
                 Coord.cartesian(yflip=true),
                 Scale.color_continuous(minvalue=0, maxvalue=1),
                 Scale.x_continuous,
                 Scale.y_continuous,
                 Geom.rectbin,
                 Stat.identity,
                 Guide.xlabel(nothing),
                 Guide.ylabel(nothing),
                 Guide.colorkey("Relative Abundance"),
                 Theme(panel_opacity=1.,
                       panel_fill=color("white"),
                       background_color=color("white"),
                       key_position = :none))
  week_plots = [newplot]
  if progress
    next!(progressbar)
  end
  # Calculate for the remaining weeks
  for w = 2:104
    df = DataFrame(x=x, y=y, value=0.)
    for i = 1:size(a_db[cohort,w],1)
      df[a_db[cohort,w][:location][i], 3] += a_db[cohort,w][:alive][i]
    end

    # Find relative abundance (1 is max)
    df[:value] /= maximum(df[:value])

    newplot = plot(df[water,:],
                 x="x",
                 y="y",
                 color="value",
                 Coord.cartesian(yflip=true),
                 Scale.color_continuous(minvalue=0, maxvalue=1),
                 Scale.x_continuous,
                 Scale.y_continuous,
                 Geom.rectbin,
                 Stat.identity,
                 Guide.xlabel(nothing),
                 Guide.ylabel(nothing),
                 Guide.colorkey("Relative Abundance"),
                 Theme(panel_opacity=1.,
                       panel_fill=color("white"),
                       background_color=color("white"),
                       key_position = :none))
    push!(week_plots, newplot)
    if progress
      next!(progressbar)
    end
  end
  return week_plots
end

function plot_stock(stockdb::StockDB)
  """
  Create an area plot of the adult population
  """
  groupnames = names(stockdb.population)
  stockarray = array(stockdb.population)
  stockarray = hcat(fill(0,size(stockarray,1)), cumsum(stockarray,2))
  x=Float64[]
  y=Float64[]
  z=ASCIIString[]
  for i = 2:size(stockarray, 2)
    append!(x, [1:size(stockarray, 1), reverse(1:size(stockarray, 1))])
    append!(y, [stockarray[:,i],reverse(stockarray[:,i-1])])
    j=i-1
    append!(z, fill(string(groupnames[i-1]), size(stockarray, 1)*2))
  end
  x=x-1
  return plot(x=x,
              y=y,
              group=z,
              color=z,
              Guide.colorkey(" "),
              Guide.xlabel("Year"),
              Guide.ylabel("Abundance"),
              Geom.polygon(preserve_order=true, fill=true),
              Scale.x_continuous(minvalue=1, maxvalue=size(stockarray,1)),
              Theme(panel_opacity=1.,
                    panel_fill=color("white"),
                    background_color=color("white")))
end

function plot_stock_k(stockdb::StockDB, k::Vector, layered=true::Bool)
  """
  Create an area plot of the adult population and the carrying capacity
  """
  groupnames = names(stockdb.population)
  stockarray = array(stockdb.population)
  stockarray = hcat(fill(0,size(stockarray,1)), cumsum(stockarray,2))
  x=Float64[]
  y=Float64[]
  z=ASCIIString[]
  for i = 2:size(stockarray, 2)
    append!(x, [1:size(stockarray, 1), reverse(1:size(stockarray, 1))])
    append!(y, [stockarray[:,i],reverse(stockarray[:,i-1])])
    j=i-1
    append!(z, fill(string(groupnames[i-1]), size(stockarray, 1)*2))
  end
  x=x-1
  if layered
    return plot(layer(x=x,
                      y=y,
                      group=z,
                      color=z,
                      Geom.polygon(preserve_order=true, fill=true),
                      order=2),
                layer(x=x,
                      y=k,
                      Geom.line,
                      order=1),
                Guide.colorkey(" "),
                Guide.xlabel("Year"),
                Guide.ylabel("Abundance/Carrying Capacity"),
                Theme(panel_opacity=1.,
                      panel_fill=color("white"),
                      background_color=color("white")))
  else
    p1 = plot(x=x,
              y=y,
              group=z,
              color=z,
              Guide.colorkey(" "),
              Guide.xlabel("Year"),
              Guide.ylabel("Abundance"),
              Geom.polygon(preserve_order=true, fill=true),
              Scale.y_continuous(minvalue=0, maxvalue=maximum(k)),
              Theme(panel_opacity=1.,
                    panel_fill=color("white"),
                    background_color=color("white")))
    p2 = plot(x=x,
              y=k,
              Geom.line,
              Guide.xlabel("Year"),
              Guide.ylabel("Carrying capacity"),
              Theme(panel_opacity=1.,
                    panel_fill=color("white"),
                    background_color=color("white")))
    return hstack(p2,p1)
  end
end

function simpleWriteOut(agent_db::DataFrame, agent_db_withA::DataFrame, carryingCapacity::Vector)
  anthroAgentEffects = Array(Int64, length(carryingCapacity)+1, 9)

  totalYears = length(carryingCapacity)

  #set all entries to 0
  for i = 1:size(anthroAgentEffects)[1]
    for j = 1:size(anthroAgentEffects)[2]
      anthroAgentEffects[i, j] = 0
    end
  end

  for stage = 1:3
    for year = 1:length(carryingCapacity)
      anthroAgentEffects[year+1, 1] = year

      #without anthro
      for agent = 1:length(a_db[stage][year][1])-1
        anthroAgentEffects[year+1, 2] += agent_db[stage][year][3][agent] #alive
        anthroAgentEffects[year+1, 3] += agent_db[stage][year][4][agent] #deadNatural
        anthroAgentEffects[year+1, 4] += agent_db[stage][year][5][agent] #anthroMortalities
      end

      #with anthro
      for agent = 1:length(a_db_withA[stage][year][1])-1
        anthroAgentEffects[year+1, 6] += agent_db_withA[stage][year][3][agent] #alive
        anthroAgentEffects[year+1, 7] += agent_db_withA[stage][year][4][agent] #deadNatural
        anthroAgentEffects[year+1, 8] += agent_db_withA[stage][year][5][agent] #anthroMortalities
      end

      anthroAgentEffects[year+1, 5] = anthroAgentEffects[year+1, 3] + anthroAgentEffects[year+1, 4]
      anthroAgentEffects[year+1, 9] = anthroAgentEffects[year+1, 7] + anthroAgentEffects[year+1, 8]
      print("Year $year of $totalYears (life stage $stage of 3) \n")
    end

    writedlm(Pkg.dir("FishABM")"/totalResults/exampleOne_stage$stage.csv", anthroAgentEffects, ',')
  end
  return anthroAgentEffects
end

#no functionality yet
function resultsSummary(agent_db::DataFrame, carryingCapacity::Vector)
"""
  Files will be written by stage.

    # a_db[stage][year][titledColumn][agentNumber]
    # stage
        1 = life stage
        2 = location
        3 = alive in that location
        4 = died due to natural mortality
        5 = died due to anthro
"""

  anthroAgentEffects = Array(Int64, length(carryingCapacity)+1, 5)

  #set all entries to 0
  for i = 1:size(anthroAgentEffects)[1]
    for j = 1:size(anthroAgentEffects)[2]
      anthroAgentEffects[i, j] = 0
    end
  end

  for stage = 1:3
    for year = 1:length(carryingCapacity)+1
      anthroAgentEffects[year+1, 1] = year

      for agent = 1:length(a_db[stage][year][1])-1
        anthroAgentEffects[year+1, 2] += a_db[stage][year][3][agent] #alive
        anthroAgentEffects[year+1, 3] += a_db[stage][year][4][agent] #deadNatural
        anthroAgentEffects[year+1, 4] += a_db[stage][year][5][agent] #anthroMortalities
      end

      anthroAgentEffects[year+1, 5] = anthroAgentEffects[year+1, 3] + anthroAgentEffects[year+1, 4]

      print("Year $year of $length(carryingCapacity)")
    end

    #switch to string array to write out titles
    resultsSummary = Array(ASCII, size(anthroAgentEffects)[1] , size(anthroAgentEffects)[2])
    resultsSummary [1,1] = "Year"
    resultsSummary [1,2] = "Alive"
    resultsSummary [1,3] = "Dead natural"
    resultsSummary [1,4] = "Anthropogenic Mortalites"
    resultsSummary [1,5] = "Total deaths"

    for i = 2:size(resultsSummary)[1]
      for j = 1:size(resultsSummary)[2]
          resultsSummary [i,j] = ASCII(anthroAgentEffects[i, j])
      end
    end

    writedlm(Pkg.dir("FishABM")"/totalResults/exampleOne_stage$stage_withA.csv", resultsSummary, ',')
  end

  return resultsSummary
end

#no functionality yet
function resultsSummary_withA(agent_db::DataFrame, carryingCapacity::Vector)
  """
  Files will be written by stage, writes out the results with anthro effects into a separate file.
  """

  anthroAgentEffects = Array(Int64, length(carryingCapacity)+1, 5)

  #set all entries to 0
  for i = 1:size(anthroAgentEffects)[1]
    for j = 1:size(anthroAgentEffects)[2]
      anthroAgentEffects[i, j] = 0
    end
  end

  for stage = 1:3
    for year = 1:length(carryingCapacity)+1
      anthroAgentEffects[year+1, 1] = year

      for agent = 1:length(a_db[stage][year][1])-1
        anthroAgentEffects[year+1, 2] += a_db[stage][year][3][agent] #alive
        anthroAgentEffects[year+1, 3] += a_db[stage][year][4][agent] #deadNatural
        anthroAgentEffects[year+1, 4] += a_db[stage][year][5][agent] #anthroMortalities
      end

      anthroAgentEffects[year+1, 5] = anthroAgentEffects[year+1, 3] + anthroAgentEffects[year+1, 4] #total deaths

      print("Year $year of $length(carryingCapacity)")
    end

    #switch to string array to write out titles
    resultsSummary = Array(ASCII,size(anthroAgentEffects)[1] , size(anthroAgentEffects)[2])
    resultsSummary [1,1] = "Year"
    resultsSummary [1,2] = "Alive"
    resultsSummary [1,3] = "Dead natural"
    resultsSummary [1,4] = "Anthropogenic Mortalites"
    resultsSummary [1,5] = "Total deaths"

    for i = 2:size(resultsSummary)[1]
      for j = 1:size(resultsSummary)[2]
          resultsSummary [i,j] = ASCII(anthroAgentEffects[i, j])
      end
    end

    writedlm(Pkg.dir("FishABM")"/totalResults/exampleOne_stage$stage_withA.csv", resultsSummary, ',')
  end

  return resultsSummary
end

#function for writing out agent plots, write the code here instead of writing it in the example file
function writeOutAgentPlots(agent_db::DataFrame, agent_db_withA::DataFrame, year::Int, e_a::EnvironmentAssumptions)
  """
  Visualize agent movement, specify:
  #  * e_a = Environment assumption object
  #  * a_db = Agent database (as generated by simulation)
  #  * year = Cohort
  Export images of all plots (for later compilation into an animation, perhaps)
  without anthro effects
  """

  agentplots = plot_agents(e_a, agent_db, year, false)
  agentplots_withA = plot_agents(e_a, agent_db_withA, year, false)

  totalNumber = length(agentplots)/1000
  #without anthro effects
  for i = 1:length(agentPlots)
    filenumber = i/1000
    print("writing file number $filenumber of $totalNumber (", integer((filenumber/totalnumber)*100))
    print("%) \n")
    filenumber = prod(split("$filenumber", ".", 2))
    filenumber *= prod(fill("0", 5-length(filenumber)))
    draw(PNG(Pkg.dir("FishABM")"/examples/plots/agent_$filenumber.png", 8.65cm, 20cm), agentplots[i])
  end

  totalNumber = length(agentplots_withA)/1000
  #with anthro effects
  for i = 1:length(agentplots_withA)
    filenumber = i/1000
    print("writing file number $filenumber of $totalNumber (", integer((filenumber/totalnumber)*100))
    print("%) \n")
    filenumber = prod(split("$filenumber", ".", 2))
    filenumber *= prod(fill("0", 5-length(filenumber)))
    draw(PNG(Pkg.dir("FishABM")"/examples/plots/agent_withA_$filenumber.png", 8.65cm, 20cm), agentplots_withA[i])
  end

end
