"""
Combine agent and stock level functions into a simulation framework
Justin Angevaare
May 2015
"""

function simulate(years::Int, s_db::stock_db, s_a::stock_assumptions, a_a::agent_assumptions, e_a::environment_assumptions)
  """
  Brings together all of the functions necessary for a life cycle simulation
  """
  a_db = create_agent_db(years)
  for y = 1:1
    spawn!(a_db, s_db, s_a, e_a, y)
    for w = 1:52
      kill!(a_db, e_a, a_a, y, w)
      move!(a_db, a_a, y, w)
      if w==52
        age_adults!(s_db, s_a)
      end
      graduate!(a_db, s_db, a_a, y, w)
    end
  end
  for y = 2:years
    spawn!(a_db, s_db, s_a, e_a, y)
    for w = 1:52
      kill!(a_db, e_a, a_a, y, w)
      kill!(a_db, e_a, a_a, y-1, w+52)
      move!(a_db, a_a, y, w)
      move!(a_db, a_a, y-1, w+52)
      if w==52
        age_adults!(s_db, s_a)
      end
      graduate!(a_db, s_db, a_a, y, w)
    end
  end
  return a_db, s_db
end
