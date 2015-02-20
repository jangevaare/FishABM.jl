"""
Combine agent and stock level functions into a simulation framework
Justin Angevaare
February 2015
"""

type simulation_db
  """
  A single database which contains all information necessary to simulate a population
  """
  agent_db::DataFrame
  stock_db::DataFrame
  life_map::DataFrame
  fecundity_assumptions::DataFrame
  transition_matrix::Matrix
end

function Initialize(years::int, )
  """
  A function which will create a `simulation_db` based on provided information
  """
  sim_db = simulation_db(agent_db = DataFrame(),
                         stock_db = DataFrame(),
                         life_map = DataFrame(),
                         fecundity_assumptions = DataFrame(),
                         transition_matrix = Matrix([]))
  sim_db[:]
  simulation_db(agent_db=Data

