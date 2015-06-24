"""
Combine agent and stock level functions into a simulation framework
Justin Angevaare
May 2015
"""

function simulate(carrying_capacity::Vector, effort::Vector, bump::Vector, s_db::StockDB, s_a::StockAssumptions, a_a::AgentAssumptions, e_a::EnvironmentAssumptions, reduced=false::Bool, progress=true::Bool, limit=250000::Int64)
  """
  Brings together all of the functions necessary for a life cycle simulation
  """
  @assert(all(carrying_capacity .> 0.), "There is at least one negative carrying capacity")
  @assert(length(effort)<=length(carrying_capacity), "The effort vector must be equal or less than the length of the simulation")
  @assert(length(bump)<=length(carrying_capacity), "The bump vector must be equal or less than the length of the simulation")
  years = length(carrying_capacity)
  a_db = AgentDB(years, a_a, reduced)
  bumpvec = fill(0, years)
  bumpvec[1:length(bump)] = bump
  harvest_effort = fill(0., years)
  harvest_effort[1:length(effort)] = effort
  if reduced
    c=fill(0, 104)
    for i = 1:104
      c[i]=find([0, a_a.growth[1:end-1]] .<= i)[end]
    end
  else
    c = 1:104
  end
  for y = 1:1
    spawn!(a_db, s_db, s_a, e_a, y, carrying_capacity[y])
    totalagents=size(a_db[y,1],1)
    if progress
      progressbar = Progress(52, 5, "Year $y simulation progress ($totalagents agents)", 30)
    end
    for w = 1:52
      if w > 1 && c[w] - c[w-1] == 1
        a_db[y,c[w]] = deepcopy(a_db[y,c[w-1]])
      end
      kill!(a_db, e_a, a_a, y, c[w])
      move!(a_db, a_a, e_a, y, c[w])
      if w==52
        harvest!(harvest_effort[y], s_db, s_a)
        ageadults!(s_db, s_a, carrying_capacity[y], bumpvec[y])
      end
      graduate!(a_db, s_db, a_a, y, w, c[w])
      if progress
        next!(progressbar)
      end
    end
  end
  for y = 2:years
    spawn!(a_db, s_db, s_a, e_a, y, carrying_capacity[y])
    totalagents=size(a_db[y,1],1)
    @assert(totalagents < limit, "> $limit agents in current simulation, stopping here.")
    if progress
      progressbar = Progress(52, 5, "Year $y simulation progress ($totalagents agents)", 30)
    end
    for w = 1:52
      if w > 1 && c[w] - c[w-1] == 1
        a_db[y,c[w]] = deepcopy(a_db[y,c[w-1]])
      end
      if c[w+52] - c[w+51] == 1
        a_db[y-1,c[w+52]] = deepcopy(a_db[y-1,c[w+51]])
      end
      kill!(a_db, e_a, a_a, y, c[w])
      kill!(a_db, e_a, a_a, y-1, c[w+52])
      move!(a_db, a_a, e_a, y, c[w])
      move!(a_db, a_a, e_a, y-1, c[w+52])
      if w==52
        harvest!(harvest_effort[y], s_db, s_a)
        ageadults!(s_db, s_a, carrying_capacity[y], bumpvec[y])
      end
      graduate!(a_db, s_db, a_a, y, w, c[w])
      graduate!(a_db, s_db, a_a, y-1, w+52, c[w+52])
      if progress
        next!(progressbar)
      end
    end
  end
  return a_db
end
