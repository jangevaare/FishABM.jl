"""
Combine agent and stock level functions into a simulation framework
Justin Angevaare
May 2015
"""

function Simulate(years::Int, harvest_effort::Vector, s_db::StockDB, s_a::StockAssumptions, a_a::AgentAssumptions, e_a::EnvironmentAssumptions, reduced::Bool)
  """
  Brings together all of the functions necessary for a life cycle simulation
  """
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
    Spawn!(a_db, s_db, s_a, e_a, y)
    progressbar = Progress(52, 5, "Year $y simulation progress", 50)
    for w = 1:52
      if w > 1 && c[w] - c[w-1] == 1
        a_db[y,c[w]] = deepcopy(a_db[y,c[w-1]])
      end
      Kill!(a_db, e_a, a_a, y, c[w])
      Move!(a_db, a_a, e_a, y, c[w])
      if w==52
        Harvest!(harvest_effort[y], s_db, s_a)
        AgeAdults!(s_db, s_a)
      end
      Graduate!(a_db, s_db, a_a, y, w, c[w])
      next!(progressbar)
    end
  end
  for y = 2:years
    Spawn!(a_db, s_db, s_a, e_a, y)
    @assert(size(a_db[y,1])[1] < 200000, "> 200000 agents in current simulation, stopping here.")
    progressbar = Progress(52, 5, "Year $y simulation progress", 50)
    for w = 1:52
      if w > 1 && c[w] - c[w-1] == 1
        a_db[y,c[w]] = deepcopy(a_db[y,c[w-1]])
      end
      if c[w+52] - c[w+51] == 1
        a_db[y-1,c[w+52]] = deepcopy(a_db[y-1,c[w+51]])
      end
      Kill!(a_db, e_a, a_a, y, c[w])
      Kill!(a_db, e_a, a_a, y-1, c[w+52])
      Move!(a_db, a_a, e_a, y, c[w])
      Move!(a_db, a_a, e_a, y-1, c[w+52])
      if w==52
        Harvest!(harvest_effort[y], s_db, s_a)
        AgeAdults!(s_db, s_a)
      end
      Graduate!(a_db, s_db, a_a, y, w, c[w])
      Graduate!(a_db, s_db, a_a, y-1, w+52, c[w+52])
      next!(progressbar)
    end
  end
  return a_db
end
