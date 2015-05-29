"""
Tools/utilities to improve ease of use of Fish_ABM.jl
Justin Angevaare
May 2015
"""

function PadEnvironmentAssumptions!(EnvironmentAssumptions::EnvironmentAssumptions)
  """
  A basic utility function which will pad the EnvironmentAssumptions such that bounds errors do not occur when performing movement
  """
  a = fill(false, (size(EnvironmentAssumptions.spawning, 1)+2, size(EnvironmentAssumptions.spawning, 2)+2))
  a[2:end-1, 2:end-1] = EnvironmentAssumptions.spawning
  EnvironmentAssumptions.spawning = a
  a = fill(0, (size(EnvironmentAssumptions.habitat, 1)+2, size(EnvironmentAssumptions.habitat, 2)+2))
  a[2:end-1, 2:end-1] = EnvironmentAssumptions.habitat
  EnvironmentAssumptions.habitat = a
  a = fill(false, (size(EnvironmentAssumptions.risk, 1)+2, size(EnvironmentAssumptions.risk, 2)+2))
  a[2:end-1, 2:end-1] = EnvironmentAssumptions.risk
  EnvironmentAssumptions.risk = a
  return EnvironmentAssumptions
end
