"""
Tools/utilities to improve ease of use of Fish_ABM.jl
Justin Angevaare
May 2015
"""

function movement_matrix(weights::Array, environment_assumptions::environment_assumptions)
  """
  When a valid neighbouring location exists, a movement probability will be given to that location according to the weight matrix
  """
  movement = eye(prod(shape(environment_assumptions.location)))
  for r in 1:shape(environment_assumptions.location)[1]
    for c in 1:shape(environment_assumptions.location)[2]
      if 0 < r-1 < shape(environment_assumptions.location)[1]
        if 0 < c-1 < shape(environment_assumptions.location)[2]  && environment_assumptions.location[r-1,c-1] != NaN
          movement[environment_assumptions.location[r,c], environment_assumptions.location[r-1,c-1]] = weights[1,1]
        end
        if 0 < c < shape(environment_assumptions.location)[2] && environment_assumptions.location[r-1,c] != NaN
          movement[environment_assumptions.location[r,c], environment_assumptions.location[r-1,c]] = weights[1,2]
        end
        if 0 < c+1 < shape(environment_assumptions.location)[2] && environment_assumptions.location[r-1,c+1] != NaN
          movement[environment_assumptions.location[r,c], environment_assumptions.location[r-1,c+1]] = weights[1,3]
        end
      end
      if 0 < r < shape(environment_assumptions.location)[1]
        if 0 < c-1 < shape(environment_assumptions.location)[2]  && environment_assumptions.location[r,c-1] != NaN
          movement[environment_assumptions.location[r,c], environment_assumptions.location[r,c-1]] = weights[2,1]
        end
        if 0 < c < shape(environment_assumptions.location)[2] && environment_assumptions.location[r,c] != NaN
          movement[environment_assumptions.location[r,c], environment_assumptions.location[r,c]] = weights[2,2]
        end
        if 0 < c+1 < shape(environment_assumptions.location)[2] && environment_assumptions.location[r,c+1] != NaN
          movement[environment_assumptions.location[r,c], environment_assumptions.location[r,c+1]] = weights[2,3]
        end
      end
      if 0 < r+1 < shape(environment_assumptions.location)[1]
        if 0 < c-1 < shape(environment_assumptions.location)[2]  && environment_assumptions.location[r+1,c-1] != NaN
          movement[environment_assumptions.location[r,c], environment_assumptions.location[r+1,c-1]] = weights[3,1]
        end
        if 0 < c < shape(environment_assumptions.location)[2] && environment_assumptions.location[r+1,c] != NaN
          movement[environment_assumptions.location[r,c], environment_assumptions.location[r+1,c]] = weights[3,2]
        end
        if 0 < c+1 < shape(environment_assumptions.location)[2] && environment_assumptions.location[r,c+1] != NaN
          movement[environment_assumptions.location[r,c], environment_assumptions.location[r+1,c+1]] = weights[3,3]
        end
      end
      tempsum = sum(movement[environment_assumptions.location[r,c],:])
      movement[environment_assumptions.location[r,c],:] = movement[environment_assumptions.location[r,c],:]./tempsum
    end
  end
  return movement
end
