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

  plotymax = maximum(df[:value])
  newplot = plot(df[water,:],
                 x="x",
                 y="y",
                 color="value",
                 Coord.cartesian(yflip=true),
                 Scale.color_continuous,#(minvalue=0, maxvalue=plotymax),
                 Scale.x_continuous,
                 Scale.y_continuous,
                 Geom.rectbin,
                 Stat.identity,
                 Guide.xlabel(nothing),
                 Guide.ylabel(nothing),
                 Guide.colorkey("Abundance"))
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
    newplot = plot(df[water,:],
                 x="x",
                 y="y",
                 color="value",
                 Coord.cartesian(yflip=true),
                 Scale.color_continuous,#(minvalue=0, maxvalue=plotymax),
                 Scale.x_continuous,
                 Scale.y_continuous,
                 Geom.rectbin,
                 Stat.identity,
                 Guide.xlabel(nothing),
                 Guide.ylabel(nothing),
                 Guide.colorkey("Abundance"))
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
              Scale.x_continuous(minvalue=1, maxvalue=size(stockarray,1)))
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
                Guide.ylabel("Abundance/Carrying Capacity"))
  else
    p1 = plot(x=x,
              y=y,
              group=z,
              color=z,
              Guide.colorkey(" "),
              Guide.xlabel("Year"),
              Guide.ylabel("Abundance"),
              Geom.polygon(preserve_order=true, fill=true),
              Scale.y_continuous(minvalue=0, maxvalue=maximum(k)))
    p2 = plot(x=x,
              y=k,
              Geom.line,
              Guide.xlabel("Year"),
              Guide.ylabel("Carrying capacity"))
    return hstack(p2,p1)
  end
end
