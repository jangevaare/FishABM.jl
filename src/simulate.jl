"""
Combine agent and stock level functions into a simulation framework
Justin Angevaare
February 2015
"""

type simulation_db
  """
  A single database which contains all information necessary to simulate a population
  """
  agent_db::agent_db
  stock_db::stock_db
  life_map::life_map
  fecundity_assumptions::fecundity_assumptions
  transition_matrix::transition_matrix
end

function Initialize(years::int, )
  """
  A function which will create a `simulation_db` based on provided information
  """
  sim_db = simulation_db(agent_db = agent_db(),
                         stock_db = stock_db(),
                         life_map = life_map(),
                         fecundity_assumptions = fecundity_assumptions(),
                         transition_matrix = transition_matrix())
