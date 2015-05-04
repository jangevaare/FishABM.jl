"""
Combine agent and stock level functions into a simulation framework
Justin Angevaare
May 2015
"""

function simulate(years::Int, harvest_effort::Vector, s_db::stock_db, s_a::stock_assumptions, a_a::agent_assumptions, e_a::environment_assumptions)
  """
  Brings together all of the functions necessary for a life cycle simulation
  """
  a_db = create_agent_db(years)
  for y = 1:1
    spawn!(a_db, s_db, s_a, e_a, y)
    for w = 1:52
      if w > 1
        a_db[y,w] = a_db[y,w-1]
      end
      kill!(a_db, e_a, a_a, y, w)
      move!(a_db, a_a, y, w)
      if w==52
        harvest!(harvest_effort[y], s_db, s_a)
        age_adults!(s_db, s_a)
      end
      graduate!(a_db, s_db, a_a, y, w)
    end
  end
  for y = 2:years
    spawn!(a_db, s_db, s_a, e_a, y)
    if shape(a_db[y,1])[1] > 1000000
      print("> 1000000 agents in current simulation, stopping here.")
      break
    end
    for w = 1:52
      if w > 1
        a_db[y,w] = a_db[y,w-1]
      end
      a_db[y-1,w+52] = a_db[y-1,w+51]
      kill!(a_db, e_a, a_a, y, w)
      kill!(a_db, e_a, a_a, y-1, w+52)
      move!(a_db, a_a, y, w)
      move!(a_db, a_a, y-1, w+52)
      if w==52
        harvest!(harvest_effort[y], s_db, s_a)
        age_adults!(s_db, s_a)
      end
      graduate!(a_db, s_db, a_a, y, w)
      graduate!(a_db, s_db, a_a, y-1, w+52)
    end
  end
  return a_db
end
