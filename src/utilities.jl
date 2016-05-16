"""
  Tools/utilities to improve ease of use of Fish_ABM.jl
  Justin Angevaare
  May 2015
"""

agent_db = adb
agent_a = a_a
enviro_types = enviro_a.habitat
current_week = 4


popDensity = Array(Int64, size(enviro_a.habitat)[1], size(enviro_a.habitat)[2])

for i = 1:size(enviro_a.habitat)[1]
  for j = 1:size(enviro_a.habitat)[2]
    popDensity[i, j] = 0
  end
end

classLen = length(agent_db[1].alive)

for k = 1:length(agent_db)
  popDensity[agent_db[k].locationID] = 1

  for m = 1:classLen
    popDensity[agent_db[k].locationID] += agent_db[k].alive[m]
  end
end

spy(popDensity)
