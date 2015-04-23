include("Fish_ABM.jl")

# Generate the simulation_db

#Initialize

# Initial age distribution of adults
s_db = stock_db(DataFrame(Year2=30000,
                          Year3=20000,
                          Year4=15000,
                          Year5=10000,
                          Year6=8000))

# Fecundity assumptions (proportion sexually mature and mean brood size at age)
s_a = stock_assumptions([0.35, 0.45, 0.4, 0.35, 0.2],
                        [0.1, 0.5, 0.9, 1, 1],
                        [7500, 15000, 20000, 22500, 25000])

# Create a simple 2x2 life_map
l_m = life_map([[1 2]
                [3 4]],
               [[true false]
                [false false]],
               [[1 2]
                [1 2]],
               [[false true]
                [false true]])
# Try the age_adults! function
age_adults!(s_db, s_a)



