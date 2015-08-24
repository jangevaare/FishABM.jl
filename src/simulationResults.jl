"""
Devin Rose
Functions used to summarize the results of a simulation
August 2015
"""

#converts all entries in an array to strings
function convertToStringArray(arrayToConvert::Array)
  """
  Converts the results summary to ASCIIString so there are titles in the file that is saved
  """
  arrayWithTitles = Array(ASCIIString, size(arrayToConvert)[1], size(arrayToConvert)[2], size(arrayToConvert)[3])

  titleRow = 1
  for stage = 1:size(arrayWithTitles)[3]
    arrayWithTitles[titleRow, 1, stage] = "Year"
    arrayWithTitles[titleRow, 2, stage] = "Carrying Capacity"
    arrayWithTitles[titleRow, 3, stage] = "Alive"
    arrayWithTitles[titleRow, 4, stage] = "Natural Mortalities"
    arrayWithTitles[titleRow, 5, stage] = "Risk mortalities"
    arrayWithTitles[titleRow, 6, stage] = "Total deaths"
    arrayWithTitles[titleRow, 7, stage] = "Alive (with)"
    arrayWithTitles[titleRow, 8, stage] = "Natural Mortalities (with)"
    arrayWithTitles[titleRow, 9, stage] = "Risk Mortalities (with)"
    arrayWithTitles[titleRow, 10, stage] = "Total Deaths (with)"
    arrayWithTitles[titleRow, 11, stage] = "Alive differential (without - with)"
    arrayWithTitles[titleRow, 12, stage] = "Total deaths differential (without-with)"
  end

  #converts each int to a string
  for year = 2:size(arrayWithTitles)[1] #stage
    for column = 1:size(arrayWithTitles)[2] #year
      for stage = 1:size(arrayWithTitles)[3] #column
        arrayWithTitles[year, column, stage] = "$(arrayToConvert[year, column, stage])"
      end
    end
  end

  return arrayWithTitles
end

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
    #do nothing yet, have to see what to do with the agent database when reduced is not used
    return anthroAgentEffects
  end
end
