"""
Tools/utilities to improve ease of use of Fish_ABM.jl
Justin Angevaare
May 2015
"""

function movement_matrix(weights::Array, environment_assumptions::environment_assumptions)
  """
  When a valid neighbour id exists, a movement probability will be given to that id according to the weight matrix. The weight matrix is a 3x3 numerical indicating movemment probabilities.
  """
  movement = eye(prod(size(environment_assumptions.id)))
  for r in 1:size(environment_assumptions.id)[1]
    for c in 1:size(environment_assumptions.id)[2]
      if 0 < r-1 <= size(environment_assumptions.id)[1]
        if 0 < c-1 <= size(environment_assumptions.id)[2] && -1 == (environment_assumptions.id[r-1,c-1]) == false
          movement[environment_assumptions.id[r,c], environment_assumptions.id[r-1,c-1]] = weights[1,1]
        end
        if 0 < c <= size(environment_assumptions.id)[2] && -1 == (environment_assumptions.id[r-1,c]) == false
          movement[environment_assumptions.id[r,c], environment_assumptions.id[r-1,c]] = weights[1,2]
        end
        if 0 < c+1 <= size(environment_assumptions.id)[2] && -1 == (environment_assumptions.id[r-1,c+1]) == false
          movement[environment_assumptions.id[r,c], environment_assumptions.id[r-1,c+1]] = weights[1,3]
        end
      end
      if 0 < r <= size(environment_assumptions.id)[1]
        if 0 < c-1 < size(environment_assumptions.id)[2] && -1 == (environment_assumptions.id[r,c-1]) == false
          movement[environment_assumptions.id[r,c], environment_assumptions.id[r,c-1]] = weights[2,1]
        end
        if 0 < c <= size(environment_assumptions.id)[2] && -1 == (environment_assumptions.id[r,c]) == false
          movement[environment_assumptions.id[r,c], environment_assumptions.id[r,c]] = weights[2,2]
        end
        if 0 < c+1 <= size(environment_assumptions.id)[2] && -1 == (environment_assumptions.id[r,c+1]) == false
          movement[environment_assumptions.id[r,c], environment_assumptions.id[r,c+1]] = weights[2,3]
        end
      end
      if 0 < r+1 <= size(environment_assumptions.id)[1]
        if 0 < c-1 <= size(environment_assumptions.id)[2] && -1 == (environment_assumptions.id[r+1,c-1]) == false
          movement[environment_assumptions.id[r,c], environment_assumptions.id[r+1,c-1]] = weights[3,1]
        end
        if 0 < c <= size(environment_assumptions.id)[2] && -1 == (environment_assumptions.id[r+1,c]) == false
          movement[environment_assumptions.id[r,c], environment_assumptions.id[r+1,c]] = weights[3,2]
        end
        if 0 < c+1 <= size(environment_assumptions.id)[2] && -1 == (environment_assumptions.id[r,c+1]) == false
          movement[environment_assumptions.id[r,c], environment_assumptions.id[r+1,c+1]] = weights[3,3]
        end
      end
      tempsum = sum(movement[environment_assumptions.id[r,c],:])
      movement[environment_assumptions.id[r,c],:] = movement[environment_assumptions.id[r,c],:]./tempsum
    end
  end
  return movement
end

function LocalMovement(location, weights::Array, environment_assumptions::environment_assumptions)
  """
  A function which creates a reduced movement matrix (3,3) for any current location
  """
  # Match location id to map index
  id_ind=findn(environment_assumptions.id .== location)
  choices=[location, weights[2,2]]
  if id_ind[1][1] > 1
    if id_ind[2][1] > 1 && environment_assumptions.id[id_ind[1][1]-1, id_ind[2][1]-1] != -1
      choices = vcat(choices, [environment_assumptions.id[id_ind[1][1]-1, id_ind[2][1]-1], weights[1,1]])
    end
    if environment_assumptions.id[id_ind[1][1]-1, id_ind[2][1]] != -1
      choices = vcat(choices, [environment_assumptions.id[id_ind[1][1]-1, id_ind[2][1]], weights[1,2]])
    end
    if id_ind[2][1] < size(environment_assumptions.id, 2) && environment_assumptions.id[id_ind[1][1]-1, id_ind[2][1]+1] != -1
      choices = vcat(choices, [environment_assumptions.id[id_ind[1][1]-1, id_ind[2][1]+1], weights[1,3]])
    end
  end
  if id_ind[2][1] > 1 && environment_assumptions.id[id_ind[1][1], id_ind[2][1]-1] != -1
    choices = vcat(choices, [environment_assumptions.id[id_ind[1][1], id_ind[2][1]-1], weights[2,1]])
  end
  if id_ind[2][1] < size(environment_assumptions.id, 2) && environment_assumptions.id[id_ind[1][1], id_ind[2][1]+1] != -1
    choices = vcat(choices, [environment_assumptions.id[id_ind[1][1], id_ind[2][1]+1], weights[2,3]])
  end
  if id_ind[1][1] < size(environment_assumptions.id, 1)
    if id_ind[2][1] > 1 && environment_assumptions.id[id_ind[1][1]+1, id_ind[2][1]-1] != -1
      choices = vcat(choices, [environment_assumptions.id[id_ind[1][1]+1, id_ind[2][1]-1], weights[3,1]])
    end
    if environment_assumptions.id[id_ind[1][1]+1, id_ind[2][1]] != -1
      choices = vcat(choices, [environment_assumptions.id[id_ind[1][1]+1, id_ind[2][1]], weights[3,2]])
    end
    if id_ind[2][1] < size(environment_assumptions.id, 2) && environment_assumptions.id[id_ind[1][1]+1, id_ind[2][1]+1] != -1
      choices = vcat(choices, [environment_assumptions.id[id_ind[1][1]+1, id_ind[2][1]+1], weights[3,3]])
    end
  end
  choices[,2]/sum(choices[,2])
  return choices[1, find(rand(Multinomial(1, choices[2,:])))]
end
