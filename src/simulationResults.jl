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

  titleRow = 1

  if (reduced == true)
    arrayWithTitles = Array(ASCIIString, size(arrayToConvert)[1], size(arrayToConvert)[2], size(arrayToConvert)[3])

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
  else
    arrayWithTitles = Array(ASCIIString, size(arrayToConvert)[1], size(arrayToConvert)[2])

    arrayWithTitles[titleRow, 1] = "Year"
    arrayWithTitles[titleRow, 2] = "Carrying Capacity"
    arrayWithTitles[titleRow, 3] = "Alive"
    arrayWithTitles[titleRow, 4] = "Natural Mortalities"
    arrayWithTitles[titleRow, 5] = "Risk mortalities"
    arrayWithTitles[titleRow, 6] = "Total deaths"
    arrayWithTitles[titleRow, 7] = "Alive (with)"
    arrayWithTitles[titleRow, 8] = "Natural Mortalities (with)"
    arrayWithTitles[titleRow, 9] = "Risk Mortalities (with)"
    arrayWithTitles[titleRow, 10] = "Total Deaths (with)"
    arrayWithTitles[titleRow, 11] = "Alive differential (without - with)"
    arrayWithTitles[titleRow, 12] = "Total deaths differential (without-with)"

      #converts each int to a string
    for year = 2:size(arrayWithTitles)[1] #stage
      for column = 1:size(arrayWithTitles)[2] #year
        arrayWithTitles[year, column] = "$(arrayToConvert[year, column])"
      end
    end
  end

  return arrayWithTitles
end

