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

#function for writing out agent plots, write the code here instead of writing it in the example file
#Update file locations to be more dynamic
function writeOutAgentPlots(agent_db::DataFrame, agent_db_withA::DataFrame, year::Int, e_a::EnvironmentAssumptions)
  """
  Visualize agent movement, specify:
  #  * e_a = Environment assumption object
  #  * a_db = Agent database (as generated by simulation)
  #  * year = Cohort
  Export images of all plots (for later compilation into an animation, perhaps)
  without anthro effects
  """

  agentplots = plot_agents(e_a, agent_db, year, true)
  agentplots_withA = plot_agents(e_a, agent_db_withA, year, true)

  cd()
  cd(split(Base.source_path(), "FishABM.jl")[1])
  cd("FishABM.jl")

  #=for i = 1:length(split(Base.source_path(), "/"))-1
    cd = (split(Base.source_path(), "/")[i])
  end=#

  if(isdir("agentPlots") == false)
    print("agentPlots not found, now creating a directory for plots in location '"pwd()"' \n")
    mkdir("agentPlots")
    cd("agentPlots")
  end

  totalNumber = length(agentplots)/1000
  #without anthro effects
  print("Without anthro effects \n")
  for i = 1:length(agentplots)
    filenumber = i/1000
    print("writing file number $filenumber of $totalNumber (", integer((filenumber/totalNumber)*100)"%) \n")
    filenumber = prod(split("$filenumber", ".", 2))
    filenumber *= prod(fill("0", 5-length(filenumber)))
    draw(PNG(pwd()"agentPlots/agent_$filenumber.png", 8.65cm, 20cm), agentplots[i])
  end

  totalNumber = length(agentplots_withA)/1000
  #with anthro effects
  print("With anthro effects \n")
  for i = 1:length(agentplots_withA)
    filenumber = i/1000
    print("writing file number $filenumber of $totalNumber (", integer((filenumber/totalnumber)*100)"%) \n")
    filenumber = prod(split("$filenumber", ".", 2))
    filenumber *= prod(fill("0", 5-length(filenumber)))
    draw(PNG(pwd()"agentPlots/agent_withA_$filenumber.png", 8.65cm, 20cm), agentplots_withA[i])
  end
end
