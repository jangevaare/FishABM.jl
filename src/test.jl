"""
Informally test Fish_ABM functions
Justin Angevaare
May 2015
"""

# To use package
using DataFrames, Fish_ABM

# Stock assumptions - survivorship and fecundity (proportion sexually mature and mean brood size at age)
s_a = stock_assumptions([0.15, 0.30, 0.35, 0.4, 0.4],
                        [0., 0.1, 0.4, 0.7, 1],
                        [7500, 15000, 20000, 22500, 25000],
                        [50000, NaN, NaN, NaN, NaN],
                        [0.00001, 0.00002, 0.000025, 0.000025, 0.000025])

# Randomly generate a simple 3x3 environment_assumptions (id, spawning areas, habitat type and risk1)
e_a = environment_assumptions(reshape(1:(3*3), (3,3)),
                              rand(Bool, (3,3)),
                              rand(1:2, (3,3)),
                              rand(Bool, (3,3)))

# Agent assumptions - weekly mortality risks and growth (weeks until next stage)
a_a = agent_assumptions([[0.005 0.005 0.005]
                         [0.01 0.01 0.01]],
                         [0.05, 0.1, 0.1],
                         [19, 52, 104],
                         fill(0.0, (9,9,3)))

# Try the movement_matrix function to specify the movement transition probability matrix
a_a.movement[:,:,1] = movement_matrix([[0 0 0]
                                       [0 1 0]
                                       [0 0 0]], e_a)
a_a.movement[:,:,2] = movement_matrix([[1 1 2]
                                       [1 6 3]
                                       [1 2 2]], e_a)
a_a.movement[:,:,3] = movement_matrix([[1 1 2]
                                       [1 3 3]
                                       [1 2 2]], e_a)

# Must set initial age distribution of adults, and create an empty dataframe for fishing mortality
s_db = stock_db(DataFrame(age_2=30000,
                          age_3=20000,
                          age_4=15000,
                          age_5=10000,
                          age_6=8000),
                DataFrame(age_2=Int[],
                          age_3=Int[],
                          age_4=Int[],
                          age_5=Int[],
                          age_6=Int[]))

# Try the simulate function
@time a_db = simulate(25, fill(0., 25), s_db, s_a, a_a, e_a)

s_db.population
#write.table("adult.csv", s_db.population)