function simulationSummary(agent_db::DataFrame, agent_db_withA::DataFrame, carryingCapacity::Vector, reduced::Bool)
  """
  Summarizes results and returns an integer array for any further requirements
  """

  #for reduced output
  if (reduced == true)
    anthroAgentEffects = Array(Int64, length(carryingCapacity)+1, 12, 4)
    totalYears = length(carryingCapacity)

    #set all entries to 0
    anthroAgentEffects[:, :, :] = 0

    for stage = 1:3
      print("For life stage $stage of 3 \n")

      for year = 1:totalYears
        #progress
        percentage = int(((year + (stage-1)*totalYears)/(3*totalYears))*100)
        print("For year $year of $totalYears ($percentage%) \n")

        #Year and carrying capacity
        anthroAgentEffects[year+1, 1, stage] = year
        anthroAgentEffects[year+1, 2, stage] = int(carryingCapacity[year])
        anthroAgentEffects[year+1, 1, 4] = year
        anthroAgentEffects[year+1, 2, 4] = int(carryingCapacity[year])

        #without anthro
        for agent = 1:length(agent_db[stage][year][1])
          anthroAgentEffects[year+1, 3, stage] += agent_db[stage][year][3][agent] #alive
          anthroAgentEffects[year+1, 4, stage] += agent_db[stage][year][4][agent] #deadNatural
          anthroAgentEffects[year+1, 5, stage] += agent_db[stage][year][5][agent] #anthroMortalities
        end

        #with anthro
        for agent = 1:length(agent_db_withA[stage][year][1])
          anthroAgentEffects[year+1, 7, stage] += agent_db_withA[stage][year][3][agent] #alive withA
          anthroAgentEffects[year+1, 8, stage] += agent_db_withA[stage][year][4][agent] #deadNatural withA
          anthroAgentEffects[year+1, 9,stage] += agent_db_withA[stage][year][5][agent] #anthroMortalities withA
        end

        #total alive and deaths differentials
        anthroAgentEffects[year+1, 6, stage] = anthroAgentEffects[year+1, 4, stage] + anthroAgentEffects[year+1, 5, stage]
        anthroAgentEffects[year+1, 10, stage] = anthroAgentEffects[year+1, 8, stage] + anthroAgentEffects[year+1, 9, stage]
        anthroAgentEffects[year+1, 11, stage] = anthroAgentEffects[year+1, 3, stage] - anthroAgentEffects[year+1, 7, stage]
        anthroAgentEffects[year+1, 12, stage] = anthroAgentEffects[year+1, 6, stage] - anthroAgentEffects[year+1, 10, stage]
      end
    end

    #totals for comparison with reduced output
    for year = 1:totalYears
      for column = 3:length(anthroAgentEffects[1,:,1])
        anthroAgentEffects[year+1, column, 4] = anthroAgentEffects[year+1, column, 1] + anthroAgentEffects[year+1, column, 2] + anthroAgentEffects[year+1, column, 3]
      end
    end

    return anthroAgentEffects
  else
    #for full output
    anthroAgentEffects = Array(Int64, length(carryingCapacity)+1, 12)
    totalYears = length(carryingCapacity)
    yearEnd = 52
    agentToAdult = 103

    #set all entries to 0
    anthroAgentEffects[:, :] = 0

    for year = 1:totalYears
      percentage = int((year/totalYears)*100)
      print("For year $year of $totalYears ($percentage%) \n")

      #Year and carrying capacity
      anthroAgentEffects[year+1, 1] = year
      anthroAgentEffects[year+1, 2] = int(carryingCapacity[year])

      #without anthro
      for agent = 1:length(agent_db[yearEnd][year][1])
        anthroAgentEffects[year+1, 3] += agent_db[yearEnd][year][3][agent] #alive
        anthroAgentEffects[year+1, 4] += agent_db[yearEnd][year][4][agent] #deadNatural
        anthroAgentEffects[year+1, 5] += agent_db[yearEnd][year][5][agent] #anthroMortalities
      end

      #with antro
      for agent = 1:length(agent_db_withA[yearEnd][year][1])
        anthroAgentEffects[year+1, 7] += agent_db_withA[yearEnd][year][3][agent] #alive withA
        anthroAgentEffects[year+1, 8] += agent_db_withA[yearEnd][year][4][agent] #deadNatural withA
        anthroAgentEffects[year+1, 9] += agent_db_withA[yearEnd][year][5][agent] #anthroMortalities withA
      end

      #for the rest of the agents from the previous year
      if year > 1
        #without anthro
        for agent = 1:length(agent_db[agentToAdult][year-1][1])
          anthroAgentEffects[year+1, 3] += agent_db[agentToAdult][year-1][3][agent] - agent_db[yearEnd][year-1][3][agent] #alive
          anthroAgentEffects[year+1, 4] += agent_db[agentToAdult][year-1][4][agent] - agent_db[yearEnd][year-1][4][agent] #deadNatural
          anthroAgentEffects[year+1, 5] += agent_db[agentToAdult][year-1][5][agent] - agent_db[yearEnd][year-1][5][agent] #anthroMortalities
        end
        #with anthro
        for agent = 1:length(agent_db_withA[agentToAdult][year-1][1])
          anthroAgentEffects[year+1, 7] += agent_db_withA[agentToAdult][year-1][3][agent] - agent_db_withA[yearEnd][year-1][3][agent] #alive withA
          anthroAgentEffects[year+1, 8] += agent_db_withA[agentToAdult][year-1][4][agent] - agent_db_withA[yearEnd][year-1][4][agent] #deadNatural withA
          anthroAgentEffects[year+1, 9] += agent_db_withA[agentToAdult][year-1][5][agent] - agent_db_withA[yearEnd][year-1][5][agent] #anthroMortalities withA
        end
      end

      #total alive and deaths differentials
      anthroAgentEffects[year+1, 6] = anthroAgentEffects[year+1, 4] + anthroAgentEffects[year+1, 5] #total deaths
      anthroAgentEffects[year+1, 10] = anthroAgentEffects[year+1, 8] + anthroAgentEffects[year+1, 9]
      anthroAgentEffects[year+1, 11] = anthroAgentEffects[year+1, 3] - anthroAgentEffects[year+1, 7] # alive differenntial
      anthroAgentEffects[year+1, 12] = anthroAgentEffects[year+1, 6] - anthroAgentEffects[year+1, 10] # death differential
    end

    return anthroAgentEffects
  end
end
