"""
Functions and types for agent-level model components
Justin Angevaare
April 2015
"""

function create_agent_db()
  """
  A function which will create an empty agent_db for the specified simulation length
  """
  sub_agent_db = DataFrame(cohort = DataFrame(stage=[], location=[], alive=[], dead_natural=[], dead_risk=[]))
  int_agent_db = hcat(sub_agent_db, sub_agent_db)
  for i = 1:50
    int_agent_db=hcat(int_agent_db, sub_agent_db)
  end
  names!(int_agent_db, [symbol("week_$i") for i in 1:52])
#   agent_db = vcat(int_agent_db, int_agent_db)
#   for i = 1:(years-2)
#     agent_db = vcat(agent_db, int_agent_db)
#   end
#   return agent_db
  return int_agent_db
end

# function kill!(agent_db::agent_db, life_map::life_map)
  """
  This function will kill agents based on all stage and location specific risk factors described in a `life_map`
  """

# function move!(agent_db::agent_db, life_map::life_map)
  """
  This function will move agents based on current for larvae, current and carrying capacity for juveniles
  """

# function inject_juveniles!(agent_db::agent_db, location, size)
  """
  This function will inject juveniles into an `agent_db` to simulate stocking efforts.
  """
