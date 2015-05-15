"""
Combine agent and stock level functions into a simulation framework
Justin Angevaare
May 2015
"""

function simulate(years::Int, harvest_effort::Vector, s_db::stock_db, s_a::stock_assumptions, a_a::agent_assumptions, e_a::environment_assumptions, reduced::Bool)
  """
  Brings together all of the functions necessary for a life cycle simulation
  """
  a_db = create_agent_db(years, a_a, reduced)
  if reduced
    c=fill(0, 104)
    for i = 1:104
      c[i]=find([0, a_a.growth[1:end-1]] .<= i)[end]
    end
  else
    c = 1:104
  end
  for y = 1:1
    spawn!(a_db, s_db, s_a, e_a, y)
    for w = 1:52
      if w > 1 && c[w] - c[w-1] == 1
        a_db[y,c[w]] = deepcopy(a_db[y,c[w-1]])
      end
      kill!(a_db, e_a, a_a, y, c[w])
      move!(a_db, a_a, y, c[w])
      if w==52
        harvest!(harvest_effort[y], s_db, s_a)
        age_adults!(s_db, s_a)
      end
      graduate!(a_db, s_db, a_a, y, w, c[w])
    end
  end
  for y = 2:years
    spawn!(a_db, s_db, s_a, e_a, y)
    @assert(size(a_db[y,1])[1] < 200000, "> 200000 agents in current simulation, stopping here.")
    for w = 1:52
      if w > 1 && c[w] - c[w-1] == 1
        a_db[y,c[w]] = deepcopy(a_db[y,c[w-1]])
      end
      if c[w+52] - c[w+51] == 1
        a_db[y-1,c[w+52]] = deepcopy(a_db[y-1,c[w+51]])
      end
      kill!(a_db, e_a, a_a, y, c[w])
      kill!(a_db, e_a, a_a, y-1, c[w+52])
      move!(a_db, a_a, y, c[w])
      move!(a_db, a_a, y-1, c[w+52])
      if w==52
        harvest!(harvest_effort[y], s_db, s_a)
        age_adults!(s_db, s_a)
      end
      graduate!(a_db, s_db, a_a, y, w, c[w])
      graduate!(a_db, s_db, a_a, y-1, w+52, c[w+52])
    end
  end
  return a_db
end
