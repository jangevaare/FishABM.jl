"""
Functions and types for agent-level model components
Justin Angevaare
February 2015
"""

# type agent_db
  """
  A hierarchical database which contains information on all agents. The hierarchy of this database is cohort -> time step -> agent. The agent entries will include current location (tuple), stage (egg, larvae, juvenile, or adult), and fate (tuple of living, natural death, and any additional risks)
  """

# function kill!(agent_db::agent_db, life_map::life_map)
  """
  This function will kill agents based on all stage and location specific risk factors described in a `life_map`
  """

# function move!(agent_db::agent_db, life_map::life_map)
  """
  This function will move agents based on current for larvae, current and carrying capacity for juveniles
  """

# function inject_agents!(agent_db::agent_db, age::integer, location, size)
  """
  This function will inject an agent of a specified stage into an `agent_db` to simulate stock rehabilitation efforts (i.e. stocking). If age is specified as 0, the agent will either be made up of eggs or larvae based on the time of year. If age is specificed as 1, the agent will be a juvenile.
  """
