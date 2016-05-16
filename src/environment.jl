"""
  FishABM.jl
  Devin Rose
  Generates an abstracted environment from bathymetry data.
  File name: environment.jl
  Updated: March, 2016
"""


function isEmpty(empty_check::EnviroAgent)
  """
    Add description.

    Last update: May 2016
  """
  #check length of vector
  for i = 1:length(empty_check.alive)
    #if agents are in the location
    if empty_check.alive[i] != 0
      return false
    end
  end

  #if no agents are found, function returns true
  return true
end


function initEnvironment(pathToSpawn::ASCIIString, pathToHabitat::ASCIIString, pathToRisk::ASCIIString)
  """
    Description: Generates an environment for the simulation. Both the
    risk assessment and spawning environments are abstracted to a list of
    integer values.

    Precondition: The files containing the spawn, habitat and risk data are all csv files.

    Last update: March 2016
  """
  #Pad all incoming arrays
  spawn = readdlm(pathToSpawn, ',', Bool)[150:end, 200:370]; spawn = pad_environment!(spawn);
  habitat = readdlm(pathToHabitat, ',', Int)[150:end, 200:370]; habitat = pad_environment!(habitat);
  risk = readdlm(pathToRisk, ',', Bool)[150:end, 200:370]; risk = pad_environment!(risk);
  totalLength = (size(spawn)[1])*(size(spawn)[2])

  abstractSpawn = [0]
  abstractRisk = [0]

  for index = 1:totalLength
    if spawn[index] == true
      if abstractSpawn[1] == 0
        abstractSpawn[1] = index
      else
        push!(abstractSpawn, index)
      end
    end

    if risk[index] == true
      if abstractRisk[1] == 0
        abstractRisk[1] = index
      else
        push!(abstractRisk, index)
      end
    end
  end

  e_a = EnvironmentAssumptions(abstractSpawn,
                            [0],
                            habitat,
                            abstractRisk,
                            [0])

  return e_a
end


function hashEnvironment!(a_db::Vector, enviro::EnvironmentAssumptions)
  """
    Generates a hash map to reference agent numbers from known spawning and risk spatial locations.
    i.e. e_a.spawning[someNum] = (a_db[e_a.spawningHash[sumNum]]).locationID

    Precondition: The environment has been initialized (initEnvironment) and AgentDB
      has been generated.
  """
  #Initialize required variables
  totalAgents = length(a_db)
  enviro.spawningHash = Array(Int64, length(enviro.spawning))
  enviro.riskHash = Array(Int64, length(enviro.risk))

  #map spawning and risk identities to agent numbers
  for agent = 1:totalAgents
    riskNum = findfirst(enviro.risk, (a_db[agent]).locationID)
    if riskNum != 0
      enviro.riskHash[riskNum] = agent
    end

    spawnNum = findfirst(enviro.spawning, (a_db[agent]).locationID)
    if spawnNum != 0
      enviro.spawningHash[spawnNum] = agent
    end
  end

  return enviro
end


function pad_environment!(pad_array::Array)
  """
    Taken from FishABM.utilities.jl
    Justin Angevaare
    Created: May 2015

    Description: A basic utility function which will pad the
    EnvironmentAssumptions such that bounds errors do not occur when performing
    hashing and movement.

    Postcondition: When padding takes place, any boolean arrays will be given a false
      value instead of 0 automatically.
  """
  a = fill(0, (size(pad_array, 1)+2, size(pad_array, 2)+2))
  a[2:end-1, 2:end-1] = pad_array
  pad_array = a
  return pad_array
end
