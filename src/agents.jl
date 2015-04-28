"""
Functions and types for agent-level model components
Justin Angevaare
April 2015
"""

# type agent_db
#   """
#   A very basic type specified for conveinence; methods can be created for the type
#   """
#   DataFrame
# end

function create_agent_db(cohorts)
  """
  A function which will create an empty agent_db for the specified simulation length
  """
  sub_agent_db = DataFrame(cohort = DataFrame(stage=ASCIIString[], location=Int[], alive=Int[], dead_natural=Int[], dead_risk=Int[]))
  int_agent_db = hcat(sub_agent_db, sub_agent_db)
  for i = 1:50
    int_agent_db=hcat(int_agent_db, sub_agent_db)
  end
  names!(int_agent_db, [symbol("week_$i") for i in 1:52])
  agent_db = vcat(int_agent_db, int_agent_db)
  for i = 1:(cohorts-2)
    agent_db = vcat(agent_db, int_agent_db)
  end
  return agent_db
#   return int_agent_db
end

function kill!(agent_db::DataFrame, life_map::life_map, week::Int64)
  """
  This function will kill agents based on all stage and location specific risk factors described in a `life_map`
  """
end

function move!(agent_db::DataFrame, life_map::life_map)
  """
  This function will move agents based on current for larvae, current and carrying capacity for juveniles
  """
end

function inject_juveniles!(agent_db::DataFrame, location::Int64, size::Int64)
  """
  This function will inject juveniles into an `agent_db` to simulate stocking efforts.
  """
end
