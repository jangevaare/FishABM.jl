include("Fish_ABM.jl")

# Generate the simulation_db

#Initialize

# Initial age distribution of adults
s_db = stock_db(DataFrame(age_2=30000,
                          age_3=20000,
                          age_4=15000,
                          age_5=10000,
                          age_6=8000))

# Stock assumptions - survivorship and fecundity (proportion sexually mature and mean brood size at age)
s_a = stock_assumptions([0.35, 0.45, 0.4, 0.35, 0.2],
                        [0.1, 0.5, 0.9, 1, 1],
                        [7500, 15000, 20000, 22500, 25000])

# Agent assumptions - weekly mortality risks and growth (weeks until next stage)
a_a = agent_assumptions([[0.05 0.1 0.05]
                         [0.05 0.1 0.05]],
                         [0.1, 0.2, 0.15],
                         [19, 52, 104])

# Randomly generate a simple 3x3 life_map (id, spawning areas, habitat type and risk1)
l_m = life_map(reshape(1:9, (3,3)),
               rand(Bool, (3,3)),
               rand(1:2, (3,3)),
               rand(Bool, (3,3)))

# Try create_agent_db
a_db = create_agent_db(10)

# Try the spawn! function
spawn!(a_db, s_db, s_a, l_m, 1)


# Try the kill! function
kill!(a_db, l_m)

# Try the age_adults! function
age_adults!(s_db, s_a)


