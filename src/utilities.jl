"""
Tools/utilities to improve ease of use of Fish_ABM.jl
Justin Angevaare
May 2015
"""

function MovementMatrix(weights::Array, EnvironmentAssumptions::EnvironmentAssumptions)
  """
  DEPRECIATED
  When a valid neighbour id exists, a movement probability will be given to that id according to the weight matrix. The weight matrix is a 3x3 numerical indicating movemment probabilities.
  """
  movement = eye(prod(size(EnvironmentAssumptions.id)))
  for r in 1:size(EnvironmentAssumptions.id)[1]
    for c in 1:size(EnvironmentAssumptions.id)[2]
      if 0 < r-1 <= size(EnvironmentAssumptions.id)[1]
        if 0 < c-1 <= size(EnvironmentAssumptions.id)[2] && -1 == (EnvironmentAssumptions.id[r-1,c-1]) == false
          movement[EnvironmentAssumptions.id[r,c], EnvironmentAssumptions.id[r-1,c-1]] = weights[1,1]
        end
        if 0 < c <= size(EnvironmentAssumptions.id)[2] && -1 == (EnvironmentAssumptions.id[r-1,c]) == false
          movement[EnvironmentAssumptions.id[r,c], EnvironmentAssumptions.id[r-1,c]] = weights[1,2]
        end
        if 0 < c+1 <= size(EnvironmentAssumptions.id)[2] && -1 == (EnvironmentAssumptions.id[r-1,c+1]) == false
          movement[EnvironmentAssumptions.id[r,c], EnvironmentAssumptions.id[r-1,c+1]] = weights[1,3]
        end
      end
      if 0 < r <= size(EnvironmentAssumptions.id)[1]
        if 0 < c-1 < size(EnvironmentAssumptions.id)[2] && -1 == (EnvironmentAssumptions.id[r,c-1]) == false
          movement[EnvironmentAssumptions.id[r,c], EnvironmentAssumptions.id[r,c-1]] = weights[2,1]
        end
        if 0 < c <= size(EnvironmentAssumptions.id)[2] && -1 == (EnvironmentAssumptions.id[r,c]) == false
          movement[EnvironmentAssumptions.id[r,c], EnvironmentAssumptions.id[r,c]] = weights[2,2]
        end
        if 0 < c+1 <= size(EnvironmentAssumptions.id)[2] && -1 == (EnvironmentAssumptions.id[r,c+1]) == false
          movement[EnvironmentAssumptions.id[r,c], EnvironmentAssumptions.id[r,c+1]] = weights[2,3]
        end
      end
      if 0 < r+1 <= size(EnvironmentAssumptions.id)[1]
        if 0 < c-1 <= size(EnvironmentAssumptions.id)[2] && -1 == (EnvironmentAssumptions.id[r+1,c-1]) == false
          movement[EnvironmentAssumptions.id[r,c], EnvironmentAssumptions.id[r+1,c-1]] = weights[3,1]
        end
        if 0 < c <= size(EnvironmentAssumptions.id)[2] && -1 == (EnvironmentAssumptions.id[r+1,c]) == false
          movement[EnvironmentAssumptions.id[r,c], EnvironmentAssumptions.id[r+1,c]] = weights[3,2]
        end
        if 0 < c+1 <= size(EnvironmentAssumptions.id)[2] && -1 == (EnvironmentAssumptions.id[r,c+1]) == false
          movement[EnvironmentAssumptions.id[r,c], EnvironmentAssumptions.id[r+1,c+1]] = weights[3,3]
        end
      end
      tempsum = sum(movement[EnvironmentAssumptions.id[r,c],:])
      movement[EnvironmentAssumptions.id[r,c],:] = movement[EnvironmentAssumptions.id[r,c],:]./tempsum
    end
  end
  return movement
end

function PadEnvironmentAssumptions!(EnvironmentAssumptions::EnvironmentAssumptions)
  """
  A basic utility function which will pad the EnvironmentAssumptions such that bounds errors do not occur when performing movement
  """
  a = fill(-1, (size(EnvironmentAssumptions.id, 1)+2, size(EnvironmentAssumptions.id, 2)+2))
  a[2:end-1, 2:end-1] = EnvironmentAssumptions.id
  EnvironmentAssumptions.id = a
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
