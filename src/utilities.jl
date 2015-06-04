"""
Tools/utilities to improve ease of use of Fish_ABM.jl
Justin Angevaare
May 2015
"""

function PadEnvironmentAssumptions!(EnvironmentAssumptions::EnvironmentAssumptions)
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

function agent_plots(e_a::EnvironmentAssumptions, a_db::DataFrame, cohort::Int)
  """
  Create an interactive visualization of an agent database with IJulia
  """
  @assert(1 <= cohort <= size(a_db,1), "Invalid cohort specified")
  @assert(size(a_db,2) == 104, "Require full agent database output")
  # Generate a simple map of the lake
  is, js, values = findnz(e_a.habitat .> 0)
  id = find(e_a.habitat .> 0)

  # Generate cohort specific dataset
  # Initialize with week 1...
  df = DataFrame(id=id, i=is, j=js, value=0)
  for i = 1:size(a_db[cohort,1],1)
    df[df[:id] .== a_db[cohort,1][:location][i], 4] += a_db[cohort,1][:alive][i]
  end
  plotymax = maximum(df[:value])
  newplot = plot(df,
                 x="j",
                 y="i",
                 color="value",
                 Coord.cartesian(yflip=true),
                 Scale.color_continuous(minvalue=0, maxvalue=plotymax),
                 Scale.x_continuous,
                 Scale.y_continuous,
                 Geom.rectbin,
                 Stat.identity,
                 Guide.xlabel(nothing),
                 Guide.ylabel(nothing),
                 Guide.colorkey("Abundance"))
  week_plots = [newplot]
  # Calculate for the remaining weeks
  for w = 2:104
    df = DataFrame(id=id, i=is, j=js, value=0)
    for i = 1:size(a_db[cohort,w],1)
      df[df[:id] .== a_db[cohort,w][:location][i], 4] += a_db[cohort,w][:alive][i]
    end
    newplot = plot(df,
                 x="j",
                 y="i",
                 color="value",
                 Coord.cartesian(yflip=true),
                 Scale.color_continuous(minvalue=0, maxvalue=plotymax),
                 Scale.color_continuous,
                 Scale.x_continuous,
                 Scale.y_continuous,
                 Geom.rectbin,
                 Stat.identity,
                 Guide.xlabel(nothing),
                 Guide.ylabel(nothing),
                 Guide.colorkey("Abundance"))
    push!(week_plots, newplot)
  end
  return week_plots
end
