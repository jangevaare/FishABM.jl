"""
Functions and types for interacting model components
Justin Angevaare
February 2015
"""

#type life_map
  """
  A specialized map which contains layers of information for each risk factor specific to agent class and location. Additionally, there are layers to indicate spawning area, carrying capacity, and water currents
  """

# function spawn!(agent_db::agent_db, stock_db::stock_db, life_map::life_map, fecundity_assumptions)
  """
  This function creates a new cohort of agents based on an structured adult population, spawning area information contained in a `life_map`, and `fecundity_assumptions`.
  """

# type fecundity_assumptions
  """
  Contains assumptions on sexual maturity for each class (i.e. percentage of females which will spawn), and age specific fecundity (i.e. mean quantity of eggs each spawning female will produce)
  """

# function graduate!(agent_db::agent_db, stock_db::stock_db, stage::integer)
  """
  This function will advance an agent currently in a specified stage to its next life stage. If this function is applied to juveniles, it will also add their information to the stock_db
  """
