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

function agent_visualize(e_a::EnvironmentAssumptions, a_db::DataFrame, cohort::Int)
  """
  Create an interactive visualization of an agent database with IJulia
  """
  @assert(1 <= cohort <= size(a_db,1), "Invalid cohort specified")
  # Generate a simple map of the lake
  is, js, values = findnz(e_a.habitat .> 0)
  lake_map = DataFrame(i=is, j=js, value=values)

  # Generate cohort specific dataset
  # Initialize with week 1...
  df = DataFrame(id = a_db[cohort,1][:location], i = ind2sub(size(e_a.habitat),a_db[cohort,1][:location])[1], j=i = ind2sub(size(e_a.habitat),a_db[cohort,1][:location])[2], value=0)
  for i = 1:size(a_db[cohort,1],1)
    df[df[:id] .== a_db[cohort,1][:location][i], 4] += a_db[cohort,1][:alive][i]
  end
  week_summaries =Array[df]
  # Calculate for the remaining weeks
  for w = 2:104
    df=DataFrame(id = a_db[cohort,w][:location], i = ind2sub(size(e_a.habitat),a_db[cohort,w][:location])[1], j=i = ind2sub(size(e_a.habitat),a_db[cohort,w][:location])[2], value=0)
    for i = 1:size(a_db[cohort,w],1)
      df[df[:id] .== a_db[cohort,w][:location][i], 4] += a_db[cohort,w][:alive][i]
    end
    push!(week_summaries, df)
  end

  # Interactive in terms of plotting
  @manipulate for week = 1:104
    plot(lake_map, x="j", y="i", color="value",
         Coord.cartesian(yflip=true),
         Scale.color_continuous,
         Scale.x_continuous,
         Scale.y_continuous,
         Geom.rectbin,
         Stat.identity,
         layer(DataFrame(i=week_summaries[w][:,2],
                         j=week_summaries[w][:,3],
                         value=week_summaries[w][:,4]),
         Geom.rectbin))
  end
end
