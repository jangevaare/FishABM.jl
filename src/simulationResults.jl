"""
Devin Rose
Functions used to summarize the results of a simulation
August 2015
"""

function simulationSummary(agent_db::DataFrame, agent_db_withA::DataFrame, carryingCapacity::Vector, reduced::Bool)
  """
  Summarizes results and returns an integer array for any further requirements
  """
  anthroAgentEffects = Array(Int64, length(carryingCapacity)+1, 12, 3)

  totalYears = length(carryingCapacity)

  #set all entries to 0
  for i = 1:size(anthroAgentEffects)[1]
    for j = 1:size(anthroAgentEffects)[2]
      for k = 1:size(anthroAgentEffects)[3]
        anthroAgentEffects[i, j, k] = 0
      end
    end
  end

  #for reduced output
  if (reduced == true)
    for stage = 1:3
      print("For life stage $stage of 3 \n")

      for year = 1:length(carryingCapacity)
        #Year and carrying capacity
        anthroAgentEffects[year+1, 1, stage] = year
        anthroAgentEffects[year+1, 2, stage] = int(carryingCapacity[year])

        #without anthro
        for agent = 1:length(agent_db[stage][year][1])-1
          anthroAgentEffects[year+1, 3, stage] += agent_db[stage][year][3][agent] #alive
          anthroAgentEffects[year+1, 4, stage] += agent_db[stage][year][4][agent] #deadNatural
          anthroAgentEffects[year+1, 5, stage] += agent_db[stage][year][5][agent] #anthroMortalities
        end

        #with anthro
        for agent = 1:length(agent_db_withA[stage][year][1])-1
          anthroAgentEffects[year+1, 7, stage] += agent_db_withA[stage][year][3][agent] #alive withA
          anthroAgentEffects[year+1, 8, stage] += agent_db_withA[stage][year][4][agent] #deadNatural withA
          anthroAgentEffects[year+1, 9,stage] += agent_db_withA[stage][year][5][agent] #anthroMortalities withA
        end

        #total alive and deaths differentials
        anthroAgentEffects[year+1, 6, stage] = anthroAgentEffects[year+1, 4, stage] + anthroAgentEffects[year+1, 5, stage]
        anthroAgentEffects[year+1, 10, stage] = anthroAgentEffects[year+1, 8, stage] + anthroAgentEffects[year+1, 9, stage]
        anthroAgentEffects[year+1, 11, stage] = anthroAgentEffects[year+1, 3, stage] - anthroAgentEffects[year+1, 7, stage]
        anthroAgentEffects[year+1, 12, stage] = anthroAgentEffects[year+1, 6, stage] - anthroAgentEffects[year+1, 10, stage]
        print("Year $year of $totalYears\n")
      end
    end
    return anthroAgentEffects
  else #for full output
    #do nothing yet
    return anthroAgentEffects
  end
end
