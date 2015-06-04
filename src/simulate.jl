"""
Combine agent and stock level functions into a simulation framework
Justin Angevaare
May 2015
"""

function simulate(years::Int, harvest_effort::Vector, carrying_capacity::Vector, s_db::StockDB, s_a::StockAssumptions, a_a::AgentAssumptions, e_a::EnvironmentAssumptions, reduced=false::Bool, progress=true::Bool)
  """
  Brings together all of the functions necessary for a life cycle simulation
  """
  @assert(any(carrying_capacity > 0.), "There is at least one negative carrying capacity")
  a_db = AgentDB(years, a_a, reduced)
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
    if progress
      progressbar = Progress(52, 5, "Year $y simulation progress", 50)
    end
    for w = 1:52
      if w > 1 && c[w] - c[w-1] == 1
        a_db[y,c[w]] = deepcopy(a_db[y,c[w-1]])
      end
      kill!(a_db, e_a, a_a, y, c[w])
      move!(a_db, a_a, e_a, y, c[w])
      if w==52
        harvest!(harvest_effort[y], s_db, s_a)
        ageadults!(s_db, s_a, carrying_capacity[y])
      end
      graduate!(a_db, s_db, a_a, y, w, c[w])
      if progress
        next!(progressbar)
      end
    end
  end
  for y = 2:years
    spawn!(a_db, s_db, s_a, e_a, y, carrying_capacity[y])
    @assert(size(a_db[y,1])[1] < 200000, "> 200000 agents in current simulation, stopping here.")
    if progress
      progressbar = Progress(52, 5, "Year $y simulation progress", 50)
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
        ageadults!(s_db, s_a, carrying_capacity[y])
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
